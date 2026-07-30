# Onboarding Akışı — Uygulama Planı

**Kapsam:** 2 karşılama ekranı + 3 tercih seçim ekranı. UI olarak uçtan uca çalışır.
**Uyulacak dokümanlar:** `docs/architecture.md` (veri sözleşmesi), `docs/flutter-mimari.md` (MVVM + feature-first).

---

## 0. Değişecek dosyalar

### Yeni (tamamı onboarding kapsamında)

```
lib/features/onboarding/
  onboarding_view.dart            # YENİDEN YAZILACAK — akışın kabuğu
  onboarding_viewmodel.dart       # YENİDEN YAZILACAK — adım + seçim state'i
  onboarding_steps.dart           # adım tanımları (veri) — tek kaynak
  widgets/
    onboarding_progress_bar.dart
    onboarding_question_card.dart
    onboarding_welcome_step.dart
    onboarding_selection_step.dart   # 3 seçim ekranının TEK widget'ı
    selectable_chip.dart
    onboarding_primary_button.dart   # Figma buton component'i
assets/images/
  onboarding_shop.svg             # ~/Downloads/shop_screen1.svg
  onboarding_scan.svg             # ~/Downloads/scan_screen2.svg
test/onboarding_viewmodel_test.dart
```

### Mevcut dosyalarda **yalnızca ekleme** (silme/değiştirme yok)

| Dosya | Değişiklik | Gerekçe |
|---|---|---|
| `lib/core/theme/app_colors.dart` | Yeni `// --- Onboarding ---` bloğu | "renk hardcode yok" kuralı; mevcut token'lara dokunulmaz |
| `lib/core/theme/app_text_styles.dart` | `onboardingQuestion`, `chipLabel` | aynı gerekçe |
| `lib/data/repositories/profile_repository.dart` | `ProfileRepository` → abstract; `SupabaseProfileRepository` + `InMemoryProfileRepository` + provider | Backend/auth hazır değil; mock dönerken bile kontrat aynı kalsın |
| `pubspec.yaml` | `flutter_svg` + `assets/` | karşılama görselleri |
| `test/shell_smoke_test.dart` | 1. testin akışı güncellenecek | mevcut test `'Atla (geçici)'` butonuna basıyor, o buton kalkıyor |

### Dokunulmayacak

`features/profile/*`, `features/shell/*`, `features/scan/*`, `features/home/*`,
`features/dashboard/*`, `features/product_detail/*`, `core/models/*`, `app.dart`, `main.dart`.

> `ProfileViewModel` `ProfileRepository`'yi kullanıyor. Sınıf **abstract**'a çevrilirken
> metod imzaları (`getProfile`, `saveProfile`) aynen korunacağı için o dosya derlenmeye
> devam eder — bu yüzden `profile_viewmodel.dart` düzenlenmeyecek.

---

## 1. Adım modeli — veri odaklı, tek kaynak

`docs/flutter-mimari.md` `warning_banner.dart` için "üç mockup'ı üç ayrı widget olarak
kodlamayın" diyor. Aynı kural burada da geçerli: **3 seçim ekranı tek widget + 3 veri kaydı.**

`lib/features/onboarding/onboarding_steps.dart`:

```dart
/// Profilde hangi alanı doldurduğumuz. UserProfile alan adlarıyla eşleşir.
enum OnboardingField { allergies, diet, health }

sealed class OnboardingStep {
  const OnboardingStep();
}

/// Görsel + başlık + açıklama taşıyan karşılama adımı.
final class OnboardingWelcomeStep extends OnboardingStep {
  const OnboardingWelcomeStep({
    required this.assetPath,
    required this.title,
    required this.body,
    required this.ctaLabel,
  });
  final String assetPath;
  final String title;
  final String body;
  final String ctaLabel;
}

/// Soru + çoklu seçim çipleri taşıyan adım.
final class OnboardingSelectionStep extends OnboardingStep {
  const OnboardingSelectionStep({
    required this.field,
    required this.question,
    required this.options,
    required this.skipLabel,
  });
  final OnboardingField field;
  final String question;
  final List<String> options;
  /// Hiçbir şey seçilmediğinde alt butonda yazan metin.
  final String skipLabel;
}

/// Akıştaki TÜM adımlar. Yeni adım eklemek = buraya bir kayıt eklemek;
/// ilerleme çubuğu ve ileri/geri bu listeden beslenir, başka yer değişmez.
const List<OnboardingStep> onboardingSteps = <OnboardingStep>[ ... ];
```

Liste içeriği (sıra = ekran sırası):

| # | Tür | İçerik |
|---|---|---|
| 0 | welcome | `assets/images/onboarding_shop.svg` — metinler **Figma MCP'den** gelecek |
| 1 | welcome | `assets/images/onboarding_scan.svg` — metinler **Figma MCP'den** gelecek |
| 2 | selection | `allergies` · "Herhangi bir gıda alerjin var mı?" · Gluten, Süt/Laktoz, Fındık/Fıstık, Yumurta, Balık, Kabuklu deniz ürünleri, Soya, Susam · skip: "Alerjim yok" |
| 3 | selection | `diet` · "Nasıl bir beslenme düzenin var?" · Vegan, Vejetaryen, Diyabet dostu, Sporcu / Yüksek protein, Düşük karbonhidrat, Glutensiz yaşam tarzı, Ketojenik · skip: "Özel bir diyetim yok" |
| 4 | selection | `health` · "Dikkat etmen gereken bir sağlık durumun var mı?" · Tansiyon, Çölyak, Yüksek kolesterol, Böbrek hastalığı, Şeker hastalığı, Kalp rahatsızlığı · skip: "Sağlık durumum yok" |

**Not:** `+` çipi `options` listesinde **yer almaz** — o bir kontrol, veri değil.
`OnboardingSelectionStep` widget'ı her zaman listenin sonuna ekler.

Karşılama adımlarındaki `title` / `body` / `ctaLabel` şimdilik
`// TODO(figma): MCP'den gelecek` yorumuyla placeholder metin taşır; Figma bağlantısı
kurulunca **sadece bu dosya** güncellenir.

---

## 2. ViewModel

`lib/features/onboarding/onboarding_viewmodel.dart` — `ChangeNotifier`, `ShellViewModel`
ile aynı desen (`ChangeNotifierProvider`, View tarafında `ConsumerWidget` + `ref.watch`).

```dart
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel(this._profileRepository);

  // --- Okuma ---
  int get currentIndex;
  OnboardingStep get currentStep;
  int get stepCount;                       // onboardingSteps.length (= 5)
  double get progress;                     // (currentIndex + 1) / stepCount
  bool get canGoBack;                      // currentIndex > 0
  bool get isLastStep;
  bool get isSaving;
  String? get errorMessage;

  /// Sabit seçenekler + kullanıcının "+" ile eklediği seçenekler.
  List<String> optionsFor(OnboardingField field);
  Set<String> selectionsFor(OnboardingField field);
  bool isSelected(OnboardingField field, String option);

  /// Alt butonun metni: hiç seçim yoksa adımın skipLabel'ı, varsa "Devam".
  String primaryActionLabel;

  // --- Yazma ---
  void toggleOption(OnboardingField field, String option);
  void addCustomOption(OnboardingField field, String option); // "+" çipi
  void goNext();      // son adımda hiçbir şey yapmaz; View submit çağırır
  void goBack();
  Future<bool> submit();   // profili kaydeder, başarıysa true
}

final onboardingViewModelProvider =
    ChangeNotifierProvider.autoDispose<OnboardingViewModel>(
  (ref) => OnboardingViewModel(ref.watch(profileRepositoryProvider)),
);
```

Kurallar:

- State `Map<OnboardingField, Set<String>>` olarak tutulur — alan başına bir küme.
- `addCustomOption`: boş/whitespace ve mevcut seçenekle (case-insensitive) çakışan girdi
  reddedilir; eklenen seçenek **otomatik seçili** gelir.
- `goNext` / `goBack` sınır dışına çıkmaz.
- `submit()` sırasında `isSaving = true` → repository → `false`; hata olursa
  `errorMessage` doldurulur ve `false` döner (View `SnackBar` gösterir, akış kapanmaz).

### Profile eşleme — dikkat, sözleşme çakışması var

`UserProfile.dietPreference` **tek** bir `DietPreference` enum'u
(`standard, vegan, vejetaryen, diyabetDostu, sporcu`), `docs/architecture.md`'de de
`diet_preference enum`. Ama diyet ekranı **çoklu seçim** ve seçeneklerin yarısı
(Düşük karbonhidrat, Glutensiz yaşam tarzı, Ketojenik) enum'da yok.

Bu turda alınan karar — **`core/models/user_profile.dart` ve sözleşme DEĞİŞTİRİLMEZ**
(backend pod'un da okuduğu ortak kontrat, tek taraflı değiştirilemez):

- UI çoklu seçim kalır (istenen tasarım bu).
- Eşleme **tek bir fonksiyonda** izole edilir:

```dart
/// Çoklu diyet seçimini sözleşmedeki tekil `diet_preference` enum'una indirger.
///
/// UYARI — bilinçli veri kaybı: seçilen ilk eşleşen değer alınır, kalanlar düşer.
/// Sözleşme `diet_preference`i tekil enum tanımlıyor (docs/architecture.md).
/// TODO(backend-pod): `diet_preference` alanının `text[]`e genişletilmesi ya da
/// `diet_tags text[]` eklenmesi konuşulacak; genişlerse burası tek satırlık değişir.
DietPreference _mapDietPreference(Set<String> selections) { ... }
```

- `UserProfile` şu şekilde kurulur:
  `allergies` = alerji kümesi (liste), `healthConditions` = sağlık kümesi (liste),
  `dietPreference` = `_mapDietPreference(...)`, `userId` = `repository.currentUserId`.

> **Melike'ye aksiyon:** bu kaybı backend pod'una taşı. Onlar `text[]`e geçerse
> `_mapDietPreference` silinir, `UserProfile` bir alan kazanır. Karar verilene kadar
> plan yukarıdaki gibi ilerler, UI teslimi bloke olmaz.

---

## 3. Repository — mock, ama kontrat gerçek

`lib/data/repositories/profile_repository.dart` şu hâle gelir (metod imzaları korunur):

```dart
abstract class ProfileRepository {
  /// Oturumdaki kullanıcının id'si; oturum yoksa null.
  String? get currentUserId;
  Future<UserProfile?> getProfile(String userId);
  Future<void> saveProfile(UserProfile profile);
}

/// docs/architecture.md — profil için ayrı API yok, Supabase "profiles" tablosu.
class SupabaseProfileRepository implements ProfileRepository { /* mevcut gövde */ }

/// Backend + auth hazır olana kadar kullanılan bellek içi karşılık.
/// Aynı arayüzü uyguladığı için gerçeğe geçiş tek satır.
class InMemoryProfileRepository implements ProfileRepository { ... }

// TODO(backend-pod): profiles tablosu + RLS + auth hazır olunca
// SupabaseProfileRepository()'ye çevrilecek. Başka hiçbir yer değişmeyecek.
final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => InMemoryProfileRepository());
```

`currentUserId` neden burada: ViewModel'in `supabase`'e doğrudan dokunmaması için
(`flutter-mimari.md`: Supabase ile konuşan tek katman repository).
`SupabaseProfileRepository.currentUserId` → `supabase.auth.currentUser?.id`,
`InMemoryProfileRepository.currentUserId` → `'mock-user'`.

`submit()` içinde `currentUserId == null` ise kaydetme atlanır, akış yine tamamlanır
(auth ekranı henüz yok) — bu durum kodda yorumla belirtilir.

---

## 4. Tasarım spesifikasyonu

### 4a. Karşılama ekranları (0–1) — kaynak: **Figma MCP**

Renk, spacing, font, radius **MCP'den gelen gerçek değerlerle** yazılır; görselden
tahmin yürütülmez. Buton `onboarding_primary_button.dart` olarak component hâlinde
çıkarılır — seçim ekranlarındaki alt buton da **aynı** component'i kullanır.

**MCP bağlantısı kurulana kadar geçici davranış:** `OnboardingPrimaryButton`, projedeki
mevcut `ElevatedButton` temasına (`AppTheme.light`: `AppColors.brand`, radius 28,
`Size.fromHeight(52)`, `AppTextStyles.button`) delege eder. Figma değerleri gelince
**yalnızca bu dosya + AppColors token'ları** değişir; seçim ekranları hiç dokunulmadan
doğru butonu alır. Bu sıralama sayesinde Figma beklenmeden 3 ekran bitirilebilir.

### 4b. Seçim ekranları (2–4) — kaynak: **BitePal referans görseli**

Referanstan piksel örneklemesiyle alınan değerler (ölçek ≈ 674px / 393pt = 1.715):

| Öğe | Değer | Token adı (AppColors) |
|---|---|---|
| Sayfa zemini | `#EFEEF5` | `onboardingBackground` |
| İlerleme çubuğu dolu | `#4AB35D` | `onboardingProgressFill` |
| İlerleme çubuğu boş | `#FEFEFE` | `onboardingProgressTrack` |
| Soru kartı / çip zemini | `#FEFEFE` | `onboardingSurface` |
| Seçili çip kenarlığı | `#E17F71` | `chipSelectedBorder` |
| Seçili çip noktası | `#FD8366` | `chipSelectedDot` |
| Boş çip noktası | `#EDEAED` | `chipDot` |

Ölçüler (hepsi ilgili widget'ın başında `static const` olarak, tek yerde):

| Öğe | Değer |
|---|---|
| Sayfa yatay padding | 20 |
| İlerleme çubuğu | yükseklik 6, radius 3 (tam yuvarlak), geri ok ile arası 16 |
| Geri oku | `Icons.arrow_back_ios_new`, 22, `AppColors.textPrimary` |
| Soru kartı | radius 20, padding 24, tam genişlik |
| Soru metni | 24 / height 1.25 / w700 → `AppTextStyles.onboardingQuestion` |
| Çip | radius 18, padding H 20 · V 14 |
| Çip etiketi | 17 / w600 → `AppTextStyles.chipLabel` |
| Çip noktası | çap 10, etiketle arası 10 |
| Çipler arası | `spacing: 8`, `runSpacing: 8`, `WrapAlignment.center` |
| Seçili kenarlık | 2px; **seçili değilken de 2px şeffaf kenarlık** çizilir (yoksa seçimde çip zıplar) |

Referanstan **kasten sapılan** noktalar (istenildiği gibi):

1. Rakun maskotu yok. Konuşma balonunun **kuyruğu da yok** — soru kartı düz, tam
   genişlikte beyaz bir kart olur (maskot gidince kuyruk boşluğa işaret ederdi).
2. Alt buton referanstaki siyah kapsül değil, **projenin Figma buton component'i**.
3. İlerleme çubuğunun tasarımı/rengi/kalınlığı referanstakiyle aynı bırakılır — sadece
   oran adıma göre değişir.

### 4c. Alt buton davranışı (referanstaki mantık)

- Adımda **hiç seçim yoksa**: metin = `step.skipLabel` (örn. "Alerjim yok"),
  başında `Icons.check_rounded`.
- **En az bir seçim varsa**: metin = "Devam", sonunda `Icons.chevron_right_rounded`.
- Her iki durumda da buton **aktiftir** ve bir sonraki adıma geçirir; seçim yapmamak
  geçerli bir cevaptır (kullanıcı o kategoride bir şeyi yok demektir).
- Son adımda buton `submit()` → başarılıysa `OnboardingView.completeOnboarding(context)`.

---

## 5. View yapısı

`onboarding_view.dart` — `ConsumerStatefulWidget` (bir `PageController` tutuyor):

```
Scaffold(backgroundColor: AppColors.onboardingBackground)
└ SafeArea
  └ Column
    ├ Padding(H 20)  → Row[ geri oku (canGoBack ? görünür : boşluk), OnboardingProgressBar ]
    ├ Expanded → PageView(
    │     controller, physics: NeverScrollableScrollPhysics(),
    │     children: adım tipine göre OnboardingWelcomeStep / OnboardingSelectionStep )
    └ Padding(H 20, alt SafeArea) → OnboardingPrimaryButton
```

- **`NeverScrollableScrollPhysics` bilinçli:** ilerleme tek kaynaktan (ViewModel) sürülsün,
  kaydırmayla ViewModel'i atlayan bir ikinci yol olmasın. İleri/geri sadece butonlarla.
  `ShellView`'daki kaydırmalı desenden farklı olması normal — orada sekmeler eşdeğer,
  burada akış sıralı.
- **Sistem geri tuşu:** `PopScope(canPop: !viewModel.canGoBack, onPopInvokedWithResult:)`
  — akışın içindeyken geri tuşu bir önceki **adıma** döner, ilk adımda uygulamadan çıkar.
  (Flutter 3.44 / Dart 3.12 — `onPopInvokedWithResult` doğru API, `onPopInvoked` deprecated.)
- ViewModel'deki `currentIndex` değişince `_pageController.animateToPage(...)` çağrılır
  (`ref.listen` ile), süre 280ms `Curves.easeOutCubic`.

### Widget sorumlulukları (küçük ve tek işli)

| Widget | Sorumluluk |
|---|---|
| `OnboardingProgressBar` | `progress` (0–1) alır, iki katmanlı yuvarlak çubuk çizer. `AnimatedFractionallySizedBox` ile 280ms geçiş. |
| `OnboardingQuestionCard` | Soru metnini beyaz kart içinde gösterir. |
| `OnboardingWelcomeStep` | `OnboardingWelcomeStep` verisini alır: SVG + başlık + açıklama. |
| `OnboardingSelectionStep` | `step` + `selections` + `onToggle` + `onAddCustom` alır. Soru kartı + `Wrap` içinde çipler + sondaki `+` çipi. **State tutmaz.** |
| `SelectableChip` | `label` / `isSelected` / `onTap`. `+` hâli için `SelectableChip.add(onTap:)` named constructor. |
| `OnboardingPrimaryButton` | `label` / `icon` / `iconAtEnd` / `isLoading` / `onPressed`. |

### `+` çipi davranışı

`showDialog` → `AlertDialog` içinde tek `TextField` (`textCapitalization: sentences`,
`autofocus: true`) + İptal / Ekle. Dönen metin `addCustomOption` ile eklenir ve
otomatik seçili gelir. Diyalog metinleri de temadan gelir, hardcode `TextStyle` yok.

---

## 6. Responsive kurallar

- **Sabit ekran boyutu varsayılmaz.** Hiçbir yerde `SizedBox(height: 300)` gibi mutlak
  görsel yüksekliği yok.
- Karşılama adımı: görsel `Expanded` + `FittedBox(fit: BoxFit.contain)`; metin bloğu
  `Flexible`. Küçük ekranda görsel küçülür, metin kırpılmaz.
- Seçim adımı: soru kartı sabit akışta, çip alanı `SingleChildScrollView` içinde —
  seçenek sayısı arttığında ya da yazı tipi büyütüldüğünde taşma olmaz.
- Alt buton her zaman ekranın altına sabit, `SafeArea` ile cihaz çentiğine saygılı.
- `Wrap` kullanıldığı için çipler her genişlikte kendi satırlarını bulur; tablet/geniş
  ekranda içerik `ConstrainedBox(maxWidth: 520)` ile ortalanır.
- Metin ölçeklendirme (`textScaler`) bozmaz: çiplerde sabit yükseklik yok, padding'li.

---

## 7. Testler

`test/onboarding_viewmodel_test.dart` — saf Dart, widget yok, sahte repository ile:

1. Başlangıç: `currentIndex == 0`, `canGoBack == false`, `progress == 1/5`.
2. `goNext` 4 kez → `isLastStep == true`, `progress == 1.0`; 5. çağrı sınırı aşmaz.
3. `toggleOption` seçer/kaldırır; farklı `OnboardingField`'lar birbirini etkilemez.
4. `addCustomOption`: boş girdi reddedilir, tekrar eden girdi reddedilir, geçerli girdi
   `optionsFor`'a eklenir **ve** seçili gelir.
5. `primaryActionLabel`: seçim yokken `skipLabel`, seçim varken "Devam".
6. `submit()`: sahte repository'ye giden `UserProfile`'da `allergies` ve
   `healthConditions` doğru; `dietPreference` eşlemesi beklendiği gibi.

`test/shell_smoke_test.dart` — 1. test güncellenir: `'Atla (geçici)'` yerine 5 adım
boyunca `OnboardingPrimaryButton`'a basılıp `ShellView`'a geçildiği doğrulanır.
Diğer 4 test **aynen kalır**.

---

## 8. Uygulama sırası (Sonnet 5 için)

Figma MCP bağlantısı beklenmeden 1–7 yapılabilir; 8 bağlantı kurulunca gelir.

1. `pubspec.yaml`: `flutter_svg: ^2.0.10` + `assets/images/`; SVG'leri
   `~/Downloads`'tan `assets/images/` altına doğru adlarla kopyala. `flutter pub get`.
2. `app_colors.dart` + `app_text_styles.dart`: yeni token'ları **ekle** (mevcutlara dokunma).
3. `profile_repository.dart`: abstract + iki implementasyon + provider.
4. `onboarding_steps.dart`: adım verisi.
5. `onboarding_viewmodel.dart`: state + provider + profile eşlemesi.
6. `widgets/`: `SelectableChip` → `OnboardingProgressBar` → `OnboardingQuestionCard` →
   `OnboardingPrimaryButton` → `OnboardingSelectionStep` → `OnboardingWelcomeStep`.
7. `onboarding_view.dart`: kabuk + navigasyon + `PopScope`.
8. **(Figma MCP sonrası)** Karşılama adımlarının gerçek metin/renk/spacing değerleri ve
   `OnboardingPrimaryButton`'ın gerçek component stili.
9. `flutter analyze` temiz + `flutter test` yeşil.

## 9. Bitmiş sayılma ölçütü

- 5 ekran ileri/geri gezilebiliyor, ilerleme çubuğu 1/5 → 5/5 ilerliyor.
- Çipler çoklu seçiliyor, seçili hâl turuncu kenarlık + dolu nokta ile görünüyor.
- `+` ile özel seçenek eklenebiliyor ve seçili geliyor.
- Alt buton metni seçime göre skipLabel ↔ "Devam" değişiyor.
- Son adımda profil repository'ye gidiyor, ardından `ShellView`'a `pushReplacement`.
- Kod içinde tek bir ham `Color(0x...)` / `TextStyle(fontSize:)` yok.
- `flutter analyze` uyarısız, `flutter test` tamamı yeşil.

## 10. Bilinen riskler

| Risk | Etki | Karşılık |
|---|---|---|
| `scan_screen2.svg` içinde `feColorMatrix` filtreleri ve gömülü base64 raster var; `flutter_svg` SVG filtrelerini desteklemez | 2. karşılama görseli hatalı/ağır render olabilir | 1. adımdan hemen sonra tek ekranda gözle doğrula; bozuksa Melike'den Figma'dan **PNG (3x)** export'u iste (`shop_screen1.svg` temiz, sorun beklenmiyor) |
| `diet_preference` tekil enum ↔ çoklu seçim | veri kaybı | §2'deki izole eşleme + backend pod'una taşınacak karar |
| Auth ekranı yok, `currentUserId` null | profil gerçekten kaydedilemez | `InMemoryProfileRepository` + `submit()` içinde null koruması |
| Figma MCP paid seat gerektirir | karşılama ekranları gerçek değerlerle yazılamaz | Adım 8 ayrıştırıldı; 1–7 bloke değil |
