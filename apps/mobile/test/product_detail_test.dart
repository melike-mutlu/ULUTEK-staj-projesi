import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/product_detail/product_detail_view.dart';
import 'package:akilli_sepet/features/product_detail/widgets/warning_banner.dart';
import 'package:akilli_sepet/features/product_detail/widgets/product_header_card.dart';
import 'package:akilli_sepet/core/models/explanation.dart';
import 'package:akilli_sepet/core/models/product.dart';
import 'package:akilli_sepet/core/models/rule_engine_result.dart';
import 'package:akilli_sepet/data/repositories/product_repository.dart';

void main() {
  testWidgets('WarningBanner displays status, warning message and disclaimer', (WidgetTester tester) async {
    const explanation = Explanation(
      summary: 'Test özeti',
      level: WarningLevel.warning,
      warningMessage: 'Bu üründe GLUTEN var!',
      disclaimer: 'Tıbbi tavsiye değildir.',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WarningBanner(explanation: explanation),
        ),
      ),
    );

    expect(find.text('UYGUN DEĞİL / RİSKLİ'), findsOneWidget);
    expect(find.text('Bu üründe GLUTEN var!'), findsOneWidget);
    expect(find.text('Tıbbi tavsiye değildir.'), findsOneWidget);
  });

  testWidgets('ProductHeaderCard displays brand, name and Nutri-Score', (WidgetTester tester) async {
    const product = Product(
      barcode: '123456789',
      name: 'Test Çikolata',
      brand: 'Test Marka',
      ingredientsText: 'Şeker, Kakao',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(energyKcal100g: 500),
      nutriscore: 'a',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductHeaderCard(product: product),
        ),
      ),
    );

    expect(find.text('Test Marka'), findsOneWidget);
    expect(find.text('Test Çikolata'), findsOneWidget);
    expect(find.text('Nutri-Score A'), findsOneWidget);
  });

  testWidgets('ProductDetailView loads default view correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductDetailView(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ürün Detayı'), findsOneWidget);
    expect(find.text('Çikolatalı Gofret'), findsOneWidget);
    expect(find.text('Ülker'), findsOneWidget);
    expect(find.text('Besin Değerleri (100g için)'), findsOneWidget);
    expect(find.text('Alerjenler & İçindekiler'), findsOneWidget);
  });

  testWidgets('ProductDetailView loads real ProductFetchResult argument', (WidgetTester tester) async {
    const realProduct = Product(
      barcode: '999888777',
      name: 'Gerçek Zeytinyağı',
      brand: 'Tariş',
      ingredientsText: 'Zeytinyağı',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(energyKcal100g: 800),
      nutriscore: 'a',
    );

    const fetchResult = ProductFetchResult(
      status: 'found',
      product: realProduct,
      ruleEngineResult: RuleEngineResult(
        matchedAllergens: [],
        hasConflict: false,
        veganCompatible: true,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => const ProductDetailView(),
            settings: RouteSettings(arguments: fetchResult),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gerçek Zeytinyağı'), findsOneWidget);
    expect(find.text('Tariş'), findsOneWidget);
    expect(find.text('SİZİN İÇİN UYGUN'), findsOneWidget);
  });
}
