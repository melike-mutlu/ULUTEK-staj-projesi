import { getServiceClient } from "../lib/supabaseClient.ts";

export async function getPendingProduct(barcode: string) {
  const supabase = getServiceClient();
  const { data, error } = await supabase
    .from("pending_products")
    .select()
    .eq("barcode", barcode)
    .eq("status", "PENDING")
    .maybeSingle();
  if (error) throw error;
  return data;
}
