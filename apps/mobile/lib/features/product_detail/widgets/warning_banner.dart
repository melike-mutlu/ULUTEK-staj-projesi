import 'package:flutter/material.dart';

import '../../../core/models/explanation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Ürün detay ekranının en üstündeki kişisel uyarı bandı.
/// Figma mockup'larındaki 3 duruma karşılık gelir: Kırmızı / Sarı / Yeşil.
/// Üç ayrı widget yerine tek widget, `level`'a göre renk/metin değiştirir.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key, required this.explanation});

  final Explanation explanation;

  Color _backgroundColor() {
    switch (explanation.level) {
      case WarningLevel.warning:
        return AppColors.warning;
      case WarningLevel.caution:
        return AppColors.caution;
      case WarningLevel.ok:
        return AppColors.ok;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: _backgroundColor(),
      child: Text(
        explanation.warningMessage,
        style: AppTextStyles.bannerMessage,
      ),
    );
  }
}
