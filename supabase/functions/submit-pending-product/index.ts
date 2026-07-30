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
}