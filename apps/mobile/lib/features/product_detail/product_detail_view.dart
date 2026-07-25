import 'package:flutter/material.dart';

import 'widgets/warning_banner.dart';

/// Figma: "Ürün Detay Kırmızı/Sarı/Yeşil" mockup'ları — tek View, ViewModel
/// durumuna göre farklı içerik gösterir (ayrı ayrı 3 ekran değil).
class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ProductDetailViewModel'i dinle, status'e göre:
    // - loading: yükleniyor göstergesi
    // - found/partial: WarningBanner + içindekiler + katkı maddeleri
    //   + besin değerleri + Nutri-Score (bkz. widgets/warning_banner.dart)
    // - notFound: Figma "Urun Bulunamadi" mockup'ı
    return const Scaffold(
      body: Center(child: Text('Ürün Detay')),
    );
  }
}
