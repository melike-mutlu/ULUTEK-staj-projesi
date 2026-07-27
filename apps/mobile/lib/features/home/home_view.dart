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
    // TODO: Son taranan ürünleri listele; bir satıra dokununca
    // AppRoutes.productDetail'e ürünü argüman olarak geçir.
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş')),
      body: const FeaturePlaceholder(
        icon: Icons.history_rounded,
        title: 'Geçmiş',
        description:
            'Daha önce taranan ürünlerin listesi. Bu ekranın içeriği henüz yazılmadı.',
        todos: <String>[
          'Son taranan ürünler listesi (ürün adı, tarih, uyarı seviyesi rozeti)',
          'Satıra dokununca AppRoutes.productDetail\'e ürünle birlikte git',
          'Hiç tarama yoksa boş-durum görünümü',
          'HomeViewModel: geçmiş kaydını tutar ve okur',
        ],
      ),
    );
  }
}
