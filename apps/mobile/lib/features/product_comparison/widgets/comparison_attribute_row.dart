import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';
import '../../../core/theme/app_colors.dart';

/// Karşılaştırma matrisindeki her bir nitelik grubu satırı.
/// Başlık (ör. Nutri-Score, Kalori, Alerjenler) ve altında yan yana 2-3 hücreyi barındırır.
class ComparisonAttributeRow extends StatelessWidget {
  const ComparisonAttributeRow({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.badgeText,
    this.badgeColor,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final String? badgeText;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AkilliSepetColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Satır Başlık Alanı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AkilliSepetColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AkilliSepetColors.textPrimary,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? AkilliSepetColors.primary)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor ?? AkilliSepetColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : AkilliSepetColors.divider,
          ),

          // Yan yana Hücreler (2 veya 3 Kolon)
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children.map((cell) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: cell,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
