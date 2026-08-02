import 'package:akilli_sepet/core/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('diet_preference dizi olarak yazilir', () {
    const profile = UserProfile(
      userId: 'u1',
      allergies: <String>['Gluten'],
      dietPreferences: <DietPreference>[
        DietPreference.vegan,
        DietPreference.sporcu,
      ],
      healthConditions: <String>[],
      displayName: 'Melike',
      avatarUrl: 'https://example.invalid/a.jpg',
    );

    expect(
      profile.toJson()['diet_preference'],
      <String>['vegan', 'sporcu'],
    );
    expect(profile.toJson()['display_name'], 'Melike');
    expect(profile.toJson()['avatar_url'], 'https://example.invalid/a.jpg');
  });

  test('secim yoksa diet_preference bos dizi', () {
    const profile = UserProfile(
      userId: 'u1',
      allergies: <String>[],
      dietPreferences: <DietPreference>[],
      healthConditions: <String>[],
    );

    expect(profile.toJson()['diet_preference'], isEmpty);
  });

  test('diet_preference dizi olarak okunur', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>['vejetaryen', 'diyabet_dostu'],
      'health_conditions': <String>[],
      'display_name': 'Melike',
      'avatar_url': null,
    });

    expect(profile.dietPreferences, <DietPreference>[
      DietPreference.vejetaryen,
      DietPreference.diyabetDostu,
    ]);
    expect(profile.displayName, 'Melike');
  });

  test('sutun donusmeden once yazilmis tekil string de okunabilir', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': 'vegan',
      'health_conditions': <String>[],
    });

    expect(profile.dietPreferences, <DietPreference>[DietPreference.vegan]);
  });

  test('standard "tercih yok" demek, listeye alinmaz', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>['standard'],
      'health_conditions': <String>[],
    });

    expect(profile.dietPreferences, isEmpty);
  });

  test('bilinmeyen diyet degeri elenir, digerleri korunur', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>['vegan', 'bilinmeyen_deger'],
      'health_conditions': <String>[],
    });

    expect(profile.dietPreferences, <DietPreference>[DietPreference.vegan]);
  });
}
