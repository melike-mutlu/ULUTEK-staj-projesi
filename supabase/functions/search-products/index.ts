// supabase/functions/search-products/index.ts

import { searchProductsByName } from "../_shared/openFoodFacts/searchProducts.service.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

Deno.serve(async (req: Request) => {
  // CORS Preflight kontrolü
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  // Yalnızca POST isteklerini kabul et
  if (req.method !== "POST") {
    return jsonResponse(
      {
        status: "error",
        message: "Bu endpoint yalnızca POST isteklerini kabul etmektedir.",
      },
      405,
    );
  }

  try {
    // JSON gövdesi ayrıştırma güvenliği
    let body: any;

    try {
      body = await req.json();
    } catch {
      return jsonResponse(
        {
          status: "error",
          message: "Geçersiz JSON gövdesi.",
        },
        400,
      );
    }

    const rawQuery = body?.query || body?.q;
    const query = typeof rawQuery === "string" ? rawQuery.trim() : "";

    // Arama terimi geçerlilik kontrolü
    if (query.length < 2) {
      return jsonResponse(
        {
          status: "error",
          message: "Arama terimi en az 2 karakter olmalıdır.",
        },
        400,
      );
    }

    // Arama servisini çalıştır
    const results = await searchProductsByName(query);

    return jsonResponse({
      status: results.length > 0 ? "found" : "not_found",
      query,
      count: results.length,
      results,
    });
  } catch (error) {
    console.error("search-products endpoint hatası:", error);

    return jsonResponse(
      {
        status: "error",
        message: "Arama sırasında beklenmeyen bir sunucu hatası oluştu.",
      },
      500,
    );
  }
});