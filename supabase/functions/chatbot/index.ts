// Akıllı Sepet — chat Edge Function
// Kimlik doğrulama: sadece giriş yapmış kullanıcılar erişebilir.
import { getUserClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";
import { CHATBOT_SYSTEM_PROMPT } from "../_shared/system_prompt.ts";

// v1: sadece kullanıcı mesajı + sistem promptu -> düz metin cevap.
// v2 (planlanan): conversation_history (chat_history tablosundan) ve
// current_profile (allergies/diet_preference/health_conditions) eklenip
// buildSystemPromptWithProfile() ile kişiselleştirilecek, cevap da
// { reply, profile_update } şemasına genişleyecek.
Deno.serve(async (req) => {
  // CORS Preflight istekleri için
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const userClient = getUserClient(req);
    const { data: { user }, error } = await userClient.auth.getUser();

    if (error || !user) {
      return jsonResponse({ status: "error", message: "Kimlik doğrulanamadı" }, 401);
    }

    const { user_message } = await req.json();
    if (typeof user_message !== "string" || user_message.trim().length === 0) {
      return jsonResponse({ status: "error", message: "user_message zorunludur" }, 400);
    }

    const apiKey = Deno.env.get("LLM_API_KEY");
    const reply = apiKey
      ? await callChatbotLlm(user_message.trim(), apiKey)
      : "Şu an yapay zeka asistanı yapılandırılmamış (LLM_API_KEY eksik). Lütfen daha sonra tekrar dene.";

    return jsonResponse({ reply });
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

async function callChatbotLlm(userMessage: string, apiKey: string): Promise<string> {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      temperature: 0.4,
      messages: [
        { role: "system", content: CHATBOT_SYSTEM_PROMPT },
        { role: "user", content: userMessage },
      ],
      max_tokens: 500,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Chatbot LLM çağrısı başarısız oldu:", response.status, errorText);
    return "Şu an cevap veremiyorum, lütfen birazdan tekrar dene.";
  }

  const payload = await response.json();
  const content = payload?.choices?.[0]?.message?.content;
  if (typeof content !== "string" || content.trim().length === 0) {
    console.error("Chatbot LLM geçersiz içerik döndü", payload);
    return "Şu an cevap veremiyorum, lütfen birazdan tekrar dene.";
  }

  return content.trim();
}
