import 'package:akilli_sepet/features/shell/shell_view.dart';
import 'package:akilli_sepet/features/shell/shell_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shell 4 sekmeyi cizer ve sekme degistirir', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShellView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsWidgets);
    expect(find.text('Tara'), findsOneWidget);
    expect(find.text('Geçmiş'), findsOneWidget);
    expect(find.text('Profil'), findsWidgets);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ShellView)),
    );
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.dashboard);

    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.home);

    await tester.tap(find.text('Tara'));
    await tester.pumpAndSettle();
    expect(container.read(shellViewModelProvider).currentTab, ShellTab.scan);
  });
}
