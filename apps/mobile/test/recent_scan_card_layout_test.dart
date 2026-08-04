import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/core/theme/akilli_sepet_colors.dart';
import 'package:akilli_sepet/features/home/widgets/recent_scan_card.dart';

const _widths = <double>[280, 320, 360];
const _longName =
    'Ülker Çikolatalı Fındıklı Gofret Ailesi Boyu Ekonomik Paket 500 Gram';
const _shortName = 'Süt';
const _absurdName =
    'Cok Uzun Bir Urun Adi Ornegi Findikli Kakaolu Gofret Ailesi Boyu Ekonomik '
    'Paket Yeni Formul Ekstra Findikli Sutlu Cikolata Kapli 1000 Gram Avantajli '
    'Aile Paketi Kampanyali Urun';
const _time = '2 gün önce';

Widget _cardAt(double width, String title) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          child: RecentScanCard(
            title: title,
            note: 'İçerik Analizi',
            noteColor: AkilliSepetColors.success,
            backgroundColor: const Color(0xFFE8F5E9),
            time: _time,
          ),
        ),
      ),
    ),
  );
}

/// Renders the card and returns the layout errors Flutter reported, so any
/// horizontal overflow fails the test with a readable message.
Future<List<String>> _layoutErrors(
  WidgetTester tester,
  double width,
  String title,
) async {
  final errors = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) => errors.add(details.exceptionAsString());
  try {
    await tester.pumpWidget(_cardAt(width, title));
    await tester.pump();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

void main() {
  for (final width in _widths) {
    for (final entry in {'uzun ad': _longName, 'absürt ad': _absurdName, 'kısa ad': _shortName}.entries) {
      testWidgets('${width.toInt()}px ${entry.key}: yatay taşma yok',
          (WidgetTester tester) async {
        expect(await _layoutErrors(tester, width, entry.value), isEmpty);
      });
    }
  }

  testWidgets('uzun ürün adı tek satıra kırpılmaz, alt satıra geçer',
      (WidgetTester tester) async {
    await _layoutErrors(tester, 280, _shortName);
    final shortHeight = tester.getSize(find.text(_shortName)).height;

    await _layoutErrors(tester, 280, _longName);
    final title = find.text(_longName);

    expect(tester.widget<Text>(title).maxLines, greaterThan(1));
    expect(tester.getSize(title).height, greaterThan(shortHeight));
  });

  testWidgets('ürün adı çok satıra çıkınca tarih üstte kalır',
      (WidgetTester tester) async {
    await _layoutErrors(tester, 280, _longName);

    final titleTop = tester.getTopLeft(find.text(_longName)).dy;
    final dateTop = tester.getTopLeft(find.text(_time)).dy;

    // Level with the first line of the title, not pushed down or centred.
    expect(dateTop, lessThanOrEqualTo(titleTop + 1));
  });

  testWidgets('tarih ürün adının sağında ve kartın içinde kalır',
      (WidgetTester tester) async {
    await _layoutErrors(tester, 280, _longName);

    final titleRight = tester.getBottomRight(find.text(_longName)).dx;
    final dateLeft = tester.getTopLeft(find.text(_time)).dx;
    final dateRight = tester.getBottomRight(find.text(_time)).dx;
    final cardRight = tester.getBottomRight(find.byType(RecentScanCard)).dx;

    expect(dateLeft, greaterThanOrEqualTo(titleRight));
    expect(dateRight, lessThanOrEqualTo(cardRight));
  });

  testWidgets('tarih hiçbir genişlikte kırpılmaz', (WidgetTester tester) async {
    for (final width in _widths) {
      await _layoutErrors(tester, width, _longName);

      final date = find.text(_time);
      final rendered = tester.getSize(date).width;
      final intrinsic =
          (tester.renderObject(date) as RenderBox).getMaxIntrinsicWidth(double.infinity);
      expect(rendered, greaterThanOrEqualTo(intrinsic - 0.5),
          reason: 'tarih ${width.toInt()}px genislikte sikismis');
    }
  });
}
