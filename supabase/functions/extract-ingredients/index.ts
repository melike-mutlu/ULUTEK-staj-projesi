// Akıllı Sepet — extract-ingredients Edge Function
// Kullanıcının çektiği ürün etiketi fotoğraf(lar)ını Vision LLM'e gönderip
// yapılandırılmış içerik/besin değeri bilgisini döner.
//
// Ağır iş (base64 dönüştürme, prompt, LLM çağrısı, şema doğrulama)
// _shared/visionExtract.ts'de yapılıyor 
//
// Girdi:  { image_urls: string[] }
// Çıktı:  { status: "success", extracted: VisionExtractResult } | { status: "error", message }

import { getUserClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";
import {
  extractFromImages,
  ValidationError,
  LlmError,
} from "../_shared/visionExtract.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    // 1) Kullanıcının JWT'sini kontrol et
    const userClient = getUserClient(req);
    const { data: { user }, error } = await userClient.auth.getUser();

    if (error || !user) {
      return jsonResponse({ status: "error", message: "Kimlik doğrulanamadı" }, 401);
    }

    // 2) İstek gövdesini al
    const { image_urls } = await req.json();

    if (!Array.isArray(image_urls) || image_urls.length === 0) {
      return jsonResponse(
        { status: "error", message: "image_urls zorunludur ve en az bir URL içermelidir" },
        400,
      );
    }

    // 3) Vision LLM'e gönder, doğrula
    const extracted = await extractFromImages(image_urls);

    return jsonResponse({ status: "success", extracted });
  } catch (error) {
    if (error instanceof ValidationError) {
      console.error("Vision şema doğrulama hatası:", error.message);
      return jsonResponse(
        { status: "error", message: "Fotoğraftan çıkarılan veri geçersiz, lütfen tekrar deneyin" },
        502,
      );
    }
    if (error instanceof LlmError) {
      console.error("Vision LLM hatası:", error.message);
      return jsonResponse(
        { status: "error", message: "Fotoğraf işlenemedi, lütfen tekrar deneyin" },
        502,
      );
    }
    console.error("extract-ingredients hatası:", error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
}); 