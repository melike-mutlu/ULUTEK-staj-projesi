// Akıllı Sepet — fetch-product Edge Function
// docs/architecture.md — Sözleşme 1: Mobil -> Backend
//
// Girdi:  { barcode: string }  (Authorization header'daki JWT'den kullanıcı çözülür)
// Çıktı:  { status, product, rule_engine_result } | { status: "not_found" }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const OFF_BASE_URL = "https://world.openfoodfacts.org/api/v2/product";

Deno.serve(async (req) => {
  try {
    const { barcode } = await req.json();
    if (!barcode) {
      return jsonResponse({ status: "error", message: "barcode zorunlu" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Çağıran kullanıcıyı isteğin Authorization header'ındaki JWT'den çöz.
    const userClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } },
    );
    const { data: { user } } = await userClient.auth.getUser();

    let product = await getFromCache(supabase, barcode);

    if (!product) {
      const offProduct = await fetchFromOpenFoodFacts(barcode);
      if (!offProduct) {
        return jsonResponse({ status: "not_found", barcode });
      }
      product = await saveToCache(supabase, offProduct);
    }

    // Kural motoru: kullanıcının profili DB'den okunur, product'ın allergens_tags'iyle
    // deterministik eşleştirilir. Bu adım asla LLM'e bırakılmaz.
    let ruleEngineResult = null;
    if (user) {
      const { data: profile } = await supabase
        .from("profiles")
        .select()
        .eq("user_id", user.id)
        .maybeSingle();
      ruleEngineResult = runRuleEngine(product, profile);
    }

    const missingFields = findMissingFields(product);
    return jsonResponse({
      status: missingFields.length > 0 ? "partial" : "found",
      product,
      rule_engine_result: ruleEngineResult,
      ...(missingFields.length > 0 ? { missing_fields: missingFields } : {}),
    });
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

async function getFromCache(supabase: ReturnType<typeof createClient>, barcode: string) {
  const { data } = await supabase.from("product_cache").select().eq("barcode", barcode).maybeSingle();
  return data;
}

async function fetchFromOpenFoodFacts(barcode: string) {
  const res = await fetch(`${OFF_BASE_URL}/${barcode}.json`);
  const json = await res.json();
  if (json.status !== 1) return null;

  const p = json.product;
  return {
    barcode,
    name: p.product_name ?? "",
    ingredients_text: p.ingredients_text ?? "",
    additives: p.additives_tags ?? [],
    allergens_tags: p.allergens_tags ?? [],
    nutriments: {
      energy_kcal_100g: p.nutriments?.["energy-kcal_100g"] ?? null,
      sugars_100g: p.nutriments?.sugars_100g ?? null,
      fat_100g: p.nutriments?.fat_100g ?? null,
      proteins_100g: p.nutriments?.proteins_100g ?? null,
      salt_100g: p.nutriments?.salt_100g ?? null,
    },
    nutriscore: p.nutriscore_grade ?? null,
  };
}

async function saveToCache(supabase: ReturnType<typeof createClient>, product: Record<string, unknown>) {
  await supabase.from("product_cache").upsert({ ...product, fetched_at: new Date().toISOString() });
  return product;
}

// TODO (Backend pod): diyet tercihine göre gerçek diet_flags mantığı (vegan/diyabet) genişletilecek.
function runRuleEngine(product: any, profile: any) {
  const userAllergies: string[] = profile?.allergies ?? [];
  const matched = userAllergies.filter((allergy) =>
    (product.allergens_tags ?? []).some((tag: string) =>
      tag.toLowerCase().includes(allergy.toLowerCase())
    )
  );

  return {
    matched_allergens: matched,
    has_conflict: matched.length > 0,
    diet_flags: {
      vegan_compatible: true, // TODO
      diabetic_note: null, // TODO
    },
  };
}

function findMissingFields(product: any) {
  const missing: string[] = [];
  const n = product.nutriments;
  if (!n || Object.values(n).every((v) => v == null)) missing.push("nutriments");
  return missing;
}

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
