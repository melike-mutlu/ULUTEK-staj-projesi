import 'package:akilli_sepet/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AkilliSepetApp loads initial route', (WidgetTester tester) async {
    // Ilk ekran (AuthView) ref.watch kullaniyor; ProviderScope sart.
    await tester.pumpWidget(const ProviderScope(child: AkilliSepetApp()));
    expect(find.byType(AkilliSepetApp), findsOneWidget);
  });
}
