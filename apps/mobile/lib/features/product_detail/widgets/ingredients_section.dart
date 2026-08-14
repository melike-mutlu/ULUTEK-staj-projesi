import 'package:flutter/material.dart';

import '../../../core/models/additive_info.dart';
import '../../../core/models/product.dart';
import '../../../l10n/app_localizations.dart';
import 'additive_info_sheet.dart';
import 'detail_section.dart';

/// Ingredients text and additives. Collapsed by default so a long ingredient
/// list does not push the personal information off the screen.
class IngredientsSection extends StatefulWidget {
  const IngredientsSection({
    super.key,
    required this.product,
    this.additivesDetails = const [],
  });

  final Product product;

  /// Backend's plain-language info per additive (fetch-product's
  /// additives_details). Falls back to AdditiveInfo.getMockInfo when a code
  /// has no match here (e.g. backend not deployed yet).
  final List<AdditiveInfo> additivesDetails;

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
                      _AdditiveChip(
                        code: additive,
                        additivesDetails: widget.additivesDetails,
                      ),
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
  const _AdditiveChip({required this.code, this.additivesDetails = const []});

  final String code;
  final List<AdditiveInfo> additivesDetails;

  @override
  Widget build(BuildContext context) {
    final cleanCode = code.replaceFirst(RegExp('^[a-z]{2}:'), '').toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final info = additivesDetails
              .cast<AdditiveInfo?>()
              .firstWhere(
                (a) => a?.code.toUpperCase() == cleanCode,
                orElse: () => null,
              ) ??
              AdditiveInfo.getMockInfo(code);
          AdditiveInfoSheet.show(context, info);
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cleanCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D4ED8),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'i',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D4ED8),
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

