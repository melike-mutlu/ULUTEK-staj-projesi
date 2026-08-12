import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/core/models/product.dart';
import 'package:akilli_sepet/features/product_detail/widgets/product_header_card.dart';
import 'package:akilli_sepet/l10n/app_localizations.dart';

/// Widths cover a narrow phone (280), the reported overflow case (310) and a
/// common phone width (360).
const _widths = <double>[280, 310, 360];

Product _product({
  String name = 'Kisa Ad',
  String brand = 'Ulker',
  String barcode = '8690504041502',
  String? nutriscore = 'b',
  bool isPending = false,
}) {
  return Product(
    barcode: barcode,
    name: name,
    brand: brand,
    ingredientsText: '',
    additives: const [],
    allergensTags: const [],
    nutriments: const Nutriments(),
    nutriscore: nutriscore,
    isPending: isPending,
  );
}

/// Every combination that used to overflow, plus the two that never did.
final _scenarios = <String, Product>{
  'kisa marka + nutri-score': _product(),
  'pending rozeti + kisa marka': _product(isPending: true),
  'pending rozeti + uzun marka': _product(
    brand: 'Topluluk Katkısı',
    isPending: true,
  ),
  'uzun marka, pending yok': _product(brand: 'Cok Uzun Bir Marka Adi Ornegi Ltd Sti'),
  'uzun urun adi': _product(
    name: 'Cok Uzun Bir Urun Adi Ornegi Findikli Kakaolu Gofret 500 Gram',
  ),
  'uzun barkod': _product(barcode: '869050404150212345678901234567890'),
};

Widget _cardAt(double width, Product product) {
  return MaterialApp(
    locale: const Locale('tr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: ProductHeaderCard(product: product)),
      ),
    ),
  );
}

/// Renders the card and returns the layout errors Flutter reported, so a
/// RenderFlex overflow fails the test with a readable message.
Future<List<String>> _layoutErrors(
  WidgetTester tester,
  double width,
  Product product,
) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details.exceptionAsString());
  try {
    await tester.pumpWidget(_cardAt(width, product));
    await tester.pump();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

void main() {
  for (final width in _widths) {
    for (final entry in _scenarios.entries) {
      testWidgets('ProductHeaderCard ${width.toInt()}px genisligde tasmiyor: ${entry.key}',
          (WidgetTester tester) async {
        expect(await _layoutErrors(tester, width, entry.value), isEmpty);
      });
    }
  }

  // Only the brand badge may shrink: the pending and Nutri-Score badges carry
  // safety information and must stay at their full width.
  for (final width in _widths) {
    testWidgets('ProductHeaderCard ${width.toInt()}px genisligde rozetleri kirpmiyor',
        (WidgetTester tester) async {
      final product = _product(brand: 'Topluluk Katkısı', isPending: true);
      expect(await _layoutErrors(tester, width, product), isEmpty);

      for (final label in ['Doğrulanmadı', 'Nutri-Score B']) {
        final badge = find.text(label);
        expect(badge, findsOneWidget, reason: '$label rozeti yok');

        final rendered = tester.getSize(badge).width;
        final intrinsic =
            (tester.renderObject(badge) as RenderBox).getMaxIntrinsicWidth(double.infinity);
        expect(rendered, greaterThanOrEqualTo(intrinsic - 0.5),
            reason: '$label rozeti kirpilmis');
      }

      expect(find.text('Topluluk Katkısı'), findsOneWidget);
    });
  }
}
