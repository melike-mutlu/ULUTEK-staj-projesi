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
    // - found/partial: WarningBanner + içindekiler + katkı maddeleri
    //   + besin değerleri + Nutri-Score
    //   (banner hazır: widgets/warning_banner.dart, level'a göre renk seçer)
    // - notFound: Figma "Urun Bulunamadi" mockup'ı
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Detay')),
      body: const FeaturePlaceholder(
        icon: Icons.inventory_2_rounded,
        title: 'Ürün Detay',
        description:
            'Taranan ürünün kişiselleştirilmiş değerlendirmesi. '
            'Bu ekranın içeriği henüz yazılmadı.',
        todos: <String>[
          'En üstte WarningBanner (widgets/warning_banner.dart) — hazır, '
              'Explanation.level\'a göre renk seçiyor',
          'Ürün adı, içindekiler, katkı maddeleri, besin değerleri, Nutri-Score',
          'Açıklama metni ve diyet notu (Explanation)',
          'Zorunlu disclaimer metnini her durumda göster',
          'status notFound / partial için ayrı boş-durum görünümleri',
        ],
      ),
    );
  }
}
