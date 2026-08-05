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
import 'package:akilli_sepet/core/providers.dart';
import 'package:akilli_sepet/data/repositories/product_repository.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';

const _foundFetchResult = ProductFetchResult(
  status: 'found',
  product: Product(
    barcode: '8690504041502',
    name: 'Rota Argumanli Urun',
    brand: 'Test Marka',
    ingredientsText: 'Test icerik',
    additives: [],
    allergensTags: [],
    nutriments: Nutriments(energyKcal100g: 400),
  ),
  ruleEngineResult: RuleEngineResult(
    matchedAllergens: [],
    hasConflict: false,
    veganCompatible: true,
  ),
);

/// Returns a distinct product per barcode, so "always the same product"
/// regressions surface immediately.
class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.namesByBarcode);

  final Map<String, String> namesByBarcode;
  final List<String> requestedBarcodes = <String>[];

  @override
  Future<ProductFetchResult> fetchProduct(String barcode) async {
    requestedBarcodes.add(barcode);

    final name = namesByBarcode[barcode];
    if (name == null) {
      return const ProductFetchResult(status: 'not_found');
    }

    return ProductFetchResult(
      status: 'found',
      product: Product(
        barcode: barcode,
        name: name,
        brand: 'Test Marka',
        ingredientsText: 'Test icerik',
        additives: const [],
        allergensTags: const [],
        nutriments: const Nutriments(energyKcal100g: 400),
      ),
      ruleEngineResult: const RuleEngineResult(
        matchedAllergens: [],
        hasConflict: false,
        veganCompatible: true,
      ),
    );
  }
}

/// Opens the screen with a route argument; profile layer is faked (no Supabase).
Widget _productDetailUnderTest(
  Object? arguments, {
  ProductRepository? productRepository,
}) {
  return ProviderScope(
    overrides: <Override>[
      profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      if (productRepository != null)
        productRepositoryProvider.overrideWithValue(productRepository),
    ],
    child: MaterialApp(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const ProductDetailView(),
        settings: RouteSettings(arguments: arguments),
      ),
    ),
  );
}

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
    // The mock bar only renders in the "found" state, so open the screen with
    // a real fetch result and tap the chip from there.
    await tester.pumpWidget(_productDetailUnderTest(_foundFetchResult));

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

  testWidgets('ProductDetailView fetches the barcode it was opened with, not a mock',
      (WidgetTester tester) async {
    final repository = _FakeProductRepository({
      '1111111111111': 'Birinci Urun',
      '2222222222222': 'Ikinci Urun',
    });

    await tester.pumpWidget(
      _productDetailUnderTest('1111111111111', productRepository: repository),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedBarcodes, equals(['1111111111111']));
    expect(find.text('Birinci Urun'), findsOneWidget);

    // Unmount first: in the app every push builds a new screen state, while
    // re-pumping the same tree would only update the existing one.
    await tester.pumpWidget(const SizedBox.shrink());

    // Reopening with another barcode must show that product, not the first one
    // and not the hardcoded mock ("Çikolatalı Gofret").
    await tester.pumpWidget(
      _productDetailUnderTest('2222222222222', productRepository: repository),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedBarcodes.last, equals('2222222222222'));
    expect(find.text('Ikinci Urun'), findsOneWidget);
    expect(find.text('Birinci Urun'), findsNothing);
    expect(find.text('Çikolatalı Gofret'), findsNothing);
  });

  test('loadFromBarcode returns a different product for a different barcode', () async {
    final repository = _FakeProductRepository({
      '1111111111111': 'Birinci Urun',
      '2222222222222': 'Ikinci Urun',
    });
    final viewModel = ProductDetailViewModel();
    final profileRepo = InMemoryProfileRepository();

    await viewModel.loadFromBarcode('1111111111111', repository, profileRepo);
    expect(viewModel.status, equals(ProductDetailStatus.found));
    expect(viewModel.product?.name, equals('Birinci Urun'));
    expect(viewModel.product?.barcode, equals('1111111111111'));

    await viewModel.loadFromBarcode('2222222222222', repository, profileRepo);
    expect(viewModel.product?.name, equals('Ikinci Urun'));
    expect(viewModel.product?.barcode, equals('2222222222222'));
    expect(repository.requestedBarcodes,
        equals(['1111111111111', '2222222222222']));
  });

  test('loadFromBarcode reports not found without falling back to a mock product', () async {
    final repository = _FakeProductRepository(const {});
    final viewModel = ProductDetailViewModel();

    await viewModel.loadFromBarcode(
      '9999999999999',
      repository,
      InMemoryProfileRepository(),
    );

    expect(viewModel.status, equals(ProductDetailStatus.notFound));
    expect(viewModel.product, isNull);
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

  test('Product model correctly parses and serializes imageUrl', () {
    final json = {
      'barcode': '123456789',
      'name': 'Test Ürün',
      'image_url': 'https://example.com/test.jpg',
      'ingredients_text': '',
      'additives': [],
      'allergens_tags': [],
      'nutriments': {},
    };
    final product = Product.fromJson(json);
    expect(product.imageUrl, equals('https://example.com/test.jpg'));
    expect(product.toJson()['image_url'], equals('https://example.com/test.jpg'));
  });

  testWidgets('ProductDetailView does not display Sepete Ekle button', (WidgetTester tester) async {
    await tester.pumpWidget(_productDetailUnderTest(_foundFetchResult));

    await tester.pumpAndSettle();
    expect(find.text('Sepete Ekle'), findsNothing);
    expect(find.text('Ana Sayfa'), findsOneWidget);
  });
}
