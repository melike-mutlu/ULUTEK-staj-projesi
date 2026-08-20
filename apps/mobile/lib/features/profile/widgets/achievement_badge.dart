import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A single achievement: a round icon that reads as unlocked (branded) or
/// locked (muted), with a wrapping label beneath. Sizes to its parent so a
/// [Wrap] of these reflows across screen widths.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.unlocked,
    required this.width,
  });

  final IconData icon;
  final String label;
  final bool unlocked;
  final double width;

  static const double _circleSize = 56;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lockedBg =
        isDark ? AppColors.darkSurfaceMuted : AppColors.surfaceMuted;
    final lockedFg =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final unlockedBg = isDark
        ? AppColors.brand.withValues(alpha: 0.18)
        : AppColors.brandSoft;
    final labelColor = unlocked
        ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
        : lockedFg;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: _circleSize,
            height: _circleSize,
            decoration: BoxDecoration(
              color: unlocked ? unlockedBg : lockedBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? icon : Icons.lock_outline_rounded,
              size: 26,
              color: unlocked ? AppColors.brand : lockedFg,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: labelColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
