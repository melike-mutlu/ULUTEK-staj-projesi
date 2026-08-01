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
      // Sağ üstteki "DEBUG" şeridi görünmesin.
      debugShowCheckedModeBanner: false,
      // Renk ve tipografi tek kaynaktan: lib/core/theme/
      // Ekranlarda renk/font hardcode edilmez, AppColors / AppTextStyles kullanılır.
      theme: AppTheme.light,
      // Route adları ve ekran eşleşmeleri tek kaynaktan: lib/core/navigation/
      //
      // `initialRoute` yerine `home`: açılış hedefi oturuma göre değiştiği için
      // kararı StartupGate veriyor. `home` ayrıca app_routes.dart'ta anlatılan
      // "initialRoute route yığınını ikiye böler" tuzağını da tamamen atlatır.
      home: const StartupGate(),
      routes: AppRoutes.table,
    );
  }
}
