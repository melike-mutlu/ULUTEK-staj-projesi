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
çakışmalarına yol açıyor.

Kontrol için:
```
flutter --version
```
Farklıysa [flutter_version_management](https://docs.flutter.dev/release/upgrade#switching-flutter-channels)
ile ya da [FVM](https://fvm.app/) kullanarak 3.44.0'a geçin.

## Mobil projeyi çalıştırmak için

Platform klasörleri (`android/`, `ios/`, `web/`) zaten repoda — `flutter create .`
çalıştırmana gerek yok.

1. **Supabase bağlantı bilgilerini gir.** `apps/mobile/lib/main.dart` içinde şu an
   `'TODO: Supabase proje URL'` gibi yer tutucular var — bunlar gerçek değerle
   değişmeden uygulama açılışta hata verir. Supabase Dashboard → Settings → API'den
   (proje: `ULUTEK-staj-projesi`) **Project URL** ve **anon public key**'i alıp
   `main.dart`'a yapıştır. Bu dosyayı bu haliyle commit'leme — gerçek anahtarları
   girdikten sonra sadece kendi makinende dursun.
2. `apps/mobile/` klasöründe:
   ```
   flutter pub get
   flutter run
   ```
3. Barkod okuma kamerası gerektirdiği için **gerçek bir telefon ya da kamera
   yönlendirmesi olan bir emülatör** kullan — düz masaüstü/web'de kamera akışı
   çalışmayabilir, "Barkodu Elle Gir" ile test edebilirsin.
4. Uçtan uca gerçek veri görmek için (`fetch-product`/`explain-product`) backend
   Edge Function'larının deploy edilmiş ve ortam değişkenlerinin (`SUPABASE_URL`,
   `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ANON_KEY`, `LLM_API_KEY`) Supabase proje
   ayarlarında girilmiş olması gerekiyor — bkz. `supabase/README.md`.

## Ekranlar hakkında not

`lib/features/` altındaki 6 klasör (onboarding, home, scan, product_detail, profile +
"ürün bulunamadı" durumu product_detail içinde bir state olarak) şu an için **temel
alınan ana ekranlar** — proje ilerledikçe yeni ekranlar eklenecek. Yeni bir ekran
eklerken aynı deseni izleyin: `features/<ekran_adi>/<ekran_adi>_view.dart` +
`<ekran_adi>_viewmodel.dart`.
