import '../../l10n/app_localizations.dart';

/// Profilde hangi alanı doldurduğumuz. UserProfile alan adlarıyla eşleşir.
enum OnboardingField { allergies, diet, health }

/// Onboarding ve Profil ekranlarının ORTAK seçenek kataloğu — tek kaynak.
/// Yeni seçenek eklemek = buradaki listeye eklemek; iki ekran da görür.
///
/// Katalog başlangıç noktası, sınır değil: üç alanda da kullanıcı "+" ile
/// kendi değerini ekleyebilir ve o değer olduğu gibi kaydedilir.
const Map<OnboardingField, List<String>> profileOptions =
    <OnboardingField, List<String>>{
  OnboardingField.allergies: <String>[
    'Gluten',
    'Süt/Laktoz',
    'Fındık/Fıstık',
    'Yumurta',
    'Balık',
    'Kabuklu deniz ürünleri',
    'Soya',
    'Susam',
  ],
  OnboardingField.diet: <String>[
    'Vegan',
    'Vejetaryen',
    'Diyabet dostu',
    'Sporcu / Yüksek protein',
    'Düşük karbonhidrat',
    'Glutensiz yaşam tarzı',
    'Ketojenik',
  ],
  OnboardingField.health: <String>[
    'Tansiyon',
    'Çölyak',
    'Yüksek kolesterol',
    'Böbrek hastalığı',
    'Şeker hastalığı',
    'Kalp rahatsızlığı',
  ],
};

/// Localized card title on the profile screen — short form of onboarding's
/// question for the given field.
String profileSectionTitle(AppLocalizations l10n, OnboardingField field) {
  switch (field) {
    case OnboardingField.allergies:
      return l10n.profileSectionAllergies;
    case OnboardingField.diet:
      return l10n.profileSectionDiet;
    case OnboardingField.health:
      return l10n.profileSectionHealth;
  }
}

/// Localized display label for a catalog option. The stored value stays the
/// raw Turkish string (selection, saving and rule matching all key on it); only
/// the visible chip text is localized. Custom "+" values fall through unchanged.
String localizedProfileOption(AppLocalizations l10n, String value) {
  switch (value) {
    // Allergies
    case 'Gluten':
      return l10n.allergenGluten;
    case 'Süt/Laktoz':
      return l10n.allergenMilk;
    case 'Fındık/Fıstık':
      return l10n.optNutsPeanuts;
    case 'Yumurta':
      return l10n.allergenEggs;
    case 'Balık':
      return l10n.allergenFish;
    case 'Kabuklu deniz ürünleri':
      return l10n.allergenCrustaceans;
    case 'Soya':
      return l10n.allergenSoy;
    case 'Susam':
      return l10n.allergenSesame;
    // Diet
    case 'Vegan':
      return l10n.optVegan;
    case 'Vejetaryen':
      return l10n.optVegetarian;
    case 'Diyabet dostu':
      return l10n.optDiabeticFriendly;
    case 'Sporcu / Yüksek protein':
      return l10n.optAthleteHighProtein;
    case 'Düşük karbonhidrat':
      return l10n.optLowCarb;
    case 'Glutensiz yaşam tarzı':
      return l10n.optGlutenFreeLifestyle;
    case 'Ketojenik':
      return l10n.optKetogenic;
    // Health
    case 'Tansiyon':
      return l10n.optBloodPressure;
    case 'Çölyak':
      return l10n.optCeliac;
    case 'Yüksek kolesterol':
      return l10n.optHighCholesterol;
    case 'Böbrek hastalığı':
      return l10n.optKidneyDisease;
    case 'Şeker hastalığı':
      return l10n.optDiabetesDisease;
    case 'Kalp rahatsızlığı':
      return l10n.optHeartCondition;
    default:
      return value;
  }
}

/// Onboarding'de alan başına sorulan soru.
const Map<OnboardingField, String> profileQuestions = <OnboardingField, String>{
  OnboardingField.allergies: 'Herhangi bir gıda alerjin var mı?',
  OnboardingField.diet: 'Nasıl bir beslenme düzenin var?',
  OnboardingField.health: 'Dikkat etmen gereken bir sağlık durumun var mı?',
};

/// Hiçbir şey seçilmediğinde onboarding'in alt butonunda yazan metin.
const Map<OnboardingField, String> profileSkipLabels =
    <OnboardingField, String>{
  OnboardingField.allergies: 'Alerjim yok',
  OnboardingField.diet: 'Özel bir diyetim yok',
  OnboardingField.health: 'Sağlık durumum yok',
};
