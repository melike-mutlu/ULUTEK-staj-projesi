# Akıllı Sepet — Mimari & API Sözleşmeleri (v0.1)

Bu doküman podlar arası entegrasyonun temelidir: her pod burada tanımlanan JSON şekillerine göre
**birbirini beklemeden, mock veriyle** çalışmaya başlayabilir.

## Akış

```
Barkod → [Backend] fetch-product → OFF verisi + kural motoru sonucu
                                         ↓
                              [AI/LLM] explain-product → kişisel açıklama
                                         ↓
                                    [Mobil] UI'da göster
```

**Kritik ilke:** Alerjen kararı LLM'e bırakılmaz. `fetch-product` içindeki kural motoru,
OFF'un yapılı `allergens_tags` verisiyle kullanıcı profilini deterministik (kural tabanlı)
eşleştirir. `explain-product` bu hazır kararı sadece sade dile çevirir, değiştirmez.

---

## Sözleşme 1 — Mobil → Backend: `fetch-product`

**Sahip pod:** Backend

### İstek

```json
POST /functions/v1/fetch-product
{
  "barcode": "8690504041502"
}
```

### Yanıt — ürün bulundu

```json
{
  "status": "found",
  "product": {
    "barcode": "8690504041502",
    "name": "Ülker Çikolatalı Gofret",
    "ingredients_text": "Buğday unu, şeker, bitkisel yağ, kakao...",
    "additives": ["E322", "E500"],
    "allergens_tags": ["en:gluten", "en:milk", "en:soy"],
    "nutriments": {
      "energy_kcal_100g": 495,
      "sugars_100g": 38.2,
      "fat_100g": 27.1,
      "proteins_100g": 6.5,
      "salt_100g": 0.3
    },
    "nutriscore": "d"
  },
  "rule_engine_result": {
    "matched_allergens": ["gluten"],
    "has_conflict": true,
    "diet_flags": {
      "vegan_compatible": false,
      "diabetic_note": "yüksek şeker içeriği"
    }
  }
}
```

### Yanıt — ürün bulunamadı (FR-6)

```json
{ "status": "not_found", "barcode": "8690504041502" }
```

### Yanıt — veri eksik

```json
{
  "status": "partial",
  "product": { "...": "..." },
  "missing_fields": ["nutriments"]
}
```

### Alan notları

- `allergens_tags`: OFF'tan geldiği ham haliyle geçer, kural motoru burada hesaplanır.
- `rule_engine_result`: zaten hesaplanmış sonuç — mobil veya AI pod tekrar hesaplamaz.
- `status`: `"found" | "not_found" | "partial"` — mobil bu alana göre hangi ekranı göstereceğine karar verir.

**Düzeltme (v0.2):** `rule_engine_result` kullanıcının alerjileriyle eşleştirme yaptığı için
kullanıcı profiline ihtiyaç duyar. Mobil bunu istek gövdesinde ayrıca göndermez — Edge
Function, isteğin `Authorization` header'ındaki JWT'den kullanıcıyı çözer ve profili kendi
`profiles` tablosundan okur. Bu hem mobili sadeleştirir hem de bir kullanıcının başkasının
profiliymiş gibi istek atmasını (spoofing) imkansız kılar. Kullanıcı oturum açmamışsa
`rule_engine_result` `null` döner.

---

## Sözleşme 2 — Mobil → AI: `explain-product`

**Sahip pod:** AI/LLM

### İstek

```json
POST /functions/v1/explain-product
{
  "product": { "...": "fetch-product'tan gelen product nesnesi" },
  "rule_engine_result": { "...": "fetch-product'tan gelen rule_engine_result" },
  "user_profile": {
    "allergies": ["gluten", "fındık"],
    "diet_preference": "standard",
    "health_conditions": ["diyabet"]
  }
}
```

### Yanıt

```json
{
  "summary": "Bu ürün buğday unu, şeker ve kakao içeren bir çikolatalı gofret.",
  "personal_warning": {
    "level": "warning",
    "message": "Bu üründe GLUTEN var ve profilinde gluten alerjisi kayıtlı. Bu ürünü tüketmemen önerilir."
  },
  "diet_note": "Diyabet profiline göre: 100g'da 38g şeker var, yüksek şeker içeriğine dikkat.",
  "disclaimer": "Bu bilgi tıbbi tavsiye niteliği taşımaz."
}
```

### Alan notları

- `level`: `"ok" | "caution" | "warning"` — mobil pod bunu UI'daki uyarı bandının rengine
  direkt bağlar (yeşil/sarı/kırmızı), kendi karar vermez.
- `disclaimer`: guardrail gereği her yanıtta zorunlu.

---

## Profil (onboarding) — ayrı API gerekmiyor

Mobil pod, Supabase istemci kütüphanesi (`supabase_flutter` veya `supabase-js`) ile
`profiles` tablosuna doğrudan yazar/okur. Backend pod sadece tabloyu ve
satır-bazlı güvenlik kuralını (RLS: kullanıcı yalnızca kendi profilini görebilir) kurar.

```
profiles
  user_id        uuid (Supabase Auth ile eşleşir)
  allergies      text[]
  diet_preference enum
  health_conditions text[]
  created_at     timestamptz
  updated_at     timestamptz
```

---

## Sonraki adım

Backend ve AI podları, mobil beklemeden bu iki endpoint'i yukarıdaki örnek JSON'larla
Postman/curl üzerinden test edip geliştirebilir. Mobil pod da gerçek backend hazır olana kadar
bu örnek JSON'ları sabit (mock) veri olarak kullanıp UI'yı kurabilir.
