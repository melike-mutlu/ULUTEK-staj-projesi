import { getServiceClient } from "../lib/supabaseClient.ts";
import type { OffProduct } from "../openFoodFacts/openFoodFacts.service.ts";

export interface CachedProduct extends OffProduct {
  fetched_at: string;
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

  return data as CachedProduct | null;
}

export async function saveToCache(
  product: OffProduct,
): Promise<OffProduct> {
  const supabase = getServiceClient();

  const { error } = await supabase
    .from("product_cache")
    .upsert({
      ...product,
      fetched_at: new Date().toISOString(),
    });

  if (error) throw error;

  return product;
}