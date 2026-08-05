import 'package:flutter/material.dart';

import '../../../core/constants/allergen_catalog.dart';
import '../../../core/models/explanation.dart';
import '../../../core/models/rule_engine_result.dart';
import 'detail_section.dart';
import 'status_dot.dart';

/// Allergens that clash with the user's own profile. Renders nothing when
/// there is no personal risk — the verdict banner already says so.
class PersonalRisksSection extends StatelessWidget {
  const PersonalRisksSection({super.key, required this.ruleEngineResult});

  final RuleEngineResult? ruleEngineResult;

  @override
  Widget build(BuildContext context) {
    final risks =
        (ruleEngineResult?.personalRiskKeys ?? const <String>[])
            .map(allergenInfo)
            .toList();
    if (risks.isEmpty) return const SizedBox.shrink();

    // The section carries its own bottom gap: when it hides, the screen's
    // column must not keep an empty space where it used to be.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DetailSection(
        title: 'Senin için riskler',
        subtitle: '${risks.length} alerjen',
        child: Column(
          children: [
            for (final risk in risks) _RiskRow(allergen: risk),
          ],
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.allergen});

  final AllergenInfo allergen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _AllergenIcon(asset: allergen.asset),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allergen.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Profilindeki alerjilerle çakışıyor',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const StatusDot(level: WarningLevel.warning),
        ],
      ),
    );
  }
}

class _AllergenIcon extends StatelessWidget {
  const _AllergenIcon({required this.asset});

  final String asset;

  static const double _size = 34;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: _size,
      height: _size,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.warning_amber_rounded,
        size: _size,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}
