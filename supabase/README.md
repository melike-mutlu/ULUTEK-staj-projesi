# Supabase — Akıllı Sepet

## Şemayı uygulamak

Supabase CLI ile proje bağlandıktan sonra:

```
supabase db push
```

Bu, `migrations/0001_init.sql` içindeki `profiles` ve `product_cache` tablolarını kurar.

## Edge Function'ları deploy etmek

```
supabase functions deploy fetch-product
supabase functions deploy explain-product
```

## Gerekli ortam değişkenleri (Supabase proje ayarlarından secret olarak eklenir)

| Değişken | Nerede kullanılıyor |
|---|---|
| `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ANON_KEY` | `fetch-product` — cache okuma/yazma ve JWT'den kullanıcı çözme |
| `LLM_API_KEY` | `explain-product` — gerçek LLM entegrasyonu eklenince (AI pod) |

## Şu an placeholder olan kısımlar

- `fetch-product`: `runRuleEngine()` içindeki `diet_flags` (vegan/diyabet mantığı) — sadece alerjen eşleştirmesi gerçek, diyet bayrakları TODO.
- `explain-product`: `callLlmPlaceholder()` — gerçek LLM çağrısı yerine sözleşmeye uygun sahte yanıt dönüyor, AI pod bunu değiştirecek.
