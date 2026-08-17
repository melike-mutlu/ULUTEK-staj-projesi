// Akıllı Sepet — compare-products Edge Function
// Birden fazla barkodu tek istekte alıp her biri için ürün + kural motoru
// sonucunu birlikte döner (fetch-product'ı N kere ayrı ayrı çağırmak yerine).
//
// Girdi:  { barcodes: string[] }  (1-10 barkod)
// Çıktı:  { status: "success", results: ProductLookupResult[] }

import { getServiceClient, getUserClient } from "../_shared/lib/supabaseClient.ts";
import { lookupProduct } from "../_shared/productLookup.service.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

const MAX_BARCODES = 10;

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const { barcodes } = await req.json();

    if (!Array.isArray(barcodes) || barcodes.length === 0) {
      return jsonResponse(
        { status: "error", message: "barcodes zorunludur ve en az bir barkod içermelidir" },
        400,
      );
    }
    if (barcodes.length > MAX_BARCODES) {
      return jsonResponse(
        { status: "error", message: `en fazla ${MAX_BARCODES} barkod karşılaştırılabilir` },
        400,
      );
    }
    if (!barcodes.every((b) => typeof b === "string" && b.trim().length > 0)) {
      return jsonResponse(
        { status: "error", message: "tüm barkodlar boş olmayan string olmalıdır" },
        400,
      );
    }

    const supabase = getServiceClient();
    const userClient = getUserClient(req);
    const { data: { user } } = await userClient.auth.getUser();

    // Profil bir kez çekilir, tüm barkodlar için aynı profil kullanılır.
    let profile = null;
    if (user) {
      const { data } = await supabase
        .from("profiles")
        .select()
        .eq("user_id", user.id)
        .maybeSingle();
      profile = data;
    }

    // Tüm barkodlar paralel olarak işlenir.
    const results = await Promise.all(
      barcodes.map((barcode: string) => lookupProduct(supabase, barcode, profile)),
    );

    return jsonResponse({ status: "success", results });
  } catch (error) {
    console.error("compare-products hatası:", error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});