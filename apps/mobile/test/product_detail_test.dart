import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/product_detail/product_detail_view.dart';
import 'package:akilli_sepet/features/product_detail/product_detail_viewmodel.dart';
import 'package:akilli_sepet/features/product_detail/widgets/warning_banner.dart';
import 'package:akilli_sepet/features/product_detail/widgets/product_header_card.dart';
import 'package:akilli_sepet/core/models/explanation.dart';
import 'package:akilli_sepet/core/models/product.dart';
import 'package:akilli_sepet/core/models/rule_engine_result.dart';
import 'package:akilli_sepet/data/repositories/product_repository.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';

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

  testWidgets('ProductDetailView loads and renders correctly with ProviderScope', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProductDetailView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ürün Detayı'), findsOneWidget);
    expect(find.text('Çikolatalı Gofret'), findsOneWidget);
    expect(find.text('Ülker'), findsOneWidget);
    expect(find.text('Besin Değerleri (100g için)'), findsOneWidget);
    expect(find.text('Alerjenler & İçindekiler'), findsOneWidget);
  });

  test('ProductDetailViewModel loadFromFetchResult processes real user profile correctly', () async {
    final viewModel = ProductDetailViewModel();
    final profileRepo = InMemoryProfileRepository();

    const product = Product(
      barcode: '8690504041502',
      name: 'Test Product',
      brand: 'Test Brand',
      ingredientsText: 'Sample Ingredients',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(energyKcal100g: 400),
    );
    const ruleResult = RuleEngineResult(
      matchedAllergens: [],
      hasConflict: false,
      veganCompatible: true,
    );

    const fetchResult = ProductFetchResult(
      status: 'found',
      product: product,
      ruleEngineResult: ruleResult,
    );

    await viewModel.loadFromFetchResult(fetchResult, profileRepo);

    expect(viewModel.status, equals(ProductDetailStatus.found));
    expect(viewModel.product?.name, equals('Test Product'));
    expect(viewModel.explanation, isNotNull);
  });

  test('ProductDetailViewModel loadFromFetchResult handles error status without mock fallback', () async {
    final viewModel = ProductDetailViewModel();
    final profileRepo = InMemoryProfileRepository();

    const fetchResult = ProductFetchResult(
      status: 'error',
      errorMessage: 'Sunucu bağlantı hatası 500',
    );

    await viewModel.loadFromFetchResult(fetchResult, profileRepo);

    expect(viewModel.status, equals(ProductDetailStatus.error));
    expect(viewModel.errorMessage, equals('Sunucu bağlantı hatası 500'));
    expect(viewModel.product, isNull);
  });
}
