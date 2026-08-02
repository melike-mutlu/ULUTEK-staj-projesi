/// `diet_preference` sütunu dönüştürülmeden önce yazılmış değerler.
/// O dönem sabit bir enum sözlüğü vardı; artık serbest metin tutuluyor, bu
/// yüzden eski satırlar okunurken katalog etiketlerine çevriliyor — yoksa
/// kullanıcının seçimi "vegan" diye ayrı bir özel çip olarak görünürdü.
const Map<String, String> _legacyDietLabels = <String, String>{
  'vegan': 'Vegan',
  'vejetaryen': 'Vejetaryen',
  'diyabet_dostu': 'Diyabet dostu',
  'sporcu': 'Sporcu / Yüksek protein',
};

/// `diet_preference` artık `text[]` ve serbest metin — alerjiler/sağlık
/// durumlarıyla aynı davranır.
///
/// Okuma tarafı hem diziyi hem de eski tekil string'i kabul eder.
/// `standard` "tercih yok" demekti, listeye alınmaz.
List<String> _parseDietPreferences(dynamic value) {
  final List<dynamic> raw;
  if (value == null) {
    return const <String>[];
  } else if (value is List) {
    raw = value;
  } else {
    raw = <dynamic>[value];
  }

  return raw
      .whereType<String>()
      .where((String e) => e != 'standard')
      .map((String e) => _legacyDietLabels[e] ?? e)
      .toList();
}

/// Supabase "profiles" tablosunun Dart karşılığı (bkz. docs/architecture.md).
class UserProfile {
  final String userId;
  final List<String> allergies;

  /// Seçili diyet tercihleri; boş liste "özel bir diyetim yok" demek.
  final List<String> dietPreferences;

  final List<String> healthConditions;

  /// Kullanıcının kendi girdiği ad. Boş bırakılabilir — gösterimde e-posta
  /// kullanıcı adına düşülür (bkz. core/utils/display_name.dart).
  final String? displayName;

  /// "avatars" storage bucket'ındaki fotoğrafın public URL'i.
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    required this.allergies,
    required this.dietPreferences,
    required this.healthConditions,
    this.displayName,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'allergies': allergies,
      'diet_preference': dietPreferences,
      'health_conditions': healthConditions,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      allergies: (json['allergies'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      dietPreferences: _parseDietPreferences(json['diet_preference']),
      healthConditions: (json['health_conditions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
