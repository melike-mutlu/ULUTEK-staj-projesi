// Akıllı Sepet — chat Edge Function
// Kimlik doğrulama: sadece giriş yapmış kullanıcılar erişebilir.
import { getUserClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts"; 

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
    
    // Beklenen istek formatı:
    // {
    //   "user_message": "artık şeker yemek istemiyorum",
    //   "conversation_history": [
    //     { "role": "user", "parts": "Merhaba" },
    //     { "role": "model", "parts": "Merhaba! Size nasıl yardımcı olabilirim?" }
    //   ],
    //   "current_profile": {
    //     "allergies": ["gluten"],
    //     "diet_preference": "standard",
    //     "health_conditions": ["tansiyon"]
    //   }
    // }
    //
    // Beklenen yanıt formatı:
    // {
    //   "reply": "Şeker tüketimini azaltmak harika bir karar!",
    //   "profile_update": {
    //     "has_update": true,
    //     "suggested_profile": { ... },
    //     "changes": [ { "field": "avoid", "action": "add", "value": "şeker" } ],
    //     "explanation": "Şeker kaçınılacaklar listesine eklendi."
    //   }
    // }
    //
    // user.id artık güvenli şekilde doğrulanmış durumda.

    return jsonResponse({ status: "ok", user_id: user.id });
  } catch (error) {
    console.error(error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500); 
  }
});    