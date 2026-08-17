// Akıllı Sepet — Tek barkod için ürün + kural motoru sonucu getirme.
// fetch-product ve compare-products tarafından paylaşılan çekirdek mantık.

import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import { getFromCache, saveToCache } from "./supabase/productCache.service.ts";
import { getPendingProduct } from "./supabase/pendingProduct.service.ts";
import { fetchFromOpenFoodFacts } from "./openFoodFacts/openFoodFacts.service.ts";
import { runRuleEngine, findMissingFields } from "./ruleEngine/ruleEngine.service.ts";
import { getAdditiveInfo } from "./ruleEngine/additives_dictionary.ts";
import { findSafeAlternatives } from "./alternativeProducts.service.ts";

export interface ProductLookupResult {
  status: "found" | "partial" | "not_found";
  barcode: string;
  product?: unknown;
  additives_details?: unknown[];
  rule_engine_result?: unknown;
  safe_alternatives?: unknown[];
  missing_fields?: string[];
}

/**
 * Bir barkod için ürünü (cache veya OFF'tan) getirir, verilen profille
 * kural motorunu çalıştırır. Profil isteğe bağlıdır — dışarıdan bir kez
 * çekilip her çağrıya aynı profil geçilir (N barkod için N kez profil
 * sorgusu yapmamak için).
 */
export async function lookupProduct(
  supabase: SupabaseClient,
  barcode: string,
  profile: Record<string, unknown> | null,
): Promise<ProductLookupResult> {
  let product = await getFromCache(barcode);
  if (!product) {
    const offProduct = await fetchFromOpenFoodFacts(barcode);
    if (!offProduct) {
      // OFF'ta yok — topluluk tarafından eklenmiş, onay bekleyen bir ürün mü diye bak.
      // Bu durumda kural motorunu çalıştırmıyoruz: pending_products'ta besin/alerjen
      // verisi henüz doğrulanmadığından güvenilir bir karar üretilemez.
      const pending = await getPendingProduct(barcode);
      if (!pending) {
        return { status: "not_found", barcode };
      }
      return {
        status: "found",
        barcode,
        product: {
          id: pending.id,
          barcode: pending.barcode,
          name: pending.product_name ?? "Bilinmeyen Ürün (Onay Bekliyor)",
          ingredients_text: pending.ingredients_text ?? "",
          image_url: pending.image_front_url,
          is_pending: true,
        },
        additives_details: [],
        rule_engine_result: null,
        safe_alternatives: [],
      };
    }
    product = await saveToCache(offProduct);
  }

  let ruleEngineResult = null;
  let safeAlternatives: unknown[] = [];
  if (profile) {
    ruleEngineResult = runRuleEngine(product, profile);
    safeAlternatives = await findSafeAlternatives(product, profile, supabase);
  } else {
    // Profil olmasa bile rule engine null-safe çalışır — eskisi gibi.
    ruleEngineResult = runRuleEngine(product, null);
  }

  const missingFields = findMissingFields(product);
  const additivesDetails = (product.additives ?? []).map(getAdditiveInfo);

  return {
    status: missingFields.length > 0 ? "partial" : "found",
    barcode,
    product,
    additives_details: additivesDetails,
    rule_engine_result: ruleEngineResult,
    safe_alternatives: safeAlternatives,
    ...(missingFields.length > 0 ? { missing_fields: missingFields } : {}),
  };
}