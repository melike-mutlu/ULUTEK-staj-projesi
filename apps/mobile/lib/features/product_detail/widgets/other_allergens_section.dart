import 'package:flutter/material.dart';

import '../../../core/constants/allergen_catalog.dart';
import '../../../core/models/product.dart';
import '../../../core/models/rule_engine_result.dart';
import 'detail_section.dart';

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
    final others = _others();
    if (others.isEmpty) return const SizedBox.shrink();

    // Carries its own bottom gap, like PersonalRisksSection.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DetailSection(
        title: 'Diğer alerjenler',
        subtitle: 'profilinde yok',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final allergen in others) _AllergenChip(allergen: allergen),
          ],
        ),
      ),
    );
  }
}

class _AllergenChip extends StatelessWidget {
  const _AllergenChip({required this.allergen});

  final AllergenInfo allergen;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      // Wrap gives children unbounded width; without this a long label would
      // silently paint outside the card instead of wrapping.
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.7,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              allergen.asset,
              width: 18,
              height: 18,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                allergen.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
