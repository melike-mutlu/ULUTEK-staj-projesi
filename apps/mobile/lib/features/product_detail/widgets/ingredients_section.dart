import 'package:flutter/material.dart';

import '../../../core/models/product.dart';
import '../../../l10n/app_localizations.dart';
import 'detail_section.dart';

/// Ingredients text and additives. Collapsed by default so a long ingredient
/// list does not push the personal information off the screen.
class IngredientsSection extends StatefulWidget {
  const IngredientsSection({super.key, required this.product});

  final Product product;

  @override
  State<IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  static const int _collapsedLines = 3;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = widget.product.ingredientsText.trim();
    final additives = widget.product.additives;

    if (text.isEmpty && additives.isEmpty) return const SizedBox.shrink();

    return DetailSection(
      title: l10n.ingredientsTitle,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (additives.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final additive in additives)
                      _AdditiveChip(code: additive),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              if (text.isEmpty)
                Text(
                  l10n.noIngredientsInfo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                    fontStyle: FontStyle.italic,
                  ),
                )
              else ...[
                Text(
                  text,
                  maxLines: _expanded ? null : _collapsedLines,
                  overflow: _expanded ? null : TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _expanded ? l10n.showLess : l10n.showAllText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF26B384),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: const Color(0xFF26B384),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AdditiveChip extends StatelessWidget {
  const _AdditiveChip({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        code.replaceFirst(RegExp('^[a-z]{2}:'), '').toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1D4ED8),
        ),
      ),
    );
  }
}
