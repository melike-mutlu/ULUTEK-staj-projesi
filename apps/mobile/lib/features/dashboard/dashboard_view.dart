import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/widgets/feature_placeholder.dart';

/// Ana Sayfa — alt navigasyonun 1. sekmesi.
///
/// Geçmiş sekmesi (`features/home`) son taranan ürünleri listeler; burası
/// uygulamanın karşılama ekranı: selamlama, büyük "Tara" çağrısı, profil özeti.
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Ana Sayfa içeriği:
    // - Figma "Ana Ekran" mockup'ına göre selamlama ve profil özeti
    // - Büyük "Tara" çağrısı -> AppRoutes.scan
    // - DashboardViewModel: selamlama metni ve profil özeti verisi
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: FeaturePlaceholder(
        icon: Icons.home_rounded,
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.scan),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Barkod Tara'),
        ),
      ),
    );
  }
}
