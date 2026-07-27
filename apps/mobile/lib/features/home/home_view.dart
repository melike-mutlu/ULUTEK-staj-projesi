import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Geçmiş — alt navigasyonun 3. sekmesi: son taranan ürünlerin listesi.
///
/// Klasör adı `home`, docs/flutter-mimari.md'deki yapı korunsun diye
/// değiştirilmedi; sekmedeki görünen adı "Geçmiş".
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Geçmiş içeriği:
    // - Son taranan ürünler listesi (ürün adı, tarih, uyarı seviyesi rozeti)
    // - Satıra dokununca AppRoutes.productDetail'e ürünle birlikte git
    // - Hiç tarama yoksa boş-durum görünümü
    // - HomeViewModel: geçmiş kaydını tutar ve okur
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
      body: const FeaturePlaceholder(icon: Icons.history_rounded),
    );
  }
}
