import '../../core/constants/profile_options.dart';

// Seçenek kataloğu profil ekranıyla ortak; OnboardingField'ı buradan da
// import edenler kırılmasın diye yeniden dışa veriliyor.
export '../../core/constants/profile_options.dart' show OnboardingField;

sealed class OnboardingStep {
  const OnboardingStep();
}

/// Görsel + başlık + açıklama taşıyan karşılama adımı.
final class OnboardingWelcomeStep extends OnboardingStep {
  const OnboardingWelcomeStep({
    required this.assetPath,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.skipLabel,
    this.imageScale = 1,
    this.contentTopOffset = 0,
    this.imageTopOffset = 0,
    this.textTopOffset = 0,
  });

  final String assetPath;
  final String title;
  final String body;

  /// Alt CTA butonunun metni. `null` ise bu ekranda buton hiç gösterilmez —
  /// Figma'da 1. ekranda (node 0:3) buton yok, sadece [skipLabel] linki ve
  /// parmakla kaydırma var.
  final String? ctaLabel;

  /// Sağ üstteki "Skip" linkinin metni. `null` ise hiç gösterilmez.
  final String? skipLabel;

  /// Görseli, kendisine ayrılan alana normalde sığacağı boyuta göre
  /// büyütür/küçültür (1 = değişiklik yok). Asset'lerin kendi kenar
  /// boşlukları farklı olduğu için ekran ekran ayarlanabilir.
  final double imageScale;

  /// Görsel + metin bloğunu (Skip linki hariç) bu kadar aşağı kaydırır.
  final double contentTopOffset;

  /// Yalnızca ortadaki görseli, metni etkilemeden bu kadar aşağı kaydırır.
  final double imageTopOffset;

  /// Yalnızca başlık + açıklama bloğunu bu kadar aşağı kaydırır.
  final double textTopOffset;
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

/// Seçim adımını katalogdan kurar — soru/seçenek/skip metni tek kaynaktan
/// (core/constants/profile_options.dart) gelir.
OnboardingSelectionStep _selectionStep(OnboardingField field) =>
    OnboardingSelectionStep(
      field: field,
      question: profileQuestions[field]!,
      options: profileOptions[field]!,
      skipLabel: profileSkipLabels[field]!,
    );

/// Akıştaki TÜM adımlar. Yeni adım eklemek = buraya bir kayıt eklemek;
/// ilerleme çubuğu ve ileri/geri bu listeden beslenir, başka yer değişmez.
final List<OnboardingStep> onboardingSteps = <OnboardingStep>[
  const OnboardingWelcomeStep(
    assetPath: 'assets/images/onboarding_shop.svg',
    title: 'Hoş geldin!',
    body: 'Akıllı Sepet, alerjine, diyetine ve sağlık durumuna göre sana '
        'özel bir alışveriş rehberi.',
    skipLabel: 'Atla',
    imageScale: 0.7,
    contentTopOffset: 20,
    imageTopOffset: 60,
  ),
  const OnboardingWelcomeStep(
    assetPath: 'assets/images/onboarding_scan.svg',
    title: 'Barkodu Okut, Anında Öğren',
    body: 'Ürünün barkodunu okut; alerjen, diyet ve sağlık profiline göre '
        'uygun olup olmadığını anında söyleyelim.',
    ctaLabel: 'Başlayalım!',
    imageScale: 3.5,
    imageTopOffset: 30,
    textTopOffset: 8,
  ),
  _selectionStep(OnboardingField.allergies),
  _selectionStep(OnboardingField.diet),
  _selectionStep(OnboardingField.health),
];
