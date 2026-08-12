// Akıllı Sepet — Vision LLM İçerik Çıkarma Modülü
//
// Prompt  : docs/ai/prompts/vision-extract-prompt.md
// Schema  : docs/ai/schemas/vision-extract-schema.json
// Örnek   : docs/ai/schemas/vision-extract-example.json
//
// Kullanım:
//   import { extractFromImages, validateVisionResult } from "./_shared/visionExtract.ts";
//
//   // LLM'ye gönder + doğrula
//   const result = await extractFromImages([ingredientsUrl, nutritionUrl]);
//
//   // Sadece doğrulama (LLM çağrısı olmadan, test veya mock veri için)
//   const validated = validateVisionResult(rawJson);
//
// NOT: LLM_API_KEY bir Gemini anahtarıdır (bkz. chatbot/index.ts), OpenAI değil.
// extractFromImages bu yüzden generativelanguage.googleapis.com'a istek atar.

import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";

// ─────────────────────────────────────────────────────────────────────────────
// Tip Tanımları
// ─────────────────────────────────────────────────────────────────────────────

export interface VisionNutrition {
  energy_kcal_100g: number | null;
  fat_100g: number | null;
  saturated_fat_100g: number | null;
  carbohydrates_100g: number | null;
  sugars_100g: number | null;
  proteins_100g: number | null;
  salt_100g: number | null;
  /** Lif — etikette yoksa null */
  fiber_100g: number | null;
}

export type VisionConfidence = "high" | "medium" | "low";

export interface VisionExtractResult {
  /** Ambalaj üzerindeki ürün adı. Okunamadıysa null. */
  product_name: string | null;
  /** Marka adı. Okunamadıysa null. */
  brand: string | null;
  /**
   * Ham içindekiler listesi, etiketteki haliyle.
   * product_cache.ingredients_text alanıyla doğrudan eşleşir.
   */
  ingredients_text: string | null;
  /**
   * İçindekilerden ayıklanan E-kodları.
   * product_cache.additives (text[]) alanıyla eşleşir.
   */
  additives: string[];
  /**
   * Etikette açıkça yazılan alerjen isimleri.
   * NOT: Alerjen kararı ruleEngine.service.ts'e aittir — bu liste
   * yalnızca ham etiketteki metni taşır.
   */
  allergens_mentioned: string[];
  /**
   * 100 g başına besin değerleri.
   * product_cache.nutriments (jsonb) alanıyla eşleşir.
   */
  nutrition: VisionNutrition;
  /** Porsiyon büyüklüğü (gram). Bulunamazsa null. */
  serving_size_g: number | null;
  /** LLM'nin kendi okuma kalitesi değerlendirmesi. */
  confidence: VisionConfidence;
  /**
   * Okunamayan alan adları.
   * Tüm görüntü okunamazsa ["all"] içerir.
   */
  unreadable_fields: string[];
}

// ─────────────────────────────────────────────────────────────────────────────
// Hata Sınıfları
// ─────────────────────────────────────────────────────────────────────────────

export class ValidationError extends Error {
  constructor(
    public readonly field: string,
    message: string,
  ) {
    super(`VisionExtract validation [${field}]: ${message}`);
    this.name = "ValidationError";
  }
}

export class LlmError extends Error {
  constructor(
    message: string,
    public readonly cause?: unknown,
  ) {
    super(`VisionExtract LLM error: ${message}`);
    this.name = "LlmError";
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// System Prompt (docs/ai/prompts/vision-extract-prompt.md ile senkron tutulmalı)
// ─────────────────────────────────────────────────────────────────────────────

const VISION_SYSTEM_PROMPT = `
Sen bir gıda etiketi OCR ve ayrıştırma asistanısın.
Sana bir veya birden fazla gıda ürünü etiketi fotoğrafı verilir.
Görevin: fotoğraflarda gördüğün içindekiler listesini ve besin değeri tablosunu okuyarak aşağıda tanımlanan JSON yapısını üretmektir.

────────────────────────────────────────────────────────────────
OKUMA KURALLARI
────────────────────────────────────────────────────────────────

1. Yalnızca GÖRDÜĞÜN bilgiyi yaz. Tahmin etme, uydurma, tamamlama yapma.
2. Fotoğraf birden fazla dil içeriyorsa Türkçeyi tercih et; Türkçe yoksa İngilizceyi kullan; hiçbiri yoksa görülen dildeki orijinal metni yaz.
3. ingredients_text: içindekiler listesini, etiket üzerinde nasıl yazıyorsa aynen yaz — büyük/küçük harf düzeltmesi yapma, sadece açık yazım hatalarını (bozuk karakter vb.) düzelt.
4. additives: E-kodlarını (E322, E471 gibi) içindekiler metninden ayıkla. "E" harfi büyük olmalı, sayı tam olmalı. Örnek: ["E322", "E471"].
5. allergens_mentioned: etikette açıkça "içerir: …" veya "Alerjen: …" başlığıyla ya da kalın/büyük harfle belirtilen alerjen isimlerini listele. Kural motoru tarafından yorumlanacak; sen sadece etikette YAZANI al.
6. nutrition: besin değeri tablosunu 100 g başına dönüştür.
   - Tabloda sadece porsiyon değeri varsa ve porsiyon ağırlığı belirtilmişse, 100 g'a çevir ve sonucu yaz.
   - Tabloda sadece porsiyon değeri varsa ve porsiyon ağırlığı belirtilmemişse, o alanı null bırak ve "unreadable_fields" listesine ekle.
   - Birimleri doğrula: enerji kJ ise 0.239 ile çarp, kcal'e çevir.
7. serving_size_g: "porsiyon: X g" gibi ifadelerden sayısal değeri al (sadece gram cinsinden). Bulamazsan null.
8. confidence:
   - "high"   → fotoğraf net, tüm ana alanlar okunabildi.
   - "medium" → bazı alanlar bulanık/kısmi ama ingredients_text veya nutrition büyük ölçüde okunabildi.
   - "low"    → fotoğraf çok bulanık ya da neredeyse hiçbir alan okunamadı.
9. unreadable_fields: bulanıklık, ışık, katlama, üst üste baskı vb. nedenlerle okuyamadığın alanların adlarını listele. Tamamen okunamazsa ["all"] yaz.
10. product_name ve brand null olabilir — zorla doldurma.

────────────────────────────────────────────────────────────────
ÇIKTI KURALLARI
────────────────────────────────────────────────────────────────

- SADECE ve SADECE aşağıdaki JSON yapısını döndür.
- JSON dışında hiçbir metin, açıklama, Markdown veya kod bloğu yazma.
- Sayısal alanlar her zaman number veya null olmalı — asla string olmamalı.
- Boş liste [] ile null arasındaki fark önemlidir:
    - [] → okunabildik, veri yoktu
    - null → okuyamadık / bilgi mevcut değil

JSON yapısı:
{"product_name":null,"brand":null,"ingredients_text":null,"additives":[],"allergens_mentioned":[],"nutrition":{"energy_kcal_100g":null,"fat_100g":null,"saturated_fat_100g":null,"carbohydrates_100g":null,"sugars_100g":null,"proteins_100g":null,"salt_100g":null,"fiber_100g":null},"serving_size_g":null,"confidence":"low","unreadable_fields":[]}
`.trim();

// ─────────────────────────────────────────────────────────────────────────────
// Doğrulayıcı
// ─────────────────────────────────────────────────────────────────────────────

const ADDITIVE_PATTERN = /^[Ee]\d{3}[a-zA-Z]?$/;
const CONFIDENCE_VALUES: VisionConfidence[] = ["high", "medium", "low"];

/**
 * LLM'den dönen ham nesneyi doğrular ve temizlenmiş `VisionExtractResult`
 * döndürür. Hata varsa `ValidationError` fırlatır.
 *
 * Beklenmedik alanlar sessizce kaldırılır (`strip`).
 */
export function validateVisionResult(raw: unknown): VisionExtractResult {
  if (typeof raw !== "object" || raw === null || Array.isArray(raw)) {
    throw new ValidationError("root", "JSON nesnesi bekleniyor");
  }

  const obj = raw as Record<string, unknown>;

  // ── Yardımcı ──────────────────────────────────────────────────────────────

  function requireField(key: string): unknown {
    if (!(key in obj)) {
      throw new ValidationError(key, "zorunlu alan eksik");
    }
    return obj[key];
  }

  function optionalStringOrNull(key: string, maxLen = 5000): string | null {
    const v = obj[key];
    if (v === undefined || v === null) return null;
    if (typeof v !== "string") {
      throw new ValidationError(key, "string veya null bekleniyor");
    }
    if (v.length > maxLen) {
      throw new ValidationError(
        key,
        `maksimum uzunluk aşıldı (${v.length} > ${maxLen})`,
      );
    }
    return v;
  }

  function numberInRange(
    key: string,
    value: unknown,
    min: number,
    max: number,
  ): number | null {
    if (value === null || value === undefined) return null;
    if (typeof value !== "number" || !Number.isFinite(value)) {
      throw new ValidationError(key, "geçerli sayı veya null bekleniyor");
    }
    if (value < min || value > max) {
      throw new ValidationError(
        key,
        `değer aralık dışı: ${value} (beklenen ${min}–${max})`,
      );
    }
    return value;
  }

  function stringArray(key: string): string[] {
    const v = requireField(key);
    if (!Array.isArray(v)) {
      throw new ValidationError(key, "dizi bekleniyor");
    }
    for (let i = 0; i < v.length; i++) {
      if (typeof v[i] !== "string" || (v[i] as string).length === 0) {
        throw new ValidationError(`${key}[${i}]`, "boş olmayan string bekleniyor");
      }
    }
    return v as string[];
  }

  // ── Alanları doğrula ──────────────────────────────────────────────────────

  const product_name = optionalStringOrNull("product_name", 300);
  const brand = optionalStringOrNull("brand", 200);
  const ingredients_text = optionalStringOrNull("ingredients_text", 5000);

  // additives — pattern kontrolü
  const additivesRaw = stringArray("additives");
  const uniqueAdditives = [...new Set(additivesRaw)];
  for (const code of uniqueAdditives) {
    if (!ADDITIVE_PATTERN.test(code)) {
      throw new ValidationError(
        "additives",
        `geçersiz E-kodu formatı: "${code}" (beklenen: E000 veya E000x)`,
      );
    }
  }

  // allergens_mentioned
  const allergensRaw = stringArray("allergens_mentioned");
  const allergens_mentioned = [...new Set(allergensRaw)];

  // nutrition
  const nutritionRaw = requireField("nutrition");
  if (
    typeof nutritionRaw !== "object" ||
    nutritionRaw === null ||
    Array.isArray(nutritionRaw)
  ) {
    throw new ValidationError("nutrition", "nesne bekleniyor");
  }
  const n = nutritionRaw as Record<string, unknown>;

  const nutrition: VisionNutrition = {
    energy_kcal_100g: numberInRange("energy_kcal_100g", n.energy_kcal_100g, 0, 900),
    fat_100g: numberInRange("fat_100g", n.fat_100g, 0, 100),
    saturated_fat_100g: numberInRange("saturated_fat_100g", n.saturated_fat_100g, 0, 100),
    carbohydrates_100g: numberInRange("carbohydrates_100g", n.carbohydrates_100g, 0, 100),
    sugars_100g: numberInRange("sugars_100g", n.sugars_100g, 0, 100),
    proteins_100g: numberInRange("proteins_100g", n.proteins_100g, 0, 100),
    salt_100g: numberInRange("salt_100g", n.salt_100g, 0, 100),
    fiber_100g: numberInRange("fiber_100g", n.fiber_100g, 0, 100),
  };

  // serving_size_g
  const serving_size_g = numberInRange(
    "serving_size_g",
    obj.serving_size_g ?? null,
    1,
    2000,
  );

  // confidence
  const rawConf = requireField("confidence");
  if (!CONFIDENCE_VALUES.includes(rawConf as VisionConfidence)) {
    throw new ValidationError(
      "confidence",
      `geçersiz değer: "${rawConf}" (beklenen: high | medium | low)`,
    );
  }
  const confidence = rawConf as VisionConfidence;

  // unreadable_fields
  const unreadable_fields = stringArray("unreadable_fields");

  // ── İş kuralı kontrolü ────────────────────────────────────────────────────
  // confidence=high ise en az bir alanın dolu olması gerekir
  if (confidence === "high") {
    const hasIngredients =
      typeof ingredients_text === "string" && ingredients_text.trim().length > 0;
    const hasAnyNutrition = Object.values(nutrition).some(
      (v) => v !== null,
    );
    if (!hasIngredients && !hasAnyNutrition) {
      throw new ValidationError(
        "confidence",
        'confidence "high" ama ingredients_text ve tüm nutrition alanları boş — tutarsız sonuç',
      );
    }
  }

  // ── Temizlenmiş nesneyi döndür (additionalProperties strip) ───────────────
  return {
    product_name,
    brand,
    ingredients_text,
    additives: uniqueAdditives,
    allergens_mentioned,
    nutrition,
    serving_size_g,
    confidence,
    unreadable_fields: [...new Set(unreadable_fields)],
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// LLM Çağrısı
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Bir görüntü URL'sini indirir ve Gemini'nin `inline_data` formatına çevirir.
 */
async function fetchImageAsInlineData(
  url: string,
): Promise<{ mime_type: string; data: string }> {
  let response: Response;
  try {
    response = await fetch(url);
  } catch (err) {
    throw new LlmError(`Fotoğraf indirilemedi: ${url}`, err);
  }
  if (!response.ok) {
    throw new LlmError(`Fotoğraf indirilemedi (HTTP ${response.status}): ${url}`);
  }
  const mime_type = response.headers.get("content-type")?.split(";")[0] || "image/jpeg";
  const bytes = new Uint8Array(await response.arrayBuffer());
  return { mime_type, data: encodeBase64(bytes) };
}

/**
 * Bir veya birden fazla ürün etiketi fotoğrafını Vision LLM'e gönderir,
 * dönen JSON'ı ayrıştırır ve doğrular.
 *
 * @param imageUrls  Ürün etiket fotoğraflarının public URL listesi.
 *                   Boş liste verilirse `LlmError` fırlatır.
 * @param model      Gemini model adı. Varsayılan: "gemini-3.6-flash" (bkz. chatbot/index.ts).
 * @throws LlmError       — API erişim hatası veya JSON ayrıştırma hatası
 * @throws ValidationError — Şema doğrulama hatası
 */
export async function extractFromImages(
  imageUrls: string[],
  model = "gemini-3.6-flash",
): Promise<VisionExtractResult> {
  if (imageUrls.length === 0) {
    throw new LlmError("En az bir fotoğraf URL'si gereklidir");
  }

  const apiKey = Deno.env.get("LLM_API_KEY");
  if (!apiKey) {
    throw new LlmError("LLM_API_KEY ortam değişkeni tanımlı değil");
  }

  const imageParts = await Promise.all(
    imageUrls.map(async (url) => ({
      inline_data: await fetchImageAsInlineData(url),
    })),
  );

  let response: Response;
  try {
    response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: VISION_SYSTEM_PROMPT }],
          },
          contents: [
            {
              role: "user",
              parts: [
                {
                  text: "Aşağıdaki fotoğraflardan içindekiler ve besin değerlerini oku.",
                },
                ...imageParts,
              ],
            },
          ],
          generationConfig: {
            // Düşük temperature: tutarlı, deterministik çıktı
            temperature: 0.1,
            maxOutputTokens: 1500,
            // JSON çıktısını zorla — syntax hatası riskini azaltır
            responseMimeType: "application/json",
          },
        }),
      },
    );
  } catch (err) {
    throw new LlmError("Gemini API'ye ulaşılamadı", err);
  }

  if (!response.ok) {
    const text = await response.text().catch(() => "<body okunamadı>");
    throw new LlmError(
      `Gemini API HTTP ${response.status}: ${text.slice(0, 200)}`,
    );
  }

  const payload = await response.json();
  const rawContent = payload?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (typeof rawContent !== "string" || rawContent.trim().length === 0) {
    throw new LlmError("Gemini yanıtında içerik yok");
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(rawContent);
  } catch (err) {
    throw new LlmError(
      `LLM geçerli JSON döndürmedi: ${rawContent.slice(0, 200)}`,
      err,
    );
  }

  // Doğrula ve temizlenmiş sonucu döndür
  return validateVisionResult(parsed);
}
