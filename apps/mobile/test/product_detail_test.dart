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

  test('Product model correctly identifies isPending from status and json', () {
    final pendingJson = {
      'barcode': '123',
      'name': 'Test',
      'ingredients_text': '',
      'additives': [],
      'allergens_tags': [],
      'nutriments': {},
      'status': 'PENDING',
    };
    final product = Product.fromJson(pendingJson);
    expect(product.isPending, isTrue);

    const directProduct = Product(
      barcode: '123',
      name: 'Test',
      ingredientsText: '',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(),
      isPending: true,
    );
    expect(directProduct.isPending, isTrue);
  });

  testWidgets('ProductHeaderCard displays "Doğrulanmadı" badge for pending products', (WidgetTester tester) async {
    const pendingProduct = Product(
      barcode: '123456789',
      name: 'Topluluk Ürünü',
      brand: 'Test Marka',
      ingredientsText: 'İçerik',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(),
      isPending: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductHeaderCard(product: pendingProduct),
        ),
      ),
    );

    expect(find.text('Doğrulanmadı'), findsOneWidget);
  });

  testWidgets('ProductDetailView renders pending warning banner for pending state', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProductDetailView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll to mock tester bar and tap on ⏳ Pending chip
    final pendingChip = find.text('⏳ Pending');
    expect(pendingChip, findsOneWidget);
    await tester.ensureVisible(pendingChip);
    await tester.pumpAndSettle();

    await tester.tap(pendingChip);
    await tester.pumpAndSettle();

    expect(find.text('Bu ürün topluluk tarafından eklendi, henüz doğrulanmadı.'), findsOneWidget);
    expect(find.text('DİKKAT EDİLMELİ'), findsOneWidget);
    expect(find.text('Doğrulanmadı'), findsOneWidget);
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

  test('ProductDetailViewModel overrides level to caution for unverified community products', () async {
    final viewModel = ProductDetailViewModel();
    final profileRepo = InMemoryProfileRepository();

    const product = Product(
      barcode: '9998887776655',
      name: 'Unverified Granola',
      ingredientsText: 'Yulaf',
      additives: [],
      allergensTags: [],
      nutriments: Nutriments(energyKcal100g: 300),
      isPending: true,
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
    expect(viewModel.product?.isPending, isTrue);
    expect(viewModel.explanation?.level, isNot(equals(WarningLevel.ok)));
    expect(viewModel.explanation?.warningMessage, contains('doğrulanmadı'));
  });
}
