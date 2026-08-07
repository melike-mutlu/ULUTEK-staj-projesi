// Akıllı Sepet — chat Edge Function
// Kimlik doğrulama: sadece giriş yapmış kullanıcılar erişebilir.
import { getUserClient, getServiceClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";
import { buildSystemPromptWithProfile } from "../_shared/system_prompt.ts";
import { saveMessage, getConversationHistory, type ChatMessage } from "../_shared/chatHistory.ts";
import { getUserHealthProfile } from "../_shared/userProfile.service.ts";

// v2: kullanıcı mesajı + sohbet geçmişi + kullanıcı profili -> kişiselleştirilmiş cevap.
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

    // 1) Kullanıcı profilini çek (alerji, diyet, sağlık durumu)
    const healthProfile = await getUserHealthProfile(serviceClient, user.id);

    // 2) Önceki sohbet geçmişini çek (aynı oturumdan)
    const history = await getConversationHistory(serviceClient, user.id, sessionId);

    // 3) Kullanıcı mesajını kaydet
    await saveMessage(serviceClient, user.id, sessionId, user_message.trim(), "user");

    // 4) Profil bilgisiyle zenginleştirilmiş sistem promptu oluştur
    const systemPrompt = buildSystemPromptWithProfile({
      allergies: healthProfile.allergies,
      diet_preference: healthProfile.dietPreference.join(", "),
      health_conditions: healthProfile.healthConditions,
    });

    const apiKey = Deno.env.get("LLM_API_KEY");
    const reply = apiKey
      ? await callChatbotGemini(user_message.trim(), history, systemPrompt, apiKey)
      : "Şu an yapay zeka asistanı yapılandırılmamış (LLM_API_KEY eksik). Lütfen daha sonra tekrar dene.";

    // 5) Asistan cevabını kaydet
    await saveMessage(serviceClient, user.id, sessionId, reply, "assistant");

    return jsonResponse({ reply, session_id: sessionId });
  } catch (error) {
    console.error("Chatbot hatası:", error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
});

async function callChatbotGemini(
  userMessage: string,
  history: ChatMessage[],
  systemPrompt: string,
  apiKey: string,
): Promise<string> {
  const model = "gemini-2.0-flash"; 

  // Geçmiş mesajları Gemini formatına çevir.
  // Gemini'de rol adı "assistant" değil "model" olmalı.
  const historyContents = history
    .filter((m) => m.role === "user" || m.role === "assistant")
    .map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.message }],
    }));

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ text: systemPrompt }],
        },
        contents: [
          ...historyContents,
          { role: "user", parts: [{ text: userMessage }] },
        ],
        generationConfig: {
          temperature: 0.4,
          maxOutputTokens: 500,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Gemini API çağrısı başarısız oldu:", response.status, errorText);
    return "Şu an cevap veremiyorum, lütfen birazdan tekrar dene.";
  }

  const payload = await response.json();
  const content = payload?.candidates?.[0]?.content?.parts?.[0]?.text;

  if (typeof content !== "string" || content.trim().length === 0) {
    console.error("Gemini geçersiz içerik döndü:", payload);
    return "Şu an cevap veremiyorum, lütfen birazdan tekrar dene.";
  }

  return content.trim();
} 