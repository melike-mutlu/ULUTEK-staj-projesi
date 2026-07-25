# Akıllı Sepet

AI destekli, kişiselleştirilmiş alışveriş asistanı — staj projesi.

## Yapı

- `apps/mobile/` — Flutter uygulaması (MVVM + Repository, feature-first klasörleme)
- `supabase/` — veritabanı şeması (`migrations/`) ve Edge Function'lar (`functions/fetch-product`, `functions/explain-product`) — bkz. `supabase/README.md`
- `docs/architecture.md` — Mobil/Backend/AI podları arası API sözleşmeleri
- `docs/flutter-mimari.md` — Flutter mimarisi ve paket seçimleri

## Mobil projeyi çalıştırmak için

`apps/mobile/` klasöründe, Flutter SDK yüklüyken:

```
flutter create .
flutter pub get
flutter run
```

`flutter create .` komutu android/ios/web gibi platform klasörlerini otomatik oluşturur,
mevcut `lib/` ve `pubspec.yaml` dosyalarına dokunmaz.

## Ekranlar hakkında not

`lib/features/` altındaki 6 klasör (onboarding, home, scan, product_detail, profile +
"ürün bulunamadı" durumu product_detail içinde bir state olarak) şu an için **temel
alınan ana ekranlar** — proje ilerledikçe yeni ekranlar eklenecek. Yeni bir ekran
eklerken aynı deseni izleyin: `features/<ekran_adi>/<ekran_adi>_view.dart` +
`<ekran_adi>_viewmodel.dart`.
