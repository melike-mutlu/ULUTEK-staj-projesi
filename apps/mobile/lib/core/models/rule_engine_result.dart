/// Bir üründe bulunan alerjen. [matched] true ise kullanıcının profiliyle
/// çakışıyor, false ise sadece üründe tespit edilmiş demektir.
class DetectedAllergen {
  final String key;
  final bool matched;

  const DetectedAllergen({required this.key, required this.matched});

  factory DetectedAllergen.fromJson(Map<String, dynamic> json) {
    return DetectedAllergen(
      key: json['key'] as String? ?? '',
      matched: json['matched'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'matched': matched};
}

/// docs/architecture.md — Sözleşme 1 (`fetch-product`) yanıtındaki "rule_engine_result".
class RuleEngineResult {
  final List<String> matchedAllergens;

  /// Ürünün tüm alerjenleri, kanonik anahtarlarıyla. Kural motorunun
  /// `allergens` alanı; eski yanıtlarda bulunmayabilir.
  final List<DetectedAllergen> allergens;

  final bool hasConflict;
  final bool veganCompatible;
  final String? diabeticNote;

  const RuleEngineResult({
    required this.matchedAllergens,
    required this.hasConflict,
    required this.veganCompatible,
    this.allergens = const <DetectedAllergen>[],
    this.diabeticNote,
  });

  /// Profille çakışan alerjenler — "Senin için riskler" bölümünü besler.
  /// `allergens` boşsa (eski backend yanıtı) ham profil string'lerine düşer,
  /// böylece ekran her iki sözleşmeyle de çalışır.
  List<String> get personalRiskKeys => allergens.isNotEmpty
      ? allergens.where((a) => a.matched).map((a) => a.key).toList()
      : matchedAllergens;

  /// Üründe var ama profilde yok.
  List<DetectedAllergen> get detectedOnly =>
      allergens.where((a) => !a.matched).toList();

  factory RuleEngineResult.fromJson(Map<String, dynamic> json) {
    final dietFlags = json['diet_flags'] as Map<String, dynamic>? ?? {};
    return RuleEngineResult(
      matchedAllergens: (json['matched_allergens'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      allergens: (json['allergens'] as List<dynamic>? ?? [])
          .map((e) => DetectedAllergen.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasConflict: json['has_conflict'] as bool? ?? false,
      veganCompatible: dietFlags['vegan_compatible'] as bool? ?? true,
      diabeticNote: dietFlags['diabetic_note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched_allergens': matchedAllergens,
      'allergens': allergens.map((a) => a.toJson()).toList(),
      'has_conflict': hasConflict,
      'diet_flags': {
        'vegan_compatible': veganCompatible,
        'diabetic_note': diabeticNote,
      },
    };
  }
}
