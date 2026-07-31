<<<<<<< HEAD
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Admin client: RLS'i bypass eder, sadece Edge Function içinde (server-side) kullanılır.
export function createAdminClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
}

// User client: isteği atan kullanıcının JWT'siyle çalışır, auth.getUser() için kullanılır.
export function createUserClient(authHeader: string) {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authHeader ?? "" } } },
  );
=======
// Akıllı Sepet — submit-pending-product Edge Function
// Girdi:  { barcode, product_name, ingredients_text, image_front_url, image_ingredients_url, image_nutrition_url }
// Çıktı:  { status: "success", product } | { status: "error", message }

import { getServiceClient, getUserClient } from "../_shared/lib/supabaseClient.ts";

Deno.serve(async (req) => {
  try {
    const {
      barcode,
      product_name,
      ingredients_text,
      image_front_url,
      image_ingredients_url,
      image_nutrition_url,
    } = await req.json();

    if (!barcode) {
      return jsonResponse({ status: "error", message: "barcode zorunlu" }, 400);
    }

    const supabase = getServiceClient();

    // İsteği gönderen kullanıcının kimliğini JWT üzerinden çözüyoruz
    const userClient = getUserClient(req);
    const { data: { user } } = await userClient.auth.getUser();

    if (!user) {
      return jsonResponse({ status: "error", message: "yetkisiz" }, 401);
    }

    const { data: product, error } = await supabase
      .from("pending_products")
      .insert({
        barcode,
        user_id: user.id,
        product_name,
        ingredients_text,
        image_front_url,
        image_ingredients_url,
        image_nutrition_url,
        status: "PENDING",
      })
      .select()
      .single();

    if (error) {
      return jsonResponse({ status: "error", message: error.message }, 500);
    }

    return jsonResponse({ status: "success", product });
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
>>>>>>> origin/main
}