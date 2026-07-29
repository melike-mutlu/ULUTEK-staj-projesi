# Akıllı Sepet

AI destekli, kişiselleştirilmiş alışveriş asistanı — staj projesi.

## Yapı

- `apps/mobile/` — Flutter uygulaması (MVVM + Repository, feature-first klasörleme)
- `supabase/` — veritabanı şeması (`migrations/`) ve Edge Function'lar (`functions/fetch-product`, `functions/explain-product`) — bkz. `supabase/README.md`
- `docs/architecture.md` — Mobil/Backend/AI podları arası API sözleşmeleri
- `docs/flutter-mimari.md` — Flutter mimarisi ve paket seçimleri

## Flutter sürümü (herkes aynısını kullanmalı)

**Flutter 3.44.0 (stable channel)** — `apps/mobile/pubspec.lock` ve `.metadata` bu sürüme
göre kilitlenmiş. Farklı sürümle `flutter create .` / `flutter pub get` çalıştırmak,
`.metadata`, `android/`, `ios/` gibi otomatik üretilen dosyalarda anlamsız PR
çakışmalarına yol açıyor (bu PR turunda tam olarak bu yaşandı).

Kontrol için:
```
flutter --version
```
Farklıysa [flutter_version_management](https://docs.flutter.dev/release/upgrade#switching-flutter-channels)
ile ya da [FVM](https://fvm.app/) kullanarak 3.44.0'a geçin.

## Mobil projeyi çalıştırmak için

`apps/mobile/` klasöründe, Flutter 3.44.0 yüklüyken:

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
