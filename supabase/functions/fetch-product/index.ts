import { getServiceClient, getUserClient } from "../_shared/lib/supabaseClient.ts";
import { lookupProduct } from "../_shared/productLookup.service.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

Deno.serve(async (req: Request) => {
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

    let profile = null;
    if (user) {
      const { data } = await supabase
        .from("profiles")
        .select()
        .eq("user_id", user.id)
        .maybeSingle();
      profile = data;
    }

    const result = await lookupProduct(supabase, barcode, profile);
    return jsonResponse(result);
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});