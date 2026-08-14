import { getServiceClient, getUserClient } from "../_shared/lib/supabaseClient.ts";
import { getFromCache, saveToCache } from "../_shared/supabase/productCache.service.ts";
import { fetchFromOpenFoodFacts } from "../_shared/openFoodFacts/openFoodFacts.service.ts";
import { runRuleEngine, findMissingFields } from "../_shared/ruleEngine/ruleEngine.service.ts";
import { getAdditiveInfo } from "../_shared/ruleEngine/additives_dictionary.ts";
import { findSafeAlternatives } from "../_shared/alternativeProducts.service.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

Deno.serve(async (req: Request) => {
  // CORS Preflight istekleri için
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const { barcode } = await req.json();
    if (!barcode) {
      return jsonResponse({ status: "error", message: "barcode zorunlu" }, 400);
    }

    const supabase = getServiceClient();
    const userClient = getUserClient(req);
    const { data: { user } } = await userClient.auth.getUser();

    let product = await getFromCache(barcode);
    if (!product) {
      const offProduct = await fetchFromOpenFoodFacts(barcode);
      if (!offProduct) {
        return jsonResponse({ status: "not_found", barcode });
      }
      product = await saveToCache(offProduct);
    }

    let ruleEngineResult = null;
    let safeAlternatives: unknown[] = [];
    if (user) {
      const { data: profile } = await supabase
        .from("profiles")
        .select()
        .eq("user_id", user.id)
        .maybeSingle();
      // Profil olmasa bile rule engine çalışır (null-safe) — eskisi gibi.
      ruleEngineResult = runRuleEngine(product, profile);

      // Alternatifler gerçek bir profil gerektirir, aksi halde anlamsız olur.
      if (profile) {
        safeAlternatives = await findSafeAlternatives(product, profile, supabase);
      }
    }

    const missingFields = findMissingFields(product);
    const additivesDetails = (product.additives ?? []).map(getAdditiveInfo);

    return jsonResponse({
      status: missingFields.length > 0 ? "partial" : "found",
      product,
      additives_details: additivesDetails,
      rule_engine_result: ruleEngineResult,
      safe_alternatives: safeAlternatives,
      ...(missingFields.length > 0 ? { missing_fields: missingFields } : {}),
    });
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});
