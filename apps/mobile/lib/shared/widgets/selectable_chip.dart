import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Chip appearance variant. Behaviour is identical; only surface, label and
/// metrics differ.
enum SelectableChipStyle {
  /// Onboarding: white surface, leading dot, border when selected.
  onboarding,

  /// Profile: grey surface + black label, pastel when selected, no dot.
  profile,
}

/// A single chip in multi-select surfaces (shared by onboarding + profile).
/// Use [SelectableChip.add] for the "+" variant (icon instead of a label).
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.style = SelectableChipStyle.onboarding,
    this.selectedColor,
  }) : _isAdd = false;

  const SelectableChip.add({
    super.key,
    required this.onTap,
    this.style = SelectableChipStyle.onboarding,
  })  : label = '',
        isSelected = false,
        selectedColor = null,
        _isAdd = true;

  static const double _radius = 18;
  static const EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const EdgeInsets _profilePadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  static const double _dotSize = 10;
  static const double _dotGap = 10;
  static const double _borderWidth = 2;

  final String label;
  final bool isSelected;
  final bool _isAdd;
  final VoidCallback onTap;
  final SelectableChipStyle style;

  /// Selected surface colour in the profile variant; falls back to the first
  /// pastel (see [AppColors.chipPastels]).
  final Color? selectedColor;

  bool get _isProfile => style == SelectableChipStyle.profile;

  Color get _background {
    if (!_isProfile) return AppColors.onboardingSurface;
    if (!isSelected) return AppColors.chipUnselected;
    return selectedColor ?? AppColors.chipPastels.first;
  }

  @override
  Widget build(BuildContext context) {
    // A transparent 2px border is drawn even when unselected; otherwise adding
    // the border on selection would resize the chip and make it jump.
    final borderColor = isSelected && !_isProfile
        ? AppColors.chipSelectedBorder
        : Colors.transparent;

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: Material(
        color: _background,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: _isProfile ? _profilePadding : _padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(color: borderColor, width: _borderWidth),
            ),
            child: _isAdd
                ? const Icon(Icons.add, color: AppColors.textPrimary)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (!_isProfile) ...<Widget>[
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
                      ],
                      // Flexible: long labels wrap on narrow screens instead
                      // of overflowing.
                      Flexible(
                        child: Text(
                          label,
                          style: _isProfile
                              ? AppTextStyles.profileChipLabel
                              : AppTextStyles.chipLabel,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
