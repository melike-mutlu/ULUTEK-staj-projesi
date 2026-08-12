// Akıllı Sepet — extract-ingredients Edge Function
// Kullanıcının çektiği ürün etiketi fotoğraf(lar)ını Vision LLM'e gönderip
// yapılandırılmış içerik/besin değeri bilgisini döner.
//
// Ağır iş (base64 dönüştürme, prompt, LLM çağrısı, şema doğrulama)
// _shared/visionExtract.ts'de yapılıyor
//
// Girdi:  { image_base64: string, mime_type: string } — mobilin gönderdiği tek fotoğraf
//         veya { image_urls: string[] } — Storage'a zaten yüklenmiş fotoğraf(lar)
// Çıktı:  { status: "success", ingredients_text, ...VisionExtractResult'un geri kalanı }
//         | { status: "error", message }
// NOT: pending_product_repository.dart yalnızca üst seviyedeki "ingredients_text" alanını okur.

import { getUserClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";
import {
  extractFromImages,
  ValidationError,
  LlmError,
  type ImageInput,
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

    // 2) İstek gövdesini al — mobil tek fotoğrafı base64 gönderiyor,
    //    image_urls Storage URL'si olan çağıranlar için alternatif.
    const { image_base64, mime_type, image_urls } = await req.json();

    let images: ImageInput[];
    if (typeof image_base64 === "string" && image_base64.length > 0) {
      images = [{ mime_type: mime_type || "image/jpeg", data: image_base64 }];
    } else if (Array.isArray(image_urls) && image_urls.length > 0) {
      images = image_urls;
    } else {
      return jsonResponse(
        { status: "error", message: "image_base64 veya image_urls zorunludur" },
        400,
      );
    }

    // 3) Vision LLM'e gönder, doğrula
    const extracted = await extractFromImages(images);

    return jsonResponse({ status: "success", ...extracted });
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