import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_routes.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_viewmodel.dart';
import 'features/startup/startup_gate.dart';
import 'l10n/app_localizations.dart';

class AkilliSepetApp extends ConsumerWidget {
  const AkilliSepetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeViewModel = ref.watch(themeViewModelProvider);
    final locale = ref.watch(localeControllerProvider).locale;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeViewModel.themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const StartupGate(),
      routes: AppRoutes.table,
    );
  }
}
