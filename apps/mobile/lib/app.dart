import 'package:flutter/material.dart';

import 'features/onboarding/onboarding_view.dart';
import 'features/home/home_view.dart';
import 'features/scan/scan_view.dart';
import 'features/product_detail/product_detail_view.dart';
import 'features/profile/profile_view.dart';

class AkilliSepetApp extends StatelessWidget {
  const AkilliSepetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akıllı Sepet',
      // TODO: Figma'daki renk paleti ve tipografiye göre ThemeData tanımla
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/onboarding',
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
