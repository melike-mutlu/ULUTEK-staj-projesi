import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/product_detail/widgets/warning_banner.dart';
import 'package:akilli_sepet/features/product_detail/widgets/personal_risks_section.dart';
import 'package:akilli_sepet/features/product_detail/widgets/other_allergens_section.dart';
import 'package:akilli_sepet/core/models/explanation.dart';
import 'package:akilli_sepet/core/models/product.dart';
import 'package:akilli_sepet/core/models/rule_engine_result.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';
import 'package:akilli_sepet/l10n/app_localizations.dart';

Widget _buildTestableWidget({
  required Widget child,
  required Size screenSize,
}) {
  return ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
    ],
    child: MaterialApp(
      locale: const Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: Scaffold(
          body: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('Screen Size Responsiveness Tests', () {
    final screenSizes = <String, Size>{
      'Small Phone (320x568)': const Size(320, 568),
      'Standard Phone (390x844)': const Size(390, 844),
      'Large Phone / Tablet (768x1024)': const Size(768, 1024),
    };

    for (final entry in screenSizes.entries) {
      final name = entry.key;
      final size = entry.value;

      testWidgets('Insufficient data screen renders cleanly without overflow on $name',
          (WidgetTester tester) async {
        const explanation = Explanation(
          summary: 'Veri Yetersiz',
          level: WarningLevel.ok,
          warningMessage: '',
          disclaimer: '',
        );

        await tester.pumpWidget(
          _buildTestableWidget(
            screenSize: size,
            child: const WarningBanner(
              explanation: explanation,
              insufficientData: true,
            ),
          ),
        );

        expect(find.text('Yetersiz veri'), findsOneWidget);
        expect(find.text('Bu ürünün içerik bilgisi eksik.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Multiple allergen icons render cleanly without overflow on $name',
          (WidgetTester tester) async {
        const product = Product(
          barcode: '123456',
          name: 'Çoklu Alerjenli Ürün',
          ingredientsText: 'Süt, buğday, yumurta, soya, fıstık, fındık, susam, balık',
          additives: [],
          allergensTags: [
            'en:milk',
            'en:gluten',
            'en:eggs',
            'en:soybeans',
            'en:peanuts',
            'en:nuts',
            'en:sesame-seeds',
            'en:fish'
          ],
          nutriments: Nutriments(),
        );

        const result = RuleEngineResult(
          matchedAllergens: ['milk', 'gluten'],
          hasConflict: true,
          veganCompatible: false,
          allergens: [
            DetectedAllergen(key: 'milk', matched: true),
            DetectedAllergen(key: 'gluten', matched: true),
            DetectedAllergen(key: 'eggs', matched: false),
            DetectedAllergen(key: 'soybeans', matched: false),
            DetectedAllergen(key: 'peanuts', matched: false),
            DetectedAllergen(key: 'nuts', matched: false),
            DetectedAllergen(key: 'sesame-seeds', matched: false),
            DetectedAllergen(key: 'fish', matched: false),
          ],
        );

        await tester.pumpWidget(
          _buildTestableWidget(
            screenSize: size,
            child: const SingleChildScrollView(
              child: Column(
                children: [
                  PersonalRisksSection(ruleEngineResult: result),
                  OtherAllergensSection(product: product, ruleEngineResult: result),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Alerjiler'), findsOneWidget);
        expect(find.text('Diğer alerjenler'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('Product Scenarios Regression Tests', () {
    testWidgets('Vegan product compatible scenario displays correctly',
        (WidgetTester tester) async {
      const result = RuleEngineResult(
        matchedAllergens: [],
        hasConflict: false,
        veganCompatible: true,
        vegetarianCompatible: true,
      );

      expect(result.veganCompatible, equals(true));
      expect(result.hasSufficientData, equals(true));
      expect(result.hasConflict, equals(false));
    });

    testWidgets('Non-vegan product scenario flags incompatibility correctly',
        (WidgetTester tester) async {
      const result = RuleEngineResult(
        matchedAllergens: ['milk'],
        hasConflict: true,
        veganCompatible: false,
        vegetarianCompatible: true,
        allergens: [DetectedAllergen(key: 'milk', matched: true)],
      );

      expect(result.veganCompatible, equals(false));
      expect(result.hasConflict, equals(true));
      expect(result.personalRiskKeys, contains('milk'));
    });

    testWidgets('Incomplete data product flags insufficient data state',
        (WidgetTester tester) async {
      const result = RuleEngineResult(
        matchedAllergens: [],
        hasConflict: false,
        veganCompatible: null,
        hasSufficientData: false,
      );

      expect(result.hasSufficientData, equals(false));
      expect(result.veganCompatible, isNull);
    });
  });
}
