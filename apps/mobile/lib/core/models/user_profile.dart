enum DietPreference { standard, vegan, vejetaryen, diyabetDostu, sporcu }

const _dietPreferenceDbNames = {
  DietPreference.standard: 'standard',
  DietPreference.vegan: 'vegan',
  DietPreference.vejetaryen: 'vejetaryen',
  DietPreference.diyabetDostu: 'diyabet_dostu',
  DietPreference.sporcu: 'sporcu',
};

/// Supabase "profiles" tablosunun Dart karşılığı (bkz. docs/architecture.md).
class UserProfile {
  final String userId;
  final List<String> allergies;
  final DietPreference dietPreference;
  final List<String> healthConditions;

  /// Kullanıcının kendi girdiği ad. Boş bırakılabilir — gösterimde e-posta
  /// kullanıcı adına düşülür (bkz. core/utils/display_name.dart).
  final String? displayName;

  /// "avatars" storage bucket'ındaki fotoğrafın public URL'i.
  final String? avatarUrl;

  const UserProfile({
    required this.userId,
    required this.allergies,
    required this.dietPreference,
    required this.healthConditions,
    this.displayName,
    this.avatarUrl,
  });

  /// saveProfile satırın TAMAMINI upsert eder; tek bir alanı değiştirirken
  /// diğerlerinin null'lanmaması için profil sıfırdan kurulmaz, bununla
  /// kopyalanır.
  ///
  /// Note: a null argument means "keep", not "clear" — clearing a field needs
  /// a different mechanism if that is ever required.
  UserProfile copyWith({
    String? userId,
    List<String>? allergies,
    DietPreference? dietPreference,
    List<String>? healthConditions,
    String? displayName,
    String? avatarUrl,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      allergies: allergies ?? this.allergies,
      dietPreference: dietPreference ?? this.dietPreference,
      healthConditions: healthConditions ?? this.healthConditions,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'allergies': allergies,
      'diet_preference': _dietPreferenceDbNames[dietPreference],
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
      dietPreference: _dietPreferenceDbNames.entries
          .firstWhere(
            (e) => e.value == json['diet_preference'],
            orElse: () => const MapEntry(DietPreference.standard, 'standard'),
          )
          .key,
      healthConditions: (json['health_conditions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
} 