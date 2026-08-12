// Akıllı Sepet — delete-account Edge Function
// Kullanıcı "hesabımı sil" dediğinde çağrılır.
// Kullanıcı silme işlemi service_role yetkisi gerektirir, bu yüzden
// mobil tarafta değil, burada (sunucu tarafında) yapılır.
//
// Girdi:  (body gerekmez, sadece Authorization header'daki JWT ile kullanıcı belirlenir)
// Çıktı:  { status: "success" } | { status: "error", message }

import { getUserClient, getServiceClient } from "../_shared/lib/supabaseClient.ts";
import { jsonResponse, handleCorsPreflight } from "../_shared/http.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return handleCorsPreflight();
  }

  try {
    // 1) Kullanıcının JWT'sini kontrol et — sadece kendi hesabını silebilir.
    const userClient = getUserClient(req);
    const { data: { user }, error } = await userClient.auth.getUser();

    if (error || !user) {
      return jsonResponse({ status: "error", message: "Kimlik doğrulanamadı" }, 401);
    }

    const serviceClient = getServiceClient();
    const userId = user.id;

    // 2) İlişkili verileri temizle.
    // profiles, chat_history, pending_products, scan_history tabloları
    // auth.users'a "on delete cascade" ile bağlıysa bu adımlar gereksiz olabilir,
    // ama garanti olması için elle de temizliyoruz.
    const cleanupResults = await Promise.allSettled([
      serviceClient.from("chat_history").delete().eq("user_id", userId),
      serviceClient.from("pending_products").delete().eq("user_id", userId),
      serviceClient.from("scan_history").delete().eq("user_id", userId),
      serviceClient.from("profiles").delete().eq("user_id", userId),
    ]);

    const cleanupErrors = cleanupResults
      .filter((r) => r.status === "rejected")
      .map((r) => (r as PromiseRejectedResult).reason);

    if (cleanupErrors.length > 0) {
      console.error("Kullanıcı verisi temizlenirken hata oluştu:", cleanupErrors);
      // Devam ediyoruz — asıl kritik adım auth.users'tan silmek, veri
      // temizliğinde kısmi hata olsa bile kullanıcı hesabını silmeyi deneriz.
    }

    // 3) Kullanıcıyı auth.users'tan sil (service_role gerektirir).
    const { error: deleteError } = await serviceClient.auth.admin.deleteUser(userId);

    if (deleteError) {
      console.error("Kullanıcı silinirken hata oluştu:", deleteError);
      return jsonResponse(
        { status: "error", message: "Hesap silinemedi, lütfen tekrar deneyin" },
        500,
      );
    }

    return jsonResponse({ status: "success" });
  } catch (error) {
    console.error("delete-account hatası:", error);
    return jsonResponse({ status: "error", message: "beklenmeyen hata" }, 500);
  }
}); 