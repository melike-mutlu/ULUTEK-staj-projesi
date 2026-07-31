import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'question_card.dart';
import 'selectable_chip.dart';

/// Title + multi-select chips, shared by the onboarding step and the profile
/// form. Holds no state; selections, options and the expand decision come from
/// the caller.
///
/// Drawn at natural height (no `Expanded`) — scrolling is the caller's call:
/// onboarding wraps one group in its scroll view, profile stacks three.
class SelectionChipGroup extends StatelessWidget {
  const SelectionChipGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
    this.onAddCustom,
    this.canAddCustom = true,
    this.titlePadding = EdgeInsets.zero,
    this.titleInCard = true,
    this.chipStyle = SelectableChipStyle.onboarding,
    this.alignment = WrapAlignment.center,
    this.selectedFirst = false,
    this.visibleCount,
    this.onShowAll,
    this.showAllLabel = 'Tümünü gör',
  });

  final String title;

  /// Catalog options + options the user added with "+".
  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  /// When null the "+" chip is hidden (e.g. the profile diet card: a label
  /// outside the catalog has no database counterpart).
  final ValueChanged<String>? onAddCustom;

  /// False draws the "+" chip disabled instead of hiding it, so the action
  /// stays discoverable (e.g. single-select diet with a choice already made).
  final bool canAddCustom;

  /// Padding around the title only — chips are unaffected (onboarding uses a
  /// left inset to line the title up with the progress bar).
  final EdgeInsets titlePadding;

  /// true → title inside a white [QuestionCard], false → plain text.
  final bool titleInCard;

  final SelectableChipStyle chipStyle;
  final WrapAlignment alignment;

  /// Draw selected chips before the unselected ones, each keeping its relative
  /// order. Also guarantees the selection stays visible while truncated.
  final bool selectedFirst;

  /// How many chips to show; null shows all. When truncated and [onShowAll] is
  /// set, a "show all" link is drawn below.
  final int? visibleCount;
  final VoidCallback? onShowAll;
  final String showAllLabel;

  static const double _gap = 20;

  Future<void> _openAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Seçenek ekle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (String value) => Navigator.pop(dialogContext, value),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
    if (result != null) onAddCustom?.call(result);
  }

  /// Pastel is keyed on the option's position in [options], never on the drawn
  /// position, so [selectedFirst] reordering doesn't reshuffle the colours.
  Color _pastelFor(String option) =>
      AppColors.chipPastels[options.indexOf(option) %
          AppColors.chipPastels.length];

  @override
  Widget build(BuildContext context) {
    final ordered = selectedFirst
        ? <String>[
            ...options.where(selected.contains),
            ...options.where((String option) => !selected.contains(option)),
          ]
        : options;

    final limit = visibleCount;
    final bool isTruncated = limit != null && limit < ordered.length;
    final visibleOptions = isTruncated ? ordered.take(limit) : ordered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: titlePadding,
          child: titleInCard
              ? QuestionCard(question: title)
              : Text(title, style: AppTextStyles.profileCardTitle),
        ),
        const SizedBox(height: _gap),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: alignment,
          children: <Widget>[
            for (final String option in visibleOptions)
              SelectableChip(
                label: option,
                isSelected: selected.contains(option),
                style: chipStyle,
                selectedColor: _pastelFor(option),
                onTap: () => onToggle(option),
              ),
            // "+" only makes sense once the list is fully expanded; while
            // truncated the user opens it with "show all" first.
            if (onAddCustom != null && !isTruncated)
              SelectableChip.add(
                style: chipStyle,
                enabled: canAddCustom,
                onTap: () => _openAddDialog(context),
              ),
          ],
        ),
        if (isTruncated && onShowAll != null) ...<Widget>[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onShowAll,
              child: Text(showAllLabel, style: AppTextStyles.profileLink),
            ),
          ),
        ],
      ],
    );
  }
}
