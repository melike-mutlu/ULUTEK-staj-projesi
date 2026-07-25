/// docs/architecture.md — Sözleşme 1 (`fetch-product`) yanıtındaki "rule_engine_result".
class RuleEngineResult {
  final List<String> matchedAllergens;
  final bool hasConflict;
  final bool veganCompatible;
  final String? diabeticNote;

  const RuleEngineResult({
    required this.matchedAllergens,
    required this.hasConflict,
    required this.veganCompatible,
    this.diabeticNote,
  });

  factory RuleEngineResult.fromJson(Map<String, dynamic> json) {
    final dietFlags = json['diet_flags'] as Map<String, dynamic>? ?? {};
    return RuleEngineResult(
      matchedAllergens: (json['matched_allergens'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      hasConflict: json['has_conflict'] as bool? ?? false,
      veganCompatible: dietFlags['vegan_compatible'] as bool? ?? true,
      diabeticNote: dietFlags['diabetic_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched_allergens': matchedAllergens,
      'has_conflict': hasConflict,
      'diet_flags': {
        'vegan_compatible': veganCompatible,
        'diabetic_note': diabeticNote,
      },
    };
  }
}
