import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_viewmodel.dart';
import 'features/startup/startup_gate.dart';

class AkilliSepetApp extends ConsumerWidget {
  const AkilliSepetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeViewModel = ref.watch(themeViewModelProvider);

    return MaterialApp(
      title: 'Akıllı Sepet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeViewModel.themeMode,
      home: const StartupGate(),
      routes: AppRoutes.table,
    );
  }
}
