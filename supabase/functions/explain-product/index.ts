// Akıllı Sepet — explain-product Edge Function
// docs/architecture.md — Sözleşme 2: Mobil -> AI
//
// Girdi:  { product, rule_engine_result, user_profile }
// Çıktı:  { summary, personal_warning: { level, message }, diet_note, disclaimer }
//
// Bu fonksiyon LLM'i yalnızca saf metin/JSON üretmek için kullanır.
// Alerjen, diyet ve sağlık kararlarını değiştirmemesi gerekiyor.
// API anahtarı sadece sunucu tarafında saklanır: Deno.env.get("LLM_API_KEY").

import {
  parseProfile,
  fromSupabaseProfile,
  emptyProfile,
  type ProfileSchema,
} from "./profile_parser.ts";

//import { jsonResponse, handleCorsPreflight } from "../../services/shared/http.ts";

import { jsonResponse } from "../_shared/http.ts";
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const { product, rule_engine_result, user_profile } = await req.json();

    // ── Profil normalize ──────────────────────────────────────────────────
    // Gelen user_profile Supabase formatında (diet_preference, health_conditions)
    // ya da AI şemasında (diet, goals, avoid) olabilir — her ikisini de kabul et.
    let profile: ProfileSchema;

    if (user_profile && "diet_preference" in user_profile) {
      // Supabase profiles tablosundan gelen format
      profile = fromSupabaseProfile(user_profile as Record<string, unknown>);
    } else {
      const result = parseProfile(user_profile);
      profile = result.success ? result.profile : emptyProfile();
      if (!result.success) {
        console.warn("Profil parse hatasi:", result.error, "Ham girdi:", result.raw);
      }
    }
    // ─────────────────────────────────────────────────────────────────────

    const prompt = buildPrompt(product, rule_engine_result, profile);
    const apiKey = Deno.env.get("LLM_API_KEY");
    const llmOutput = apiKey
      ? await callLlm(prompt, apiKey)
      : await callLlmPlaceholder("LLM_API_KEY tanimli degil.");

    return jsonResponse(llmOutput);
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

function buildPrompt(product: unknown, ruleResult: unknown, profile: ProfileSchema) {
  // Profil özetini okunabilir hale getir
  const profileSummary = [
    profile.allergies.length > 0
      ? `Alerjiler: ${profile.allergies.join(", ")}`
      : "Bilinen alerji yok",
    profile.diet !== "standard"
      ? `Diyet: ${profile.diet}`
      : "Standart diyet",
    profile.goals.length > 0
      ? `Saglik hedefleri: ${profile.goals.join(", ")}`
      : "",
    profile.avoid.length > 0
      ? `Kacinilacaklar: ${profile.avoid.join(", ")}`
      : "",
  ]
    .filter(Boolean)
    .join(" | ");

  return `
Asagidaki urun verisini ve kullanici profilini kullanarak sade bir aciklama ve kisisel uyari uret.

Kurallar (guardrail):
- Alerjen kararini DEGISTIRME — rule_engine_result zaten hesaplanmis, sen sadece sade dile cevir.
- Veri eksikse uydurma; "bu bilgi mevcut degil" de.
- Tibbi teshis/tedavi onerme; her yanita "bu bilgi tibbi tavsiye degildir" notu ekle.
- Ciktiyi belirtilen JSON semasinda ver: { summary, personal_warning: { level, message }, diet_note, disclaimer }
- level yalnizca "ok" | "caution" | "warning" olabilir.
- personal_warning.message icinde urundeki alerjen ve saglik risklerini acikca belirt.
- Eger profil bossa, yalnizca urun bilgisine dayanarak genel aciklama yap.
- "avoid" listesindeki icerikleri urunde varsa "caution" veya "warning" olarak isaretle.
- "goals" listesindeki hedeflere gore diyet notunu (diet_note) ozelleştir.

Urun: ${JSON.stringify(product, null, 2)}
Kural motoru sonucu: ${JSON.stringify(ruleResult, null, 2)}
Kullanici profili (normalize edilmis): ${profileSummary}
Profil JSON: ${JSON.stringify(profile, null, 2)}
  `.trim();
}

async function callLlm(prompt: string, apiKey: string) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      temperature: 0.2,
      messages: [
        {
          role: "system",
          content:
            "Sen bir ürün açıklama asistanısın. Alerjen ve diyet kararlarını değiştirme; sadece mevcut veriyi sade bir şekilde sun."
        },
        {
          role: "user",
          content: prompt,
        },
      ],
      max_tokens: 700,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("LLM çağrısı başarısız oldu:", response.status, errorText);
    return callLlmPlaceholder("LLM API çağrısı başarısız oldu.");
  }

  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;
  if (typeof content !== "string") {
    console.error("LLM geçersiz içerik döndü", payload);
    return callLlmPlaceholder("LLM geçersiz içerik döndürdü.");
  }

  const parsed = parseLlmJson(content);
  return validateLlmResponse(parsed);
}

function parseLlmJson(content: string) {
  try {
    return JSON.parse(content);
  } catch {
    const jsonMatch = content.match(/\{[\s\S]*\}/m);
    if (jsonMatch) {
      try {
        return JSON.parse(jsonMatch[0]);
      } catch {
        return null;
      }
    }
    return null;
  }
}

function validateLlmResponse(value: any) {
  if (!value || typeof value !== "object") {
    return callLlmPlaceholder("LLM geçerli JSON döndürmedi.");
  }

  const summary = typeof value.summary === "string" ? value.summary.trim() : null;
  const personalWarning = value.personal_warning;
  const level = personalWarning?.level;
  const message = typeof personalWarning?.message === "string" ? personalWarning.message.trim() : null;
  const dietNote = value.diet_note ?? null;
  const disclaimer = typeof value.disclaimer === "string" ? value.disclaimer.trim() : null;

  const allowedLevels = new Set(["ok", "caution", "warning"]);
  const normalizedLevel = allowedLevels.has(level) ? level : "caution";

  if (!summary || !message || !disclaimer) {
    console.error("LLM yanıtı eksik alan içeriyor", { summary, message, disclaimer });
    return callLlmPlaceholder("LLM yanıtı eksik alan içeriyor.");
  }

  return {
    summary,
    personal_warning: {
      level: normalizedLevel,
      message,
    },
    diet_note: dietNote,
    disclaimer,
  };
}

function callLlmPlaceholder(reason: string) {
  console.warn("LLM placeholder döndü:", reason);
  return {
    summary: "Ürün açıklaması henüz LLM entegrasyonu tamamlanmadığı için mevcut değil.",
    personal_warning: {
      level: "ok",
      message: "Alerjen veya diyet uyarısı şu an placeholder olarak gösteriliyor.",
    },
    diet_note: null,
    disclaimer: "Bu bilgi tıbbi tavsiye niteliği taşımaz.",
  };
}


