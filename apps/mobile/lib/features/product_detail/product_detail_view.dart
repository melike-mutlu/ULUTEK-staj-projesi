import 'package:flutter/material.dart';

import '../../core/widgets/feature_placeholder.dart';

/// Figma: "Ürün Detay Kırmızı/Sarı/Yeşil" mockup'ları — tek View, ViewModel
/// durumuna göre farklı içerik gösterir (ayrı ayrı 3 ekran değil).
///
/// Şimdilik tam ekran route (AppRoutes.productDetail); bottom-sheet'e çevirme
/// kararı sonraya bırakıldı.
class ProductDetailView extends StatelessWidget {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ProductDetailViewModel'i dinle, status'e göre:
    // - loading: yükleniyor göstergesi
    // - found/partial: en üstte WarningBanner (widgets/warning_banner.dart —
    //   hazır, Explanation.level'a göre renk seçiyor), ardından ürün adı,
    //   içindekiler, katkı maddeleri, besin değerleri, Nutri-Score,
    //   açıklama metni ve diyet notu
    // - notFound: Figma "Urun Bulunamadi" mockup'ı
    //
    // Zorunlu disclaimer metni her durumda gösterilmeli.
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detay')),
      body: const FeaturePlaceholder(icon: Icons.inventory_2_rounded),
    );
  }
}
