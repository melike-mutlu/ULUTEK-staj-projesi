// Akıllı Sepet — fetch-product Edge Function
// docs/architecture.md — Sözleşme 1: Mobil -> Backend
//
// Girdi:  { barcode: string }  (Authorization header'daki JWT'den kullanıcı çözülür)
// Çıktı:  { status, product, rule_engine_result } | { status: "not_found" }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  // CORS Preflight istekleri için
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { barcode } = await req.json();
    if (!barcode) {
      return jsonResponse({ status: "error", message: "barcode zorunlu" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Çağıran kullanıcıyı JWT'den çöz
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.replace("Bearer ", "");

    let user = null;
    if (jwt) {
      const userClient = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_ANON_KEY")!,
        { global: { headers: { Authorization: authHeader } } }
      );
      const { data } = await userClient.auth.getUser(jwt);
      user = data.user;
    }

    let product = await getFromCache(supabase, barcode);

    if (!product) {
      const offProduct = await fetchFromOpenFoodFacts(barcode);
      if (!offProduct) {
        return jsonResponse({ status: "not_found", barcode });
      }
      product = await saveToCache(supabase, offProduct);
    }

    // Kural motoru: Kullanıcı profili okunur ve kısıtlamalar kontrol edilir
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
  const res = await fetch(`${OFF_BASE_URL}/${barcode}.json`, {
    headers: { "User-Agent": "AkilliSepet - Backend - Version 1.0" },
  });
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

// Genişletilmiş Kural Motoru (Rule Engine)
function runRuleEngine(product: any, profile: any) {
  const userAllergies: string[] = profile?.allergies ?? [];
  const isVeganUser: boolean = profile?.is_vegan ?? profile?.diets?.includes("vegan") ?? false;

  // 1. Alerjen Eşleştirme
  const matchedAllergens = userAllergies.filter((allergy) =>
    (product.allergens_tags ?? []).some((tag: string) =>
      tag.toLowerCase().includes(allergy.toLowerCase())
    )
  );

  // 2. Gerçek Vegan Mantığı (İçerik ve etiket analizi)
  const ingredientsText = (product.ingredients_text || "").toLowerCase();
  const allergensTags = (product.allergens_tags || []).map((t: string) => t.toLowerCase());

  const containsAnimalProduct = ANIMAL_INGREDIENTS.some((item) =>
    ingredientsText.includes(item) ||
    allergensTags.some((tag: string) => tag.includes(item))
  );

  const veganCompatible = !containsAnimalProduct;

  // 3. Gerçek Diyabet Mantığı (Şeker analizi)
  let diabeticNote: string | null = null;
  const sugar100g = product.nutriments?.sugars_100g ?? null;

  if (sugar100g !== null) {
    if (sugar100g > 10) {
      diabeticNote = `Yüksek şeker içeriği (${sugar100g}g / 100g). Diyabetik tüketime uygun değildir.`;
    } else if (sugar100g > 5) {
      diabeticNote = `Orta düzey şeker içeriği (${sugar100g}g / 100g). Porsiyon kontrolü önerilir.`;
    } else {
      diabeticNote = `Düşük şeker içeriği (${sugar100g}g / 100g). Diyabetik tüketime uygundur.`;
    }
  } else {
    diabeticNote = "Şeker miktarı bilgisi bulunamadı, dikkatli tüketiniz.";
  }

  // Çakışma durumu: Alerjen eşleşmesi VEYA (Vegan kullanıcı için hayvansal içerik tespiti)
  const hasConflict = matchedAllergens.length > 0 || (isVeganUser && !veganCompatible);

  return {
    matched_allergens: matchedAllergens,
    has_conflict: hasConflict,
    diet_flags: {
      vegan_compatible: veganCompatible,
      diabetic_note: diabeticNote,
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
    headers: corsHeaders,
  });
}