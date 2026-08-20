// Akıllı Sepet — weekly-motivation Edge Function
// Kullanıcının haftalık tarama verilerine göre 1-2 cümlelik kısa AI motivasyon cümlesi üretir.
//
// Girdi:  { user_profile?: object, weekly_stats?: { total_scanned?: number, compatible_count?: number, risk_count?: number } }
// Çıktı:  { status: "success", motivation_sentence: string, disclaimer: string }
//
// Guardrail: Sağlık/güvenlik kararı VERMEZ, tıbbi tavsiye vermez. Sadece pozitif motivasyon sunar.

import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

// gpt-4o-mini kasitli olarak zincirde degil - bkz. explain-product/index.ts'teki not:
// LLM_API_KEY projede Gemini anahtari, OpenAI'a gonderilirse 401 doner.
const MODEL_FALLBACK_CHAIN = [
  "gemini-3.6-flash",
  "gemini-3.5-flash",
  "gemini-2.5-flash",
];

const RETRYABLE_STATUS_CODES = new Set([429, 503]);

const DEFAULT_MOTIVATION =
  "Bu hafta alışverişlerinde gösterdiğin özen ve attığın her bilinçli adım daha sağlıklı bir yaşam için harika bir kazanım. Böyle devam et!";

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const body = await req.json().catch(() => ({}));
    const { user_profile, weekly_stats } = body;

    const apiKey = Deno.env.get("LLM_API_KEY");
    const sentence = apiKey
      ? await generateMotivation(user_profile, weekly_stats, apiKey)
      : DEFAULT_MOTIVATION;

    return jsonResponse({
      status: "success",
      motivation_sentence: sentence,
      disclaimer: "Bu motivasyon notu bilgilendirme amaçlıdır; tıbbi tavsiye niteliği taşımaz.",
    });
  } catch (error) {
    console.error("weekly-motivation hatası:", error);
    return jsonResponse({
      status: "success",
      motivation_sentence: DEFAULT_MOTIVATION,
      disclaimer: "Bu motivasyon notu bilgilendirme amaçlıdır; tıbbi tavsiye niteliği taşımaz.",
    });
  }
});

async function generateMotivation(
  userProfile: unknown,
  weeklyStats: unknown,
  apiKey: string,
): Promise<string> {
  const prompt = `
Aşağıdaki haftalık alışveriş istatistiklerine dayanarak kullanıcıya 1-2 cümlelik kısa, pozitif ve motive edici bir destek mesajı yaz.

Kurallar:
- Kesinlikle sağlık/güvenlik garantisi veya tıbbi teşhis/tavsiye verme.
- Ürünlerin güvenli veya tehlikeli olduğuna dair hüküm verme.
- Samimi, cesaretlendirici ve yapıcı bir Türkçe kullan.
- Maksimum 200 karakter.

Profil: ${JSON.stringify(userProfile ?? {})}
İstatistikler: ${JSON.stringify(weeklyStats ?? {})}
  `.trim();

  for (let i = 0; i < MODEL_FALLBACK_CHAIN.length; i++) {
    const model = MODEL_FALLBACK_CHAIN[i];

    try {
      let response: Response;

      if (model.startsWith("gemini")) {
        response = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              systemInstruction: {
                parts: [{
                  text:
                    "Sen bir alışveriş ve sağlıklı yaşam motivasyon asistanısın. Sadece pozitif ve kısa destek cümleleri üretirsin.",
                }],
              },
              contents: [{ role: "user", parts: [{ text: prompt }] }],
              generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 150,
              },
            }),
          },
        );
      } else {
        response = await fetch("https://api.openai.com/v1/chat/completions", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model,
            temperature: 0.7,
            messages: [
              {
                role: "system",
                content:
                  "Sen bir alışveriş ve sağlıklı yaşam motivasyon asistanısın. Sadece pozitif ve kısa destek cümleleri üretirsin.",
              },
              { role: "user", content: prompt },
            ],
            max_tokens: 150,
          }),
        });
      }

      if (response.ok) {
        const payload = await response.json();
        let content: string | null = null;

        if (model.startsWith("gemini")) {
          content = payload?.candidates?.[0]?.content?.parts?.[0]?.text ?? null;
        } else {
          content = payload?.choices?.[0]?.message?.content ?? null;
        }

        if (typeof content === "string" && content.trim().length > 0) {
          return content.trim();
        }
      }

      if (!RETRYABLE_STATUS_CODES.has(response.status)) {
        break;
      }
    } catch (err) {
      console.error(`weekly-motivation ${model} hatası:`, err);
    }
  }

  return DEFAULT_MOTIVATION;
}
