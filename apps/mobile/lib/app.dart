import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';

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
      initialRoute: AppRoutes.onboarding,
      routes: AppRoutes.table,
    );
  }
}
