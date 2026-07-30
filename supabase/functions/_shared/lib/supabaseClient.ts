import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Tam yetkili client (SERVICE_ROLE) — RLS'i atlar.
// Sadece fonksiyonun kendisinin yapması gereken işlemler için kullan
// (örneğin doğrulamadan sonra insert işlemi gibi).
export function getServiceClient() {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
}

// İsteği gönderen kullanıcıyı temsil eden client
// (Authorization header'daki JWT üzerinden).
// Kullanıcının kimliğini öğrenmek (auth.getUser()) veya
// kullanıcının yetkilerine saygı gösterilmesi gereken işlemler için kullan.
export function getUserClient(req: Request) {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } } },
  );
}