import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/app_colors.dart';

/// Karşılaştırma ekranındaki her bir ürünün üst başlık kartı.
/// Ürün görseli, ismi, markası, silme ve değiştirme aksiyonlarını barındırır.
class ComparisonColumnHeader extends StatelessWidget {
  const ComparisonColumnHeader({
    super.key,
    this.product,
    this.onRemove,
    this.onReplace,
    this.onAdd,
    required this.columnIndex,
  });

  final Product? product;
  final VoidCallback? onRemove;
  final VoidCallback? onReplace;
  final VoidCallback? onAdd;
  final int columnIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Boş Sütun (+ Ürün Ekle Kartı)
    if (product == null) {
      return InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 170,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceMuted
                : AkilliSepetColors.primaryLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AkilliSepetColors.primary.withOpacity(0.4),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AkilliSepetColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${columnIndex + 1}. Ürünü Ekle',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AkilliSepetColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Karşılaştır',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AkilliSepetColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Dolu Ürün Kartı
    return Container(
      height: 170,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceMuted : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AkilliSepetColors.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Aksiyon Barı (Çıkar / Değiştir)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AkilliSepetColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Ürün #${columnIndex + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AkilliSepetColors.primary,
                    ),
                  ),
                ),
              ),
              if (onReplace != null)
                InkWell(
                  onTap: onReplace,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AkilliSepetColors.textSecondary,
                    ),
                  ),
                ),
              if (onRemove != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AkilliSepetColors.warning,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Ürün Görseli & İsim
          Center(
            child: Container(
              height: 58,
              width: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark ? Colors.black26 : Colors.grey.shade50,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product!.imageUrl != null && product!.imageUrl!.isNotEmpty
                    ? Image.network(
                        product!.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.fastfood_rounded,
                          color: AkilliSepetColors.primary,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.fastfood_rounded,
                        color: AkilliSepetColors.primary,
                        size: 28,
                      ),
              ),
            ),
          ),

          const Spacer(),

          // Marka & İsim
          Text(
            product!.brand ?? 'Bilinmeyen Marka',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AkilliSepetColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product!.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              height: 1.15,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AkilliSepetColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
