import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/selectable_chip.dart';
import '../../../shared/widgets/selection_chip_group.dart';

/// One category card in the profile form: a white card on the grey scaffold,
/// holding a title + chips. The shared [SelectionChipGroup] draws the content;
/// this widget only supplies the card shell and the profile variant settings.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
    required this.isExpanded,
    required this.onShowAll,
    this.onAddCustom,
    this.canAddCustom = true,
  });

  final String title;
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  /// Whether the card is expanded — collapsed shows only [_collapsedCount].
  final bool isExpanded;
  final VoidCallback onShowAll;

  /// When null the "+" chip is hidden.
  final ValueChanged<String>? onAddCustom;

  /// False keeps the "+" chip visible but disabled.
  final bool canAddCustom;

  /// Chips shown while the card is collapsed.
  static const int _collapsedCount = 8;

  static const double _radius = 20;
  static const EdgeInsets _padding = EdgeInsets.all(20);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;

    return Container(
      width: double.infinity,
      padding: _padding,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: SelectionChipGroup(
        title: title,
        titleInCard: false,
        chipStyle: SelectableChipStyle.profile,
        alignment: WrapAlignment.start,
        selectedFirst: true,
        options: options,
        selected: selected,
        onToggle: onToggle,
        onAddCustom: onAddCustom,
        canAddCustom: canAddCustom,
        visibleCount: isExpanded ? null : _collapsedCount,
        onShowAll: onShowAll,
      ),
    );
  }
}
