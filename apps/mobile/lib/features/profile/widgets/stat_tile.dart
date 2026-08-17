import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// One metric tile: icon, value, and a wrapping label. Shared by the profile
/// stats row and the stats detail screen so both stay visually identical and
/// theme-aware.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final valueColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 22, color: AppColors.brand),
          const SizedBox(height: 8),
          Text('$value', style: AppTextStyles.heading2.copyWith(color: valueColor)),
          const SizedBox(height: 4),
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
