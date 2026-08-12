import 'package:flutter/material.dart';

import '../../../core/constants/allergen_catalog.dart';
import '../../../core/models/explanation.dart';
import '../../../core/models/rule_engine_result.dart';
import '../../../l10n/app_localizations.dart';
import 'detail_row.dart';
import 'detail_section.dart';
import 'section_note.dart';

const String _assetDir = 'assets/allergens';

/// "Alerjiler" — allergens that clash with the user's own profile.
/// Always visible: when there is no clash it says so in one line.
class PersonalRisksSection extends StatelessWidget {
  const PersonalRisksSection({super.key, required this.ruleEngineResult});

  final RuleEngineResult? ruleEngineResult;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final risks = (ruleEngineResult?.personalRiskKeys ?? const <String>[])
        .map(allergenInfo)
        .toList();

    // Without allergen data an empty risk list is not proof of safety.
    if (risks.isEmpty && ruleEngineResult?.hasSufficientData == false) {
      return DetailSection(
        title: l10n.allergiesTitle,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const AllergenIcon(asset: '$_assetDir/nope.png'),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.insufficientAllergenInfo,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF6B7280),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return DetailSection(
      title: l10n.allergiesTitle,
      meta: risks.isEmpty ? null : l10n.warningsCount(risks.length),
      children: risks.isEmpty
          ? [SectionNote(text: l10n.noProfileAllergens)]
          : [
              for (final risk in risks)
                DetailRow(
                  leading: AllergenIcon(asset: risk.asset),
                  title: allergenLabel(l10n, risk),
                  subtitle: l10n.conflictsWithAllergies,
                  level: WarningLevel.warning,
                ),
            ],
    );
  }
}

/// Allergen png with a graceful fallback when the asset is missing.
class AllergenIcon extends StatelessWidget {
  const AllergenIcon({super.key, required this.asset, this.size = 60});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      errorBuilder: (_, __, ___) => Icon(
        Icons.warning_amber_rounded,
        size: size,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}
