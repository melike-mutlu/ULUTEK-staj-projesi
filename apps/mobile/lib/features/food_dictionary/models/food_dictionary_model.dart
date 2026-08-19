enum FoodDictionaryCategory {
  all('Tümü', 'Tüm Terimler'),
  additives('Katkı Maddeleri', 'E-Kodları ve Gıda Katkıları'),
  nutrients('Besin Öğeleri', 'Makro ve Mikro Besinler'),
  terms('Gıda Terimleri', 'Gıda Bilimi ve Teknik Terimler'),
  allergens('Alerjenler', 'Alerjen Maddeler ve Hassasiyetler'),
  labelInfo('Etiket Bilgileri', 'Etiket Okuma ve Yasal Bilgiler'),
  processing('Üretim ve İşleme', 'Gıda İşleme Yöntemleri');

  final String title;
  final String description;
  const FoodDictionaryCategory(this.title, this.description);
}

enum SafetyLevel {
  safe('Güvenli', 'Genel olarak zararsız kabul edilir.'),
  caution('Dikkat', 'Hassas kişilerde veya yüksek dozda yan etki yapabilir.'),
  avoid('Kaçınılmalı', 'Sağlık riski taşıyabilir veya kısıtlanmıştır.'),
  neutral('Bilgilendirme', 'Besin öğesi veya teknik işlem terimi.');

  final String label;
  final String description;
  const SafetyLevel(this.label, this.description);
}

class FoodTerm {
  final String id;
  final String? code; // e.g. "E100"
  final String name; // e.g. "Kurkumin" or "Pastörizasyon"
  final FoodDictionaryCategory category;
  final String subCategory; // e.g. "Renklendirici", "Koruyucu", "Makro Besin"
  final String description;
  final SafetyLevel safetyLevel;
  final String? details;
  final String? usageAreas;
  final List<String> tags;

  const FoodTerm({
    required this.id,
    this.code,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.description,
    this.safetyLevel = SafetyLevel.neutral,
    this.details,
    this.usageAreas,
    this.tags = const [],
  });

  /// Visual display title (e.g. "E100 – Kurkumin" or "Pastörizasyon")
  String get displayTitle {
    if (code != null && code!.isNotEmpty) {
      return '$code – $name';
    }
    return name;
  }
}
