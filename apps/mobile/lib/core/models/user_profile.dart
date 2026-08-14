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
  List<dynamic> raw;
  if (value == null) {
    return const <String>[];
  } else if (value is List) {
    raw = value;
  } else {
    raw = <dynamic>[value];
  }

  // PostgREST normalde text[] sütununu gerçek JSON dizisi döndürür; ama bazı
  // satırlarda değer tek bir Postgres array literal string'i olarak geldi
  // (ör. '{"a","b"}') — bunu tek eleman sanıp olduğu gibi göstermek yerine
  // açıp tek tek elemanlara ayırıyoruz.
  if (raw.length == 1 && raw.single is String) {
    final single = raw.single as String;
    if (single.startsWith('{') && single.endsWith('}')) {
      raw = _unwrapPostgresArrayLiteral(single);
    }
  }

  return raw
      .whereType<String>()
      .where((String e) => e != 'standard')
      .map((String e) => _legacyDietLabels[e] ?? e)
      .toList();
}

/// `{"a","b, c","d"}` gibi bir Postgres array literal string'ini elemanlarına
/// ayırır. Tırnaklı parçalardaki virgülleri korur.
List<String> _unwrapPostgresArrayLiteral(String literal) {
  final inner = literal.substring(1, literal.length - 1);
  if (inner.isEmpty) return const <String>[];

  final matches = RegExp(r'"((?:[^"\\]|\\.)*)"|([^,]+)').allMatches(inner);
  return matches
      .map((m) => (m.group(1) ?? m.group(2) ?? '').trim())
      .where((e) => e.isNotEmpty)
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

  /// Kullanıcının premium abonelik durumu.
  final bool isPremium;

  /// Kullanıcının seçtiği/girdiği ülke.
  final String? country;

  const UserProfile({
    required this.userId,
    required this.allergies,
    required this.dietPreferences,
    required this.healthConditions,
    this.displayName,
    this.avatarUrl,
    this.isPremium = false,
    this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'allergies': allergies,
      'diet_preference': dietPreferences,
      'health_conditions': healthConditions,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'country': country,
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
      isPremium: json['is_premium'] as bool? ?? false,
      country: json['country'] as String?,
    );
  }
}
