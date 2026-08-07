// Akıllı Sepet — chat Edge Function
// Kimlik doğrulama: sadece giriş yapmış kullanıcılar erişebilir.
import { getUserClient, getServiceClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";
import { CHATBOT_SYSTEM_PROMPT } from "../_shared/system_prompt.ts";
import { saveMessage } from "../_shared/chatHistory.ts";

// v1: kullanıcı mesajı + sistem promptu -> düz metin cevap.
// Kullanıcı ve asistan mesajları chat_history tablosuna kaydediliyor.
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    const userClient = getUserClient(req);
    const { data: { user }, error } = await userClient.auth.getUser();

    if (error || !user) {
      return jsonResponse({ status: "error", message: "Kimlik doğrulanamadı" }, 401);
    }

    const serviceClient = getServiceClient();

    const { user_message, session_id } = await req.json();
    if (typeof user_message !== "string" || user_message.trim().length === 0) {
      return jsonResponse({ status: "error", message: "user_message zorunludur" }, 400);
    }

    // session_id istekte yoksa yeni bir oturum başlat.
    const sessionId = typeof session_id === "string" && session_id.length > 0
      ? session_id
      : crypto.randomUUID();

    // 1) Kullanıcı mesajını kaydet
    await saveMessage(serviceClient, user.id, sessionId, user_message.trim(), "user");

    const apiKey = Deno.env.get("LLM_API_KEY");
    const reply = apiKey
      ? await callChatbotLlm(user_message.trim(), apiKey)
      : "Şu an yapay zeka asistanı yapılandırılmamış (LLM_API_KEY eksik). Lütfen daha sonra tekrar dene.";

    // 2) Asistan cevabını kaydet
    await saveMessage(serviceClient, user.id, sessionId, reply, "assistant");

    return jsonResponse({ reply, session_id: sessionId });
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