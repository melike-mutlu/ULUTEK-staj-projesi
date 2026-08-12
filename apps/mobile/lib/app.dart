import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/startup/startup_gate.dart';

class AkilliSepetApp extends StatelessWidget {
  const AkilliSepetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Sepet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      
      home: const StartupGate(),
      routes: AppRoutes.table,
    );
  }
}
