import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/features/product_detail/product_detail_view.dart';
import 'package:akilli_sepet/features/product_detail/widgets/warning_banner.dart';
import 'package:akilli_sepet/features/product_detail/widgets/product_header_card.dart';
import 'package:akilli_sepet/core/models/explanation.dart';
import 'package:akilli_sepet/core/models/product.dart';

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
      const MaterialApp(
        home: ProductDetailView(),
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
}
