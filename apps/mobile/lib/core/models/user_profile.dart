enum DietPreference { standard, vegan, vejetaryen, diyabetDostu, sporcu }

const _dietPreferenceDbNames = {
  DietPreference.standard: 'standard',
  DietPreference.vegan: 'vegan',
  DietPreference.vejetaryen: 'vejetaryen',
  DietPreference.diyabetDostu: 'diyabet_dostu',
  DietPreference.sporcu: 'sporcu',
};

/// `diet_preference` artık `text[]` — çoklu seçim serbest.
///
/// Okuma tarafı hem diziyi hem de eski tekil string'i kabul eder: sütun
/// dönüştürülmeden önce yazılmış satırlar hâlâ okunabilsin diye.
/// `standard` "tercih yok" demek, listeye alınmaz — karşılığı boş listedir.
List<DietPreference> _parseDietPreferences(dynamic value) {
  final List<dynamic> raw;
  if (value == null) {
    return const <DietPreference>[];
  } else if (value is List) {
    raw = value;
  } else {
    raw = <dynamic>[value];
  }

  final result = <DietPreference>[];
  for (final entry in raw) {
    for (final pair in _dietPreferenceDbNames.entries) {
      if (pair.value == entry && pair.key != DietPreference.standard) {
        result.add(pair.key);
      }
    }
  }
  return result;
}

/// Supabase "profiles" tablosunun Dart karşılığı (bkz. docs/architecture.md).
class UserProfile {
  final String userId;
  final List<String> allergies;

  /// Seçili diyet tercihleri; boş liste "özel bir diyetim yok" demek.
  final List<DietPreference> dietPreferences;

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
      'diet_preference': dietPreferences
          .map((DietPreference e) => _dietPreferenceDbNames[e])
          .toList(),
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
