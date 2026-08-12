import 'package:flutter/material.dart';

import '../../../core/constants/allergen_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/models/rule_engine_result.dart';
import '../../../l10n/app_localizations.dart';
import 'detail_section.dart';
import 'personal_risks_section.dart';

/// Allergens the product contains but the user's profile does not flag.
/// Quiet on purpose: informative, never alarming.
class OtherAllergensSection extends StatelessWidget {
  const OtherAllergensSection({
    super.key,
    required this.product,
    required this.ruleEngineResult,
  });

  final Product product;
  final RuleEngineResult? ruleEngineResult;

  List<AllergenInfo> _others() {
    final result = ruleEngineResult;

    // Older backend responses have no canonical keys; fall back to raw tags.
    final keys = result != null && result.allergens.isNotEmpty
        ? result.detectedOnlyKeys
        : product.allergensTags;

    final riskLabels = (result?.personalRiskKeys ?? const <String>[])
        .map((key) => allergenInfo(key).label)
        .toSet();

    return keys
        .map(allergenInfo)
        .where((info) => !riskLabels.contains(info.label))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final others = _others();
    if (others.isEmpty) return const SizedBox.shrink();

    return DetailSection(
      title: l10n.otherAllergensTitle,
      meta: l10n.notInYourProfile,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 20,
              runSpacing: 14,
              children: [
                for (final allergen in others)
                  _AllergenItem(
                    allergen: allergen,
                    label: allergenLabel(l10n, allergen),
                    maxWidth: constraints.maxWidth,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AllergenItem extends StatelessWidget {
  const _AllergenItem({
    required this.allergen,
    required this.label,
    required this.maxWidth,
  });

  final AllergenInfo allergen;
  final String label;

  /// Wrap gives children unbounded width; without a bound a long label would
  /// silently paint outside the section instead of wrapping to a new line.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AllergenIcon(asset: allergen.asset, size: 44),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
