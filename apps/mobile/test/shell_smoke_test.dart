import 'package:akilli_sepet/app.dart';
import 'package:akilli_sepet/features/onboarding/onboarding_view.dart';
import 'package:akilli_sepet/features/onboarding/widgets/onboarding_primary_button.dart';
import 'package:akilli_sepet/features/profile/profile_view.dart';
import 'package:akilli_sepet/features/shell/shell_view.dart';
import 'package:akilli_sepet/features/shell/shell_viewmodel.dart';
import 'package:akilli_sepet/features/shell/widgets/glass_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:akilli_sepet/features/auth/auth_view.dart';

/// Sekme etiketi hem AppBar basliginda hem barda gecebiliyor; dokunusun
/// bardaki etikete gittiginden emin olmak icin arama bar icinde yapiliyor.
Finder _navLabel(String label) => find.descendant(
      of: find.byType(GlassBottomNav),
      matching: find.text(label),
    );

void main() {
  testWidgets('uygulama auth ile aciliyor', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AkilliSepetApp()));
    await tester.pumpAndSettle();

    expect(find.byType(AuthView), findsOneWidget);
    expect(find.byType(ShellView), findsNothing);
  });

  testWidgets('shell 4 sekmeyi cizer ve sekme degistirir', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShellView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(_navLabel('Ana Sayfa'), findsOneWidget);
    expect(_navLabel('Tara'), findsOneWidget);
    expect(_navLabel('Geçmiş'), findsOneWidget);
    expect(_navLabel('Profil'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    expect(
      container.read(shellViewModelProvider).currentTab,
      ShellTab.dashboard,
    );

    await tester.tap(_navLabel('Geçmiş'));
    await tester.pumpAndSettle();
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.home);

    await tester.tap(_navLabel('Tara'));
    await tester.pumpAndSettle();
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.scan);
  });

  testWidgets('ekrani kaydirinca sekme degisiyor', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShellView()),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    ShellTab currentTab() => container.read(shellViewModelProvider).currentTab;

    expect(currentTab(), ShellTab.dashboard);

    // Sola kaydir -> bir sonraki sekme.
    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.scan);

    await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.home);

    // Saga kaydir -> geri.
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await tester.pumpAndSettle();
    expect(currentTab(), ShellTab.scan);
  });

  testWidgets('bardan secince sayfa da o sekmeye geliyor', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShellView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_navLabel('Profil'));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileView), findsOneWidget);
    final controller =
        tester.widget<PageView>(find.byType(PageView)).controller!;
    expect(controller.page, 3.0);
  });

  testWidgets('secili gosterge her sekmede ayni boyutta ve kayiyor',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShellView()),
      ),
    );
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
