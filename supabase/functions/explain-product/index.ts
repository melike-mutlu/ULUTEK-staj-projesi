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

import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

/** Swappable via Supabase secret; gpt-4o family is being retired. */
const DEFAULT_MODEL = "gpt-4o-mini";

type Level = "ok" | "caution" | "warning";
const SEVERITY: Level[] = ["ok", "caution", "warning"];

/**
 * The deterministic floor: the rule engine owns the verdict, so the shown level
 * can never be below this. A confirmed conflict/allergen match forces warning.
 */
export function ruleFloorLevel(ruleResult: unknown): Level {
  const r = (ruleResult ?? {}) as {
    has_conflict?: boolean;
    matched_allergens?: unknown[];
  };
  const matched = Array.isArray(r.matched_allergens) &&
    r.matched_allergens.length > 0;
  return r.has_conflict === true || matched ? "warning" : "ok";
}

/** LLM may raise severity, never lower it below the rule engine floor. */
export function clampToFloor(llmLevel: unknown, floor: Level): Level {
  const llm = SEVERITY.includes(llmLevel as Level) ? llmLevel as Level : floor;
  return SEVERITY.indexOf(llm) >= SEVERITY.indexOf(floor) ? llm : floor;
}

async function handleRequest(req: Request): Promise<Response> {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const { product, rule_engine_result, user_profile } = await req.json();

    // Insufficient allergen data: the rule engine already says "yetersiz veri".
    // Never ask the LLM for a verdict here — return the neutral state directly.
    if (rule_engine_result?.data_sufficiency === "insufficient") {
      return jsonResponse(insufficientResponse());
    }

    const floor = ruleFloorLevel(rule_engine_result);

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
    const model = Deno.env.get("LLM_MODEL") ?? DEFAULT_MODEL;
    const llmOutput = apiKey
      ? await callLlm(prompt, apiKey, model, floor)
      : callLlmPlaceholder("LLM_API_KEY tanimli degil.", floor);

    return jsonResponse(llmOutput);
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
}

// Only serve when run as the entrypoint, so tests can import the pure helpers.
if (import.meta.main) {
  Deno.serve(handleRequest);
}

function buildPrompt(product: unknown, ruleResult: unknown, profile: ProfileSchema) {
  // Profil özetini okunabilir hale getir
  const profileSummary = [
    profile.allergies.length > 0
      ? `Alerjiler: ${profile.allergies.join(", ")}`
      : "Bilinen alerji yok",
    profile.diets.length > 0
      ? `Diyet: ${profile.diets.join(", ")}`
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

async function callLlm(
  prompt: string,
  apiKey: string,
  model: string,
  floor: Level,
) {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
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
    return callLlmPlaceholder("LLM API çağrısı başarısız oldu.", floor);
  }

  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;
  if (typeof content !== "string") {
    console.error("LLM geçersiz içerik döndü", payload);
    return callLlmPlaceholder("LLM geçersiz içerik döndürdü.", floor);
  }

  const parsed = parseLlmJson(content);
  return validateLlmResponse(parsed, floor);
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

export function validateLlmResponse(value: unknown, floor: Level) {
  if (!value || typeof value !== "object") {
    return callLlmPlaceholder("LLM geçerli JSON döndürmedi.", floor);
  }

  const v = value as Record<string, unknown>;
  const personalWarning = (v.personal_warning ?? {}) as Record<string, unknown>;
  const summary = typeof v.summary === "string" ? v.summary.trim() : null;
  const message = typeof personalWarning.message === "string"
    ? personalWarning.message.trim()
    : null;
  const dietNote = v.diet_note ?? null;
  const disclaimer = typeof v.disclaimer === "string" ? v.disclaimer.trim() : null;

  if (!summary || !message || !disclaimer) {
    console.error("LLM yanıtı eksik alan içeriyor", { summary, message, disclaimer });
    return callLlmPlaceholder("LLM yanıtı eksik alan içeriyor.", floor);
  }

  return {
    summary,
    personal_warning: {
      // The rule engine floor wins; the LLM can only raise severity.
      level: clampToFloor(personalWarning.level, floor),
      message,
    },
    diet_note: dietNote,
    disclaimer,
  };
}

/**
 * Neutral fallback when the LLM is unavailable. Never asserts safety on its own:
 * the level is the rule engine's verdict, not a hardcoded "ok".
 */
export function callLlmPlaceholder(reason: string, floor: Level) {
  console.warn("LLM placeholder döndü:", reason);
  return {
    summary: "Ürün açıklaması şu an oluşturulamadı.",
    personal_warning: {
      level: floor,
      message: floor === "warning"
        ? "Bu üründe profilinle çakışan içerik var; ayrıntılar aşağıda."
        : "Açıklama şu an oluşturulamadı; ürün bilgileri aşağıda.",
    },
    diet_note: null,
    disclaimer: "Bu bilgi tıbbi tavsiye niteliği taşımaz.",
  };
}

/** data_sufficiency=insufficient: no verdict, no safety claim. */
function insufficientResponse() {
  return {
    summary: "Bu ürünün içerik bilgisi eksik.",
    personal_warning: {
      level: "caution",
      message: "İçerik bilgisi eksik olduğu için değerlendirme yapılamadı.",
    },
    diet_note: null,
    disclaimer: "Bu bilgi tıbbi tavsiye niteliği taşımaz.",
  };
}


