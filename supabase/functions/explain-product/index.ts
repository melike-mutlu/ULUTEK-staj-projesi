// Akıllı Sepet — explain-product Edge Function
// docs/architecture.md — Sözleşme 2: Mobil -> AI
//
// Girdi:  { product, rule_engine_result, user_profile }
// Çıktı:  { summary, personal_warning: { level, message }, diet_note, disclaimer }
//
// TODO (AI/LLM pod): callLlmPlaceholder() yerine gerçek LLM sağlayıcı çağrısı eklenecek.
// API anahtarı yalnızca burada (sunucu tarafında), env variable olarak durur — istemciye asla geçmez.

import { jsonResponse } from "../../services/shared/http.ts";
Deno.serve(async (req) => {
  try {
    const { product, rule_engine_result, user_profile } = await req.json();

    const prompt = buildPrompt(product, rule_engine_result, user_profile);

    // const apiKey = Deno.env.get("LLM_API_KEY");
    // const llmOutput = await callLlm(prompt, apiKey);
    const llmOutput = await callLlmPlaceholder(prompt);

    return jsonResponse(llmOutput);
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

function buildPrompt(product: unknown, ruleResult: unknown, profile: unknown) {
  return `
Aşağıdaki ürün verisini ve kullanıcı profilini kullanarak sade bir açıklama ve kişisel uyarı üret.

Kurallar (guardrail):
- Alerjen kararını DEĞİŞTİRME — rule_engine_result zaten hesaplanmış, sen sadece sade dile çevir.
- Veri eksikse uydurma; "bu bilgi mevcut değil" de.
- Tıbbi teşhis/tedavi önerme; her yanıta "tıbbi tavsiye değildir" notu ekle.
- Çıktıyı belirtilen JSON şemasında ver: { summary, personal_warning: { level, message }, diet_note, disclaimer }
- level yalnızca "ok" | "caution" | "warning" olabilir.

Ürün: ${JSON.stringify(product)}
Kural motoru sonucu: ${JSON.stringify(ruleResult)}
Kullanıcı profili: ${JSON.stringify(profile)}
  `.trim();
}

// Gerçek LLM entegrasyonu gelene kadar mobil/backend'in geliştirmeyi durdurmaması için
// sözleşmeye uygun sahte (placeholder) yanıt döner.
async function callLlmPlaceholder(_prompt: string) {
  return {
    summary: "TODO: LLM entegrasyonu eklenince gerçek özet buraya gelecek.",
    personal_warning: { level: "ok", message: "TODO" },
    diet_note: null,
    disclaimer: "Bu bilgi tıbbi tavsiye niteliği taşımaz.",
  };
}


