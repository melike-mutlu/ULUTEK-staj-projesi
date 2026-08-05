import { getServiceClient } from "../lib/supabaseClient.ts";
import type { OffProduct } from "../openFoodFacts/openFoodFacts.service.ts";

export interface CachedProduct extends OffProduct {
  fetched_at: string;
}

/** Fresh window for a normally populated product. */
const CACHE_TTL_MS = 7 * 24 * 60 * 60 * 1000;

/** Shorter window for records that came back without allergen data, so an OFF
 * entry that was empty when first seen gets another chance soon instead of
 * staying "yetersiz veri" forever. */
const INSUFFICIENT_CACHE_TTL_MS = 24 * 60 * 60 * 1000;

/** Mirrors the rule engine: only allergen tags / ingredients count as evidence. */
function hasAllergenEvidence(row: CachedProduct): boolean {
  const tags = row.allergens_tags ?? [];
  const ingredients = String(row.ingredients_text ?? "").trim();
  return tags.length > 0 || ingredients.length > 0;
}

/**
 * A stale cache row is treated as a miss so we re-fetch from OFF. Critical for
 * safety: if OFF later adds an allergen, our old empty record must not keep
 * reporting the product as safe.
 */
function isFresh(row: CachedProduct): boolean {
  const fetchedAt = Date.parse(row.fetched_at ?? "");
  if (Number.isNaN(fetchedAt)) return false; // unknown age -> refetch

  const ttl = hasAllergenEvidence(row)
    ? CACHE_TTL_MS
    : INSUFFICIENT_CACHE_TTL_MS;
  return Date.now() - fetchedAt < ttl;
}

export async function getFromCache(
  barcode: string,
): Promise<CachedProduct | null> {
  const supabase = getServiceClient();

  const { data, error } = await supabase
    .from("product_cache")
    .select()
    .eq("barcode", barcode)
    .maybeSingle();

  if (error) throw error;
  if (!data) return null;

  const row = data as CachedProduct;
  return isFresh(row) ? row : null; // stale -> caller re-fetches from OFF
}

export async function saveToCache(
  product: OffProduct,
): Promise<OffProduct> {
  const supabase = getServiceClient();

  // Only persist columns that exist today. New OFF fields (traces_tags,
  // ingredients_analysis_tags, labels_tags) are used live per request but not
  // written until their columns are added — spreading them would break upsert.
  const { error } = await supabase
    .from("product_cache")
    .upsert({
      barcode: product.barcode,
      name: product.name,
      ingredients_text: product.ingredients_text,
      additives: product.additives,
      allergens_tags: product.allergens_tags,
      nutriments: product.nutriments,
      nutriscore: product.nutriscore,
      image_url: product.image_url,
      fetched_at: new Date().toISOString(),
    });

  if (error) throw error;

  return product;
}