import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/app.dart';

void main() {
  testWidgets('AkilliSepetApp loads initial route', (WidgetTester tester) async {
    await tester.pumpWidget(const AkilliSepetApp());
    expect(find.byType(AkilliSepetApp), findsOneWidget);
  });
}
