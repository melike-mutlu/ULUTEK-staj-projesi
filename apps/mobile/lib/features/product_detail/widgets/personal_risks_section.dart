import 'package:flutter/material.dart';

import '../../../core/constants/allergen_catalog.dart';
import '../../../core/models/explanation.dart';
import '../../../core/models/rule_engine_result.dart';
import 'detail_row.dart';
import 'detail_section.dart';
import 'section_note.dart';

/// "Alerjiler" — allergens that clash with the user's own profile.
/// Always visible: when there is no clash it says so in one line.
class PersonalRisksSection extends StatelessWidget {
  const PersonalRisksSection({super.key, required this.ruleEngineResult});

  final RuleEngineResult? ruleEngineResult;

  @override
  Widget build(BuildContext context) {
    final risks = (ruleEngineResult?.personalRiskKeys ?? const <String>[])
        .map(allergenInfo)
        .toList();

    // Without allergen data an empty risk list is not proof of safety.
    if (risks.isEmpty && ruleEngineResult?.hasSufficientData == false) {
      return const DetailSection(
        title: 'Alerjiler',
        children: [
          SectionNote(
            text: 'Bu ürünün içerik bilgisi eksik, alerjen kontrolü '
                'yapılamadı. Ambalajdaki etiketi kontrol et.',
          ),
        ],
      );
    }

    return DetailSection(
      title: 'Alerjiler',
      meta: risks.isEmpty ? null : '${risks.length} uyarı',
      children: risks.isEmpty
          ? const [
              SectionNote(
                  text: 'Profilindeki alerjenlerin hiçbiri bu üründe yok.')
            ]
          : [
              for (final risk in risks)
                DetailRow(
                  leading: AllergenIcon(asset: risk.asset),
                  title: risk.label,
                  subtitle: 'Profilindeki alerjilerle çakışıyor',
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
