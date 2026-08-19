import 'package:akilli_sepet/app.dart';
import 'package:akilli_sepet/core/models/scan_history_entry.dart';
import 'package:akilli_sepet/core/providers.dart';
import 'package:akilli_sepet/data/repositories/chatbot_repository.dart';
import 'package:akilli_sepet/data/repositories/profile_repository.dart';
import 'package:akilli_sepet/data/repositories/scan_history_repository.dart';
import 'package:akilli_sepet/features/auth/auth_view.dart';
import 'package:akilli_sepet/features/onboarding/onboarding_view.dart';
import 'package:akilli_sepet/features/profile/profile_view.dart';
import 'package:akilli_sepet/features/shell/shell_view.dart';
import 'package:akilli_sepet/features/shell/shell_viewmodel.dart';
import 'package:akilli_sepet/features/shell/widgets/glass_bottom_nav.dart';
import 'package:akilli_sepet/features/startup/startup_gate.dart';
import 'package:akilli_sepet/l10n/app_localizations.dart';
import 'package:akilli_sepet/shared/services/image_picker_service.dart';
import 'package:akilli_sepet/shared/widgets/user_avatar_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sekme etiketi hem AppBar basliginda hem barda gecebiliyor; dokunusun
/// bardaki etikete gittiginden emin olmak icin arama bar icinde yapiliyor.
Finder _navLabel(String label) => find.descendant(
      of: find.byType(GlassBottomNav),
      matching: find.text(label),
    );

/// `implements` ile: gercek kurucu Supabase.instance'i istiyor, testte ise
/// Supabase hic baslatilmiyor.
class _FakeScanHistoryRepository implements ScanHistoryRepository {
  @override
  Future<void> saveScanHistory(String barcode ,{bool hadConflict = false}) async {}

  @override
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async =>
      <Map<String, dynamic>>[];

  @override
  Future<List<ScanHistoryEntry>> getUniqueScanHistory({int limit = 10}) async =>
      <ScanHistoryEntry>[];
}

/// Chatbot sekmesi de PageView icinde inşa ediliyor; gercek kurucu Supabase
/// istemcisi istiyor, testte ise Supabase hic baslatilmiyor.
class _FakeChatbotRepository implements ChatbotRepository {
  @override
  Future<ChatbotResponse> sendMessage(String userMessage,
          {String? sessionId, PickedImage? image}) async =>
      ChatbotResponse(reply: 'test yaniti');
}

/// Kabuk, sekmeleri araciligiyla veri katmanina dokunuyor; testte hepsi
/// Supabase'siz sahtelerle degistiriliyor.
Widget _shellUnderTest() {
  return ProviderScope(
    overrides: <Override>[
      scanHistoryRepositoryProvider
          .overrideWithValue(_FakeScanHistoryRepository()),
      profileRepositoryProvider.overrideWithValue(InMemoryProfileRepository()),
      chatbotRepositoryProvider.overrideWithValue(_FakeChatbotRepository()),
    ],
    child: const MaterialApp(
      locale: Locale('tr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ShellView(),
    ),
  );
}

void main() {
  testWidgets('oturum yoksa StartupGate auth ekranina yonlendiriyor',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AkilliSepetApp()));

    // Karar verilene kadar gate gosteriliyor.
    expect(find.byType(StartupGate), findsOneWidget);

    await tester.pumpAndSettle();

    // Testte Supabase hic baslatilmadigi icin oturum yok sayilir.
    expect(find.byType(AuthView), findsOneWidget);
    expect(find.byType(OnboardingView), findsNothing);
    expect(find.byType(ShellView), findsNothing);

    // Gate pushReplacement yapar: altinda baska bir route kalmamali, yoksa
    // kullanici geri tusuyla oturum acmadan iceri girebilir.
    final navigator = Navigator.of(tester.element(find.byType(AuthView)));
    expect(navigator.canPop(), isFalse);
  });

  // TODO(test): onboarding -> kabuk tam akis smoke testi yok. Eski testi auth
  // ilk ekran olunca gecersiz kaldi; yeniden yazilinca karsilama ekrani test
  // yuzeyinde tasiyor (RenderFlex overflow). Layout duzeltilince geri gelecek.

  testWidgets('shell 4 sekmeyi cizer ve sekme degistirir', (tester) async {
    await tester.pumpWidget(_shellUnderTest());
    await tester.pumpAndSettle();

    expect(_navLabel('Ana Sayfa'), findsOneWidget);
    expect(_navLabel('Tara'), findsOneWidget);
    expect(_navLabel('Chatbot'), findsOneWidget);
    expect(_navLabel('Profil'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    expect(
      container.read(shellViewModelProvider).currentTab,
      ShellTab.home,
    );

    await tester.tap(_navLabel('Chatbot'));
    await tester.pumpAndSettle();
    expect(
      container.read(shellViewModelProvider).currentTab,
      ShellTab.chatbot,
    );

    await tester.tap(_navLabel('Tara'));
    await tester.pumpAndSettle();
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.scan);
  });

  testWidgets('ekrani kaydirinca sekme degisiyor', (tester) async {
    await tester.pumpWidget(_shellUnderTest());
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    ShellTab currentTab() => container.read(shellViewModelProvider).currentTab;

    expect(currentTab(), ShellTab.home);

    // Sola kaydir -> bir sonraki sekme.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.scan);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.chatbot);

    // Saga kaydir -> geri.
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.scan);
  });

  testWidgets('bardan secince sayfa da o sekmeye geliyor', (tester) async {
    await tester.pumpWidget(_shellUnderTest());
    await tester.pumpAndSettle();

    await tester.tap(_navLabel('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    final controller =
        tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.page, 3.0);
  });

  testWidgets('profil dairesine dokununca profil sekmesi aciliyor',
      (tester) async {
    await tester.pumpWidget(_shellUnderTest());
    await tester.pumpAndSettle();

    // Ana Sayfa sekmesindeki daire; Chatbot sekmesininki de agacta oldugu icin
    // ilki aliniyor.
    await tester.tap(find.byType(UserAvatarCircle).first);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.profile);

    // Sekme state'i degismekle kalmiyor, sayfa da gercekten oraya kayiyor.
    final controller =
        tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.page, 3.0);
  });

  testWidgets('secili gosterge her sekmede ayni boyutta ve kayiyor',
      (tester) async {
    await tester.pumpWidget(_shellUnderTest());
    await tester.pumpAndSettle();

    // Gosterge, bar icindeki tek DecoratedBox'tir (ikon/etiket kendi arka
    // planini cizmez).
    Rect indicatorRect() => tester.getRect(
          find
              .descendant(
                of: find.byType(GlassBottomNav),
                matching: find.byType(DecoratedBox),
              )
              .last,
        );

    final first = indicatorRect();

    await tester.tap(_navLabel('Profil'));
    await tester.pumpAndSettle();
    final last = indicatorRect();

    // Boyut degismiyor — etiket uzunlugundan bagimsiz.
    expect(last.size, first.size);
    // Konum degisiyor — gosterge son sekmeye kaydi.
    expect(last.left, greaterThan(first.left));
  });
}
