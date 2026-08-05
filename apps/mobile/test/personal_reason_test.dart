import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/core/models/explanation.dart';
import 'package:akilli_sepet/core/models/rule_engine_result.dart';
import 'package:akilli_sepet/core/models/user_profile.dart';
import 'package:akilli_sepet/features/product_detail/profile_checks.dart';

const _explanation = Explanation(
  summary: 'Ozet',
  level: WarningLevel.warning,
  warningMessage: 'Backend mesaji',
  disclaimer: 'Tibbi tavsiye degildir.',
);

UserProfile _profile({
  List<String> diets = const [],
  List<String> conditions = const [],
}) {
  return UserProfile(
    userId: 'u1',
    allergies: const [],
    dietPreferences: diets,
    healthConditions: conditions,
  );
}

void main() {
  test('alerjenleri tek cumlede sayar', () {
    final reason = personalReason(
      explanation: _explanation,
      rule: const RuleEngineResult(
        matchedAllergens: [],
        hasConflict: true,
        veganCompatible: false,
        allergens: [
          DetectedAllergen(key: 'gluten', matched: true),
          DetectedAllergen(key: 'milk', matched: true),
          DetectedAllergen(key: 'nuts', matched: true),
        ],
      ),
      profile: _profile(),
    );

    expect(
      reason,
      'Sende alerji yapan gluten, süt / laktoz ve kabuklu yemişler içeriyor.',
    );
  });

  test('diyet ve saglik cakismalarini ekler', () {
    final reason = personalReason(
      explanation: _explanation,
      rule: const RuleEngineResult(
        matchedAllergens: [],
        hasConflict: true,
        veganCompatible: false,
        diabeticNote: 'Yüksek şeker oranı',
      ),
      profile: _profile(diets: ['Vegan'], conditions: ['Şeker hastalığı']),
    );

    expect(reason, contains('Vegan beslenmene uygun değil.'));
    expect(
      reason,
      contains('Profilindeki Şeker hastalığı için: Yüksek şeker oranı.'),
    );
  });

  test('kisisel bir sey yoksa backend mesajina duser', () {
    final reason = personalReason(
      explanation: _explanation,
      rule: const RuleEngineResult(
        matchedAllergens: [],
        hasConflict: false,
        veganCompatible: true,
      ),
      profile: _profile(),
    );

    expect(reason, 'Backend mesaji');
  });
}
