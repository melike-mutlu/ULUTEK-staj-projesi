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

  const UserProfile({
    required this.userId,
    required this.allergies,
    required this.dietPreference,
    required this.healthConditions,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'allergies': allergies,
      'diet_preference': _dietPreferenceDbNames[dietPreference],
      'health_conditions': healthConditions,
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
    );
  }
} 