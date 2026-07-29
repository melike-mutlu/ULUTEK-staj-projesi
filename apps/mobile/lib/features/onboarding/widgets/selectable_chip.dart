import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Onboarding seçim ekranlarındaki tek çip. Etiket + sol noktadan oluşur;
/// "+" hâli için [SelectableChip.add] kullanılır (nokta/etiket yerine tek ikon).
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : _isAdd = false;

  const SelectableChip.add({super.key, required this.onTap})
      : label = '',
        isSelected = false,
        _isAdd = true;

  static const double _radius = 18;
  static const EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const double _dotSize = 10;
  static const double _dotGap = 10;
  static const double _borderWidth = 2;

  final String label;
  final bool isSelected;
  final bool _isAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Seçili değilken de şeffaf 2px kenarlık çizilir; yoksa seçilince kenarlık
    // eklenmesi çipin boyutunu değiştirip zıplamasına yol açar.
    final borderColor =
        isSelected ? AppColors.chipSelectedBorder : Colors.transparent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: AppColors.onboardingSurface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: borderColor, width: _borderWidth),
            ),
            child: _isAdd
                ? const Icon(Icons.add, color: AppColors.textPrimary)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.chipSelectedDot
                              : AppColors.chipDot,
                        ),
                      ),
                      const SizedBox(width: _dotGap),
                      // Flexible: uzun etiketler (ör. "Kabuklu deniz
                      // ürünleri") dar ekranda taşmak yerine sarar.
                      Flexible(
                        child: Text(label, style: AppTextStyles.chipLabel),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
