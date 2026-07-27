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
    // TODO: Figma "Ana Ekran" mockup'ına göre karşılama içeriğini kur.
    // State için DashboardViewModel kullanılacak (şu an boş).
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: FeaturePlaceholder(
        icon: Icons.home_rounded,
        title: 'Ana Sayfa',
        description:
            'Kullanıcıyı karşılayan giriş ekranı. Bu ekranın içeriği henüz yazılmadı.',
        todos: const <String>[
          'Figma "Ana Ekran" mockup\'ına göre selamlama ve profil özeti',
          'Büyük "Tara" çağrısı — AppRoutes.scan\'e yönlendirir',
          'DashboardViewModel: selamlama metni ve profil özeti verisi',
        ],
        action: ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.scan),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Barkod Tara'),
        ),
      ),
    );
  }
}
