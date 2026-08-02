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

/// Card titles on the profile screen — short form of onboarding's questions.
const Map<OnboardingField, String> profileSectionTitles =
    <OnboardingField, String>{
  OnboardingField.allergies: 'Alerjilerim',
  OnboardingField.diet: 'Beslenme düzenim',
  OnboardingField.health: 'Sağlık durumum',
};

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
