// Akıllı Sepet — fetch-product Edge Function
// docs/architecture.md — Sözleşme 1: Mobil -> Backend

import { createAdminClient, createUserClient } from "../../services/supabase/supabaseClient.ts";
import { getFromCache, saveToCache } from "../../services/supabase/productCache.service.ts";
import { fetchFromOpenFoodFacts } from "../../services/openFoodFacts/openFoodFacts.service.ts";
import { runRuleEngine, findMissingFields } from "../../services/ruleEngine/ruleEngine.service.ts";
import { jsonResponse } from "../../services/shared/http.ts";

Deno.serve(async (req) => {
  try {
    const { barcode } = await req.json();
    if (!barcode) {
      return jsonResponse({ status: "error", message: "barcode zorunlu" }, 400);
    }

    const supabase = createAdminClient();
    const userClient = createUserClient(req.headers.get("Authorization") ?? "");
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