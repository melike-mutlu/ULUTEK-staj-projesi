import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/core/models/scan_history_entry.dart';
import 'package:akilli_sepet/core/providers.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';
import 'package:akilli_sepet/data/repositories/scan_history_repository.dart';
import 'package:akilli_sepet/features/chatbot/chatbot_view.dart';
import 'package:akilli_sepet/features/home/home_view.dart';
import 'package:akilli_sepet/shared/widgets/user_avatar_circle.dart';

class _FakeScanHistoryRepository implements ScanHistoryRepository {
  @override
  Future<void> saveScanHistory(String barcode) async {}

  @override
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async =>
      <Map<String, dynamic>>[];

  @override
  Future<List<ScanHistoryEntry>> getUniqueScanHistory({int limit = 10}) async =>
      <ScanHistoryEntry>[];
}

/// A screen rendered with a device-like status bar inset.
Widget _screenWithTopInset(Widget screen, double topInset) {
  return ProviderScope(
    overrides: <Override>[
      profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      scanHistoryRepositoryProvider.overrideWithValue(_FakeScanHistoryRepository()),
    ],
    child: MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(top: topInset)),
        child: screen,
      ),
    ),
  );
}

Widget _homeWithTopInset(double topInset) =>
    _screenWithTopInset(const HomeView(), topInset);

Future<double> _greetingTop(WidgetTester tester, double topInset) async {
  await tester.pumpWidget(_homeWithTopInset(topInset));
  await tester.pumpAndSettle();
  return tester.getTopLeft(find.text('Merhaba,')).dy;
}

void main() {
  testWidgets('selamlama status bar alanının altında başlar',
      (WidgetTester tester) async {
    const inset = 47.0; // typical notched phone
    expect(await _greetingTop(tester, inset), greaterThanOrEqualTo(inset));
  });

  testWidgets('profil ikonu da status bar alanının altında kalır',
      (WidgetTester tester) async {
    const inset = 47.0;
    await tester.pumpWidget(_homeWithTopInset(inset));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byType(UserAvatarCircle)).dy,
        greaterThanOrEqualTo(inset));
  });

  testWidgets('selamlama, sohbet ekranıyla aynı yükseklikte başlar',
      (WidgetTester tester) async {
    const inset = 47.0;

    await tester.pumpWidget(_screenWithTopInset(const ChatbotView(), inset));
    await tester.pumpAndSettle();
    final chatbotTop = tester.getTopLeft(find.byKey(const Key('screenHeaderRow'))).dy;

    await tester.pumpWidget(_homeWithTopInset(inset));
    await tester.pumpAndSettle();
    final homeTop = tester.getTopLeft(find.byKey(const Key('screenHeaderRow'))).dy;

    // Both screens put the header row at the same height, so switching tabs
    // does not shift it — even though the copy inside differs (chatbot no
    // longer shows the "Merhaba," placeholder now that it has a real UI).
    expect(homeTop, closeTo(chatbotTop, 0.5));
  });

  testWidgets('boşluk cihazın inset değerine göre büyür',
      (WidgetTester tester) async {
    final withoutInset = await _greetingTop(tester, 0);
    final withInset = await _greetingTop(tester, 60);

    // Responsive: the gap follows the device, it is not a hardcoded offset.
    expect(withInset - withoutInset, closeTo(60, 0.5));
  });
}
