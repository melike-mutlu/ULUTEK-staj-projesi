import 'package:akilli_sepet/core/models/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('diet_preference serbest metin dizisi olarak yazilir', () {
    const profile = UserProfile(
      userId: 'u1',
      allergies: <String>['Gluten'],
      dietPreferences: <String>['Vegan', 'Aralikli oruc'],
      healthConditions: <String>[],
      displayName: 'Melike',
      avatarUrl: 'https://example.invalid/a.jpg',
    );

    expect(
      profile.toJson()['diet_preference'],
      <String>['Vegan', 'Aralikli oruc'],
    );
    expect(profile.toJson()['display_name'], 'Melike');
    expect(profile.toJson()['avatar_url'], 'https://example.invalid/a.jpg');
  });

  test('secim yoksa diet_preference bos dizi', () {
    const profile = UserProfile(
      userId: 'u1',
      allergies: <String>[],
      dietPreferences: <String>[],
      healthConditions: <String>[],
    );

    expect(profile.toJson()['diet_preference'], isEmpty);
  });

  test('ozel diyet degeri kaybolmadan geri okunur', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>['Ketojenik', 'Aralikli oruc'],
      'health_conditions': <String>[],
      'display_name': 'Melike',
      'avatar_url': null,
    });

    expect(profile.dietPreferences, <String>['Ketojenik', 'Aralikli oruc']);
    expect(profile.displayName, 'Melike');
  });

  test('eski enum degerleri katalog etiketlerine cevrilir', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>['vegan', 'diyabet_dostu'],
      'health_conditions': <String>[],
    });

    expect(profile.dietPreferences, <String>['Vegan', 'Diyabet dostu']);
  });

  test('sutun donusmeden once yazilmis tekil string de okunabilir', () {
    final profile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': 'vegan',
      'health_conditions': <String>[],
    });

    expect(profile.dietPreferences, <String>['Vegan']);
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

  test('isPremium alani varsayilan olarak false, toJson/fromJson ile korunur', () {
    const defaultProfile = UserProfile(
      userId: 'u1',
      allergies: <String>[],
      dietPreferences: <String>[],
      healthConditions: <String>[],
    );
    expect(defaultProfile.isPremium, isFalse);
    expect(defaultProfile.toJson()['is_premium'], isFalse);

    const premiumProfile = UserProfile(
      userId: 'u1',
      allergies: <String>[],
      dietPreferences: <String>[],
      healthConditions: <String>[],
      isPremium: true,
    );
    expect(premiumProfile.isPremium, isTrue);
    expect(premiumProfile.toJson()['is_premium'], isTrue);

    final readProfile = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>[],
      'health_conditions': <String>[],
      'is_premium': true,
    });
    expect(readProfile.isPremium, isTrue);
  });

  test('country alani toJson ve fromJson ile korunur', () {
    const profile = UserProfile(
      userId: 'u1',
      allergies: <String>[],
      dietPreferences: <String>[],
      healthConditions: <String>[],
      country: 'Türkiye',
    );
    expect(profile.country, 'Türkiye');
    expect(profile.toJson()['country'], 'Türkiye');

    final read = UserProfile.fromJson(<String, dynamic>{
      'user_id': 'u1',
      'allergies': <String>[],
      'diet_preference': <String>[],
      'health_conditions': <String>[],
      'country': 'Almanya',
    });
    expect(read.country, 'Almanya');
  });
}
