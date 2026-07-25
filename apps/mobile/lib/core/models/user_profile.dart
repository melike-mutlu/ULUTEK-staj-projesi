enum DietPreference { standard, vegan, vejetaryen, diyabetDostu, sporcu }

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
      'diet_preference': dietPreference.name,
      'health_conditions': healthConditions,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      allergies: (json['allergies'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      dietPreference: DietPreference.values.firstWhere(
        (e) => e.name == json['diet_preference'],
        orElse: () => DietPreference.standard,
      ),
      healthConditions: (json['health_conditions'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}
