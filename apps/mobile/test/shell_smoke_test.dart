import 'package:akilli_sepet/features/shell/shell_view.dart';
import 'package:akilli_sepet/features/shell/shell_viewmodel.dart';
import 'package:akilli_sepet/features/shell/widgets/glass_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sekme etiketi hem AppBar basliginda hem barda gecebiliyor; dokunusun
/// bardaki etikete gittiginden emin olmak icin arama bar icinde yapiliyor.
Finder _navLabel(String label) => find.descendant(
      of: find.byType(GlassBottomNav),
      matching: find.text(label),
    );

void main() {
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
