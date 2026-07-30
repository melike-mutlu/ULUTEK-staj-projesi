import { getServiceClient } from "../lib/supabaseClient.ts";
import type { OffProduct } from "../openFoodFacts/openFoodFacts.service.ts";

export async function getFromCache(barcode: string) {
  const supabase = getServiceClient();
  const { data } = await supabase.from("product_cache").select().eq("barcode", barcode).maybeSingle();
  return data;
}

export async function saveToCache(product: OffProduct) {
  const supabase = getServiceClient();
  await supabase.from("product_cache").upsert({ ...product, fetched_at: new Date().toISOString() });
  return product;
}