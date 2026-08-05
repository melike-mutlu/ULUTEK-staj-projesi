# Akıllı Sepet — Demo Hazırlık Dokümanı

*Bu doküman, projeye tekrar hâkim olabilmen ve yarınki demoda sorulabilecek sorulara hazırlıklı olman için hazırlandı.*

---

## 1. Proje Nedir, Neden Yapıyoruz?

**Akıllı Sepet**, market alışverişi sırasında bir ürünün barkodunu okutarak, o ürünün **kullanıcının kendi profiline göre** (alerjileri, diyet tercihi, sağlık durumu) uygun olup olmadığını saniyeler içinde gösteren bir mobil uygulama.

**Çözdüğümüz problem:** Market etiketleri uzun ve teknik. Özellikle alerjisi, diyeti veya sağlık hassasiyeti olan biri için "bu ürünü yiyebilir miyim?" sorusuna cevap bulmak zaman alıyor ve hataya açık.

**Farklılaştığımız nokta:** Herkese aynı sonucu vermiyoruz. Aynı ürün, fındık alerjisi olan biri için "kırmızı/riskli", başka biri için "yeşil/uygun" çıkabilir.

**AI'ın rolü (çok sorulan bir nokta — net olmak önemli):** AI, ürünün güvenli olup olmadığına **karar vermiyor**. Karar tamamen kural motorundan (rule engine) geliyor — alerjen eşleştirmesi, diyet uyumu gibi somut kurallara dayanıyor. AI sadece bu kararı **sade, anlaşılır bir dile çeviriyor**. Bu bilinçli bir tasarım kararı: AI'ın "halüsinasyon görüp" yanlış bir sağlık kararı vermesini engelliyor. Backend'deki prompt'ta bile açıkça "Alerjen kararını DEĞİŞTİRME, sadece sade dile çevir" diye yazıyor.

---

## 2. Ekip ve Roller

| Kişi | Pod | Sorumluluk |
|---|---|---|
| **Sen (Melike Mutlu)** | PM/Lead | Koordinasyon, mimari, tüm PR'ları merge etme |
| Melike Çolak | Mobil | Tema/navigasyon, onboarding, profil ekranı, StartupGate |
| Ahmet Gölcük | Mobil | Ürün detay ekranı, pending product (eksik ürün bildirme) |
| İbrahim Alptekin | Mobil | Barkod okuma, tarama geçmişi, ana sayfa/chatbot sekme düzeni |
| Eda | Backend | Supabase kurulumu, auth (email/şifre + misafir girişi) |
| Zeynep Ulutek | Backend | Veritabanı tabloları, Open Food Facts entegrasyonu, kural motoru |
| Ranim Ulutek | Backend | Backend klasör yapısı, pending product backend'i, Storage bucket |
| Melike Dal | Backend | Servis katmanı birleştirme, chat_history tablosu |
| Sevde Betül Karakaş | AI | Profil oluşturma konuşma tasarımı, system prompt |
| Suhail Khaleqi | AI | JSON şeması, profil parser, ürün açıklama LLM entegrasyonu |

> Not: Ekipte 3 farklı "Melike" var (Mutlu/Çolak/Dal) — biri sensin, ikisi farklı kişiler. Kafan karışırsa bunu hatırla.

---

## 3. Teknik Mimari (Neden Bu Seçimler?)

- **Flutter** (mobil uygulama): Tek kod tabanıyla Android/iOS/Web hepsine derlenebiliyor, staj süresi için hız kazandırıyor.
- **Supabase** (backend): Postgres veritabanı + kullanıcı girişi (Auth) + dosya depolama (Storage) + sunucu fonksiyonları (Edge Functions) hepsi tek serviste hazır geliyor — sıfırdan backend kurmaya gerek kalmadı.
- **Open Food Facts**: Ücretsiz, açık kaynaklı bir ürün veritabanı. Barkod girip ürün bilgisi (içerik, alerjen, besin değeri) çekiyoruz.
- **OpenAI (gpt-4o-mini)**: Ürün verisini + kural motoru sonucunu alıp kullanıcıya sade bir açıklama üretiyor.

**Mimari desen:** MVVM + Repository. Her ekranın bir `View` (arayüz) + `ViewModel` (mantık/state) dosyası var; veriye erişim `Repository` sınıfları üzerinden, doğrudan Supabase çağrısı View'larda yapılmıyor. Böylece test edilebilir ve bakımı kolay.

---

## 4. Uygulama Akışı (Baştan Sona)

1. **Açılış (`StartupGate`)** — kullanıcının oturumu var mı, profili var mı diye bakıp otomatik yönlendiriyor: oturum yoksa **Giriş/Kayıt**'a, oturum var ama profil yoksa **Onboarding**'e, ikisi de varsa direkt **Ana Sayfa**'ya.
2. **Giriş/Kayıt** — e-posta/şifre ile ya da "Misafir Olarak Devam Et" ile.
3. **Onboarding** — alerjiler, diyet tercihi (çoklu seçim: vegan/vejetaryen/diyabet dostu/sporcu), sağlık durumları soruluyor.
4. **Ana Sayfa** — karşılama, profil fotoğrafı/ad, son taramalar, büyük "Tara" butonu.
5. **Barkod Tara** — kamera açılıyor, barkodu okuyor (EAN13/EAN8). Karede birden fazla barkod varsa (örn. rafta yan yana iki ürün) **hiçbirini işlemiyor**, kullanıcı tek ürünü hizalayana kadar bekliyor — bu, yanlış ürün gösterme riskini azaltmak için bugün eklediğimiz bir güvenlik önlemi.
6. **Backend (`fetch-product`)** — barkodu önce kendi önbelleğimizde (cache) arıyor, yoksa Open Food Facts'ten çekip kaydediyor. Sonra kullanıcının profiliyle karşılaştırıp kural motorunu çalıştırıyor.
7. **Kural Motoru** — alerjen eşleşmesi var mı, ürün vegan mı (kullanıcı vegansa), şeker oranı diyabet için nasıl, protein oranı sporcu için yeterli mi — hepsini hesaplayıp kırmızı/sarı/yeşil bir sonuç üretiyor.
8. **Ürün Detay Ekranı** — gerçek ürün bilgisi + AI'ın ürettiği sade açıklama + renkli uyarı bandı gösteriliyor. Ürün topluluk tarafından eklenmiş ve onaylanmamışsa **"Doğrulanmadı"** rozeti çıkıyor ve asla "güvenli" denmiyor.
9. **Ürün Bulunamazsa** — kullanıcı fotoğraf çekip "bu ürünü bildir" diyebiliyor, bu bilgi bekleyen ürünler listesine düşüyor (manuel onay Supabase üzerinden yapılıyor, ayrı bir admin ekranı yok — bilinçli bir MVP kararı, gerek yoktu).
10. **Profil Sekmesi** — alerji/diyet/sağlık bilgilerini sonradan düzenleyebiliyor, ad ve profil fotoğrafı ekleyebiliyor.
11. **Chatbot Sekmesi** — *(bkz. Bölüm 6, hâlâ yer tutucu)*.

---

## 5. Bugüne Kadar Neler Tamamlandı (Özet Kronoloji)

- **1. gün:** Proje iskeleti, tema/navigasyon, barkod okuma altyapısı, Supabase projesi + veritabanı tabloları, Open Food Facts ilk test, AI JSON şeması tasarımı.
- **2. gün:** Barkod→API bağlantısı, onboarding ekranları, OFF entegrasyonu (gerçek ürün çekme), pending product sistemi, ürün detay ekranı, auth/profil altyapısı, AI prompt + JSON parser.
- **Sonraki günler:** Gerçek auth (e-posta/şifre + misafir), ürün detay ekranının gerçek veriye bağlanması, kural motorunun genişletilmesi (vegan/diyabet/sporcu), backend servis katmanının birleştirilmesi (kod tekrarını azaltma), profil düzenleme (ad + fotoğraf yükleme), ana sayfanın gerçek verilerle (isim, son taramalar) doldurulması, "Geçmiş" sekmesinin kaldırılıp yerine **Chatbot** sekmesinin eklenmesi, "Doğrulanmadı" rozeti, barkod tarama güvenlik düzeltmesi (çoklu barkod algılama), isimlendirme temizliği (ekran sınıf adları artık gösterdikleri sekmeyle uyumlu).

**Genel değerlendirme:** Çekirdek akış (kayıt/giriş → profil → barkod tara → kişiselleştirilmiş sonuç) uçtan uca gerçekten çalışıyor durumda, mock/sahte veri değil.

---

## 6. Dürüst Olmamız Gereken Eksikler (Demo'da Sorulursa)

- **Chatbot sekmesi henüz gerçek bir sohbet arayüzü değil** — şu an "yakında eklenecek" yazan bir yer tutucu. Backend tarafında sadece kimlik doğrulama iskeleti var, asıl AI konuşma mantığı henüz yazılmadı. *Eğer sorulursa: "Bu, gelecek sürüm için planladığımız, temelini attığımız bir özellik" demek en doğrusu.*
- **Ürün onay süreci tam otomatik değil** — kullanıcı eksik ürün bildirdiğinde, onay manuel olarak Supabase panelinden yapılıyor, uygulama içinde ayrı bir admin ekranı yok. Bu, kapsamı gereksiz büyütmemek için bilinçli bir tercih.
- **LLM_API_KEY'in backend'e eklenip eklenmediğini demo öncesi mutlaka teyit et** — eklenmemişse AI açıklaması yerine placeholder bir metin çıkar (uygulama çökmez ama demo'da fark edilir).

---

## 7. Demo Sırasında Sorulabilecek Sorular ve Önerilen Cevaplar

**"Neden Flutter/Supabase seçtiniz?"**
→ Tek kod tabanıyla çoklu platform (Flutter), backend'i sıfırdan kurmak yerine hazır servisleri (Supabase) kullanarak 4 haftalık süreye sığdırdık.

**"AI ürüne kendisi mi karar veriyor?"**
→ Hayır, karar tamamen kural motorundan geliyor (alerjen/diyet eşleştirmesi). AI sadece bu kararı sade dille anlatıyor, kararı değiştirmiyor. Bunu bilinçli yaptık çünkü sağlıkla ilgili kararı bir dil modeline bırakmak riskli.

**"Yanlış ürün/bilgi gösterirse ne olur?"**
→ Veri kaynağımız Open Food Facts (açık kaynak) olduğu için veri kalitesi bazen eksik olabilir. Topluluk tarafından eklenen doğrulanmamış ürünlerde bunu açıkça "Doğrulanmadı" rozetiyle belirtiyoruz ve asla "kesin güvenli" demiyoruz. Ayrıca her ekranda "bu bilgi tıbbi tavsiye değildir" notu var.

**"Kullanıcı verileri güvende mi?"**
→ Her tabloda Row Level Security (RLS) var — kullanıcı sadece kendi profiline, kendi tarama geçmişine erişebiliyor, başkasının verisini göremiyor.

**"Chatbot ne durumda?"**
→ Dürüstçe: temel altyapı (kimlik doğrulama) hazır, sohbet mantığı önümüzdeki sprintte tamamlanacak.

**"En büyük zorluk neydi?"**
→ 10 kişilik bir ekipte git/PR süreçlerini oturtmak, ve veritabanı şemasıyla kodun senkron kalmasını sağlamak (birkaç kez veritabanında elle yapılan değişiklikler koda yansıtılmayı unutuldu, bunları tespit edip düzelttik).

---

## 8. Önerilen Demo Akışı

1. Kayıt ol / giriş yap (ya da hazır bir hesapla giriş yap, zaman kazan).
2. Onboarding'i hızlıca göster (alerji/diyet seç).
3. Ana Sayfa'yı göster (karşılama, son taramalar).
4. **Önceden belirlenmiş 2-3 barkodla** tara: biri profildeki alerjenle çakışan (kırmızı sonuç), biri tamamen uygun (yeşil sonuç) — kişiselleştirmenin gerçekten çalıştığını göstermek için aynı ürünü **farklı bir profille** de deneyebilirsin.
5. Bulunamayan bir ürünü tara, "bize bildir" akışını göster.
6. Profil sekmesinden bir bilgiyi değiştir, kaydet.
7. Chatbot sekmesini kısaca göster, dürüstçe "gelecek özellik" de.

**Önemli:** Demo öncesi gerçekten var olan, Open Food Facts'te kayıtlı 2-3 barkodu önceden test et ki demo sırasında sürpriz yaşama.
