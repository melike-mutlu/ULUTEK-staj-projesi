import 'package:flutter/material.dart';

import 'features/onboarding/onboarding_view.dart';
import 'features/home/home_view.dart';
import 'features/scan/scan_view.dart';
import 'features/product_detail/product_detail_view.dart';
import 'features/profile/profile_view.dart';

/// Figma Renk Paletesi
class AkilliSepetColors {
  static const Color primary = Color(0xFF26B384); // Yeşil
  static const Color primaryLight = Color(0xFFE6F9F5);
  static const Color warning = Color(0xFFFF4757); // Kırmızı (Uyarı)
  static const Color caution = Color(0xFFFFD93D); // Sarı (Dikkat)
  static const Color success = Color(0xFF27AE60); // Yeşil (Uygun)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
}

class AkilliSepetApp extends StatelessWidget {
  const AkilliSepetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Sepet',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AkilliSepetColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AkilliSepetColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AkilliSepetColors.background,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AkilliSepetColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AkilliSepetColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AkilliSepetColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AkilliSepetColors.primary,
            side:
                const BorderSide(color: AkilliSepetColors.primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/onboarding': (_) => const OnboardingView(),
        '/home': (_) => const HomeView(),
        '/scan': (_) => const ScanView(),
        '/product-detail': (_) => const ProductDetailView(),
        '/profile': (_) => const ProfileView(),
      },
    );
  }
}
