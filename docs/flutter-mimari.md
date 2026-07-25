# Akıllı Sepet — Flutter Mimarisi (v0.1)

## Neden MVVM

- Flutter'ın resmi mimari rehberi zaten View + ViewModel + Repository katmanlarını önerir;
  widget'ların "build" mantığı View/ViewModel ayrımına doğal olarak uyuyor.
- Ekran sayımız az ve net (6 ekran) — her ekrana 1 ViewModel karşılık gelmesi kolay
  kavranan bir kural.
- Test edilebilirlik: iş mantığı widget'tan ayrıldığı için ViewModel'ler Flutter widget
  test'i olmadan unit test edilebilir. Ayrı bir QA podu olmadığı için bu önemli.

**Önemli:** Alerjen eşleştirme (kural motoru) Flutter tarafında tekrar yazılmaz. Bu mantık
backend'de (`fetch-product` Edge Function) çalışır; mobil yalnızca `rule_engine_result`
alanını okuyup gösterir.

## Katmanlar ve veri akışı

```
View (widget)          → sadece gösterir, state'i ViewModel'den dinler
    ↓ kullanıcı eylemi
ViewModel               → ekranın state'i (loading/data/error) + View'in çağırdığı metodlar
    ↓ çağırır
Repository              → Supabase ile konuşan tek katman
    ↓ çağırır
Supabase Edge Function  → fetch-product / explain-product (bkz. docs/architecture.md)
```

## Klasör yapısı (feature-first)

Katman bazlı değil özellik bazlı klasörleme: her geliştirici kendi ekranının klasöründe
çalışır, 3 mobil geliştirici aynı dosyalarda çakışmaz.

```
lib/
  main.dart
  app.dart                        # MaterialApp, route'lar, tema
  core/
    supabase_client.dart          # Supabase init
    models/                       # docs/architecture.md'deki JSON sözleşmelerinin Dart karşılığı
      product.dart                # Sözleşme 1 — "product"
      rule_engine_result.dart     # Sözleşme 1 — "rule_engine_result"
      explanation.dart            # Sözleşme 2'nin yanıtı
      user_profile.dart
  data/
    repositories/
      product_repository.dart     # fetch-product çağırır
      explanation_repository.dart # explain-product çağırır
      profile_repository.dart     # Supabase profiles tablosu CRUD
  features/
    onboarding/
      onboarding_view.dart
      onboarding_viewmodel.dart
    home/
      home_view.dart
      home_viewmodel.dart
    scan/
      scan_view.dart
      scan_viewmodel.dart
    product_detail/
      product_detail_view.dart
      product_detail_viewmodel.dart
      widgets/
        warning_banner.dart        # kırmızı/sarı/yeşil — level parametresiyle tek widget
    profile/
      profile_view.dart
      profile_viewmodel.dart
```

`warning_banner.dart` tek widget olmalı, `level` parametresine (`ok` / `caution` / `warning`)
göre renk ve metni değiştirmeli — üç mockup'ı üç ayrı widget olarak kodlamayın.

## Paket önerileri

| İhtiyaç | Öneri | Neden |
|---|---|---|
| State management | `flutter_riverpod` (ekip zorlanırsa `provider` + `ChangeNotifier`) | ViewModel'i `Notifier` olarak yazarsınız, BuildContext bağımlılığı yok, test etmesi kolay |
| Supabase erişimi | `supabase_flutter` | Auth + DB + Edge Function çağrısı tek pakette |
| Barkod okuma | `mobile_scanner` | PRD'de zaten önerilen, aktif bakımlı paket |
| JSON parse | Elle yazılmış `fromJson`/`toJson` factory'ler | `freezed`/`json_serializable`'ın `build_runner` kod üretimi 4 haftalık projede zaman kaybettirebilir |
| Navigasyon | Düz `Navigator.pushNamed` | 6 ekran, çoğunlukla doğrusal akış — `go_router` bu ölçekte gereksiz |

## Örnek: ProductDetailViewModel akışı

1. `ScanView` barkodu okur, `ScanViewModel.onBarcodeScanned(barcode)` çağrılır.
2. `ScanViewModel`, `ProductRepository.fetchProduct(barcode)` çağırır → `Product` + `RuleEngineResult` döner.
3. Sonuç `ProductDetailViewModel`'e taşınır (Navigator argument olarak), o da
   `ExplanationRepository.explainProduct(product, ruleResult, profile)` çağırır → `Explanation` döner.
4. `ProductDetailViewModel` state'ini `loading` → `data` yapar, `ProductDetailView` yeniden çizilir:
   `warning_banner.dart` (Explanation.personalWarning.level'a göre renk), içerik, katkı maddeleri,
   besin değerleri, Nutri-Score.
5. `status: "not_found"` veya `"partial"` gelirse `ProductDetailViewModel` state'ini `notFound`/`partial`
   yapar, View farklı bir boş-durum gösterir.
