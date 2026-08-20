# Sağlık Durumu Bilgi Kartı İçeriği ve Yönlendirme Rehberi

Bu doküman, **Akıllı Sepet** uygulamasında kural motorunun (rule engine) otomatik/deterministik olarak karara bağlayamadığı **özel sağlık durumları ve hassasiyetler** için mobil UI bilgi kartlarının metin içeriklerini, yönlendirme ilkelerini ve guardrail kurallarını tanımlar.

---

## 1. Temel İlke ve Sorumluluk Reddi (Guardrail)

1. **Kesin Karar Verilmez**: Kural motoru veya AI, özel/karmaşık sağlık durumlarında "Bu ürün senin için %100 güvenlidir" veya "Kesinlikle yasaktır" şeklinde tıbbi bir hüküm **veremez**.
2. **Doktor Yönlendirmesi Zorunludur**: Otomatik eşleşme yapılamayan her durumda kartın altında belirgin şekilde **"Hassas bir sağlık durumunuz olduğu için tüketim öncesinde mutlaka doktorunuza veya diyetisyeninize danışınız."** uyarısı yer alır.
3. **Şeffaflık**: Kullanıcıya verinin neden kural motoru tarafından tam işlenemediği açıkça bildirilir (örn: ambalajda spesifik miktar belirtilmemesi veya klinik durumun kişiye özel değişkenlik göstermesi).

---

## 2. Kural Motorunun Tanımadığı Özel Durumlar & Kart Metin Şablonları

### A. Hamilelik & Emzirme Dönemi (`pregnant_lactating`)
- **Neden Otomatik Karar Verilemiyor?**: Kafein, bazı bitki çayları, tatlandırıcılar (aspartam vb.) ve işlenmiş et ürünlerindeki (nitrat) güvenli sınırlar kişiden kişiye ve hamilelik haftasına göre değişir.
- **Bilgi Kartı Başlığı**: 🤰 Hamilelik & Emzirme Hassasiyeti
- **Kart Metni**:
  > "Bu ürün kafein, bitki özleri veya yapay tatlandırıcılar içerebilir. Hamilelik ve emzirme döneminde bu bileşenlerin günlük tüketim miktarı kişisel sağlık geçmişinize göre belirlenmelidir."
- **Mobil UI Aksiyon Notu**: 🩺 *Doktorunuza Danışın: Lütfen bu ürünü doktorunuzun veya kadın doğum uzmanınızın onayladığı beslenme listesine göre değerlendiriniz.*

---

### B. Çölyak Dışı Glüten Hassasiyeti (`non_celiac_gluten_sensitivity`)
- **Neden Otomatik Karar Verilemiyor?**: Çölyak hastalarında eser miktarda dahi glüten yasakken, çölyak dışı hassasiyette tolere edilebilir eşik kişiseldir. Etiketlerde sadece "glüten içerir" bilgisi yer alır.
- **Bilgi Kartı Başlığı**: 🌾 Glüten Hassasiyeti Bilgilendirmesi
- **Kart Metni**:
  > "Üründe glüten içeren tahıllar yer almaktadır. Çölyak dışı hassasiyetiniz varsa, tolere edebileceğiniz miktar ve semptom geçmişiniz belirleyicidir."
- **Mobil UI Aksiyon Notu**: 🩺 *Uzman Notu: Bireysel tolere etme düzeyiniz için diyetisyeninizle görüşmeniz önerilir.*

---

### C. Hipertansiyon & Böbrek Rahatsızlıkları (`hypertension_renal`)
- **Neden Otomatik Karar Verilemiyor?**: Ürün etiketinde sodyum/tuz miktarı yazsa dahi, kullanıcının günlük toplam potasyum/sodyum kısıtlaması tıbbi reçeteye bağlıdır.
- **Bilgi Kartı Başlığı**: 🧂 Sodyum & Mineral Düzeyi Uyarısı
- **Kart Metni**:
  > "Bu ürün sodyum (tuz) veya potasyum mineralleri içermektedir. Hipertansiyon veya böbrek sağlığı takibinde günlük toplam mineral alımınız kritik önem taşır."
- **Mobil UI Aksiyon Notu**: 🩺 *Doktorunuza Danışın: Günlük sodyum/potasyum limitiniz dahilinde olup olmadığını doktorunuza danışınız.*

---

### D. İritabl Bağırsak Sendromu / IBS & FODMAP (`ibs_fodmap`)
- **Neden Otomatik Karar Verilemiyor?**: FODMAP bileşenleri (fruktoz, laktoz, polioller) Open Food Facts veritabanında tekil FODMAP skoru olarak etiketlenmemiştir.
- **Bilgi Kartı Başlığı**: 🍎 Sindirim Hassasiyeti (FODMAP / IBS)
- **Kart Metni**:
  > "Ürün yüksek fruktoz, baklagiller veya polioller (tatlandırıcılar) içerebilir. IBS / FODMAP hassasiyetinde eliminasyon aşamanıza göre reaksiyon değişebilir."
- **Mobil UI Aksiyon Notu**: 🩺 *Diyetisyeninize Danışın: Şu anki eliminasyon veya yeniden ekleme fazınıza uygunluğunu kontrol ediniz.*

---

### E. Özel Kronik İlaç Etkileşimleri (`medication_interaction`)
- **Neden Otomatik Karar Verilemiyor?**: Bazı gıdalar (örn: greyfurt, K vitamini içeren koyu yeşillikler, tiramin içeren olgunlaşmış peynirler) belirli ilaçlarla (kan sulandırıcı, MAO inhibitörleri) etkileşime girer.
- **Bilgi Kartı Başlığı**: 💊 İlaç - Gıda Etkileşimi Uyarısı
- **Kart Metni**:
  > "Düzenli kullandığınız kronik bir ilaç varsa, bazı besin bileşenleri ilacın emilimini veya etkisini değiştirebilir. Sistemimiz ilaç reçetenizi takip edemez."
- **Mobil UI Aksiyon Notu**: 🩺 *Eczacınıza/Doktorunuza Danışın: Kullandığınız ilacın prospektüsünü inceleyiniz veya doktorunuza danışınız.*

---

## 3. Mobil UI Bilgi Kartı Bileşen Yapısı (Design Spec)

Mobil uygulamada özel durum karta dönüştüğünde aşağıdaki yapısal elemanlar gösterilir:

```
+-------------------------------------------------------------+
|  ℹ️ SAĞLIK DURUMU BİLGİ KARTI                              |
|  [Özel Durum Başlığı]                                       |
|                                                             |
|  "Genel bilgilendirme metni..."                            |
|                                                             |
|  ---------------------------------------------------------  |
|  🩺 DOKTORUNUZA DANIŞIN                                      |
|  "Bu içerik tıbbi karar teşkil etmez. Kişisel sağlık        |
|   durumunuz için lütfen doktorunuza başvurunuz."            |
+-------------------------------------------------------------+
```

- **Kart Rengi**: Nötr Mavi / Kehribar Sarı (Risk uyarısından ayırt edilmesi için Kırmızı yerine bilgi rengi kullanılır).
- **Rozet**: `Kural Motoru Dışı - Bilgilendirme`
