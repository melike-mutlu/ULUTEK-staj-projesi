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

/// Kural motorunun bir sağlık durumu için verdiği sonuç.
/// [status]: "conflict" | "ok" | "not_evaluated".
class HealthConditionResult {
  final String condition;
  final String status;

  const HealthConditionResult({required this.condition, required this.status});

  bool get isConflict => status == 'conflict';
  bool get isEvaluated => status != 'not_evaluated';

  factory HealthConditionResult.fromJson(Map<String, dynamic> json) {
    return HealthConditionResult(
      condition: json['condition'] as String? ?? '',
      status: json['status'] as String? ?? 'not_evaluated',
    );
  }

  Map<String, dynamic> toJson() => {'condition': condition, 'status': status};
}

/// docs/architecture.md — Sözleşme 1 (`fetch-product`) yanıtındaki "rule_engine_result".
class RuleEngineResult {
  final List<String> matchedAllergens;

  /// Ürünün tüm alerjenleri, kanonik anahtarlarıyla. Kural motorunun
  /// `allergens` alanı; eski yanıtlarda bulunmayabilir.
  final List<DetectedAllergen> allergens;

  final bool hasConflict;

  /// null = bilinmiyor: ürünün bitkisel olup olmadığını söyleyecek veri yok.
  /// Kanıt yokluğu uygunluk sayılmaz.
  final bool? veganCompatible;

  /// null = bilinmiyor. Vegandan ayrı: et/balık/jelatin dışlanır, süt/yumurta
  /// serbesttir.
  final bool? vegetarianCompatible;

  final String? diabeticNote;

  /// Profildeki her sağlık durumu için kural motoru sonucu.
  final List<HealthConditionResult> healthConditions;

  /// false ise ürünün alerjen/içerik verisi yok; verdict "uygun" sayılamaz.
  /// Eski yanıtlarda alan olmadığından varsayılan olarak yeterli kabul edilir.
  final bool hasSufficientData;

  const RuleEngineResult({
    required this.matchedAllergens,
    required this.hasConflict,
    required this.veganCompatible,
    this.vegetarianCompatible,
    this.allergens = const <DetectedAllergen>[],
    this.diabeticNote,
    this.healthConditions = const <HealthConditionResult>[],
    this.hasSufficientData = true,
  });

  /// Profille çakışan alerjenler — "Senin için riskler" bölümünü besler.
  /// `allergens` boşsa (eski backend yanıtı) ham profil string'lerine düşer,
  /// böylece ekran her iki sözleşmeyle de çalışır.
  List<String> get personalRiskKeys => allergens.isNotEmpty
      ? allergens.where((a) => a.matched).map((a) => a.key).toList()
      : matchedAllergens;

  /// Üründe var ama profilde yok — "Diğer alerjenler" bölümünü besler.
  List<String> get detectedOnlyKeys =>
      allergens.where((a) => !a.matched).map((a) => a.key).toList();

  factory RuleEngineResult.fromJson(Map<String, dynamic> json) {
    final dietFlags = json['diet_flags'] as Map<String, dynamic>? ?? {};
    return RuleEngineResult(
      matchedAllergens: (json['matched_allergens'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      allergens: (json['allergens'] as List<dynamic>? ?? [])
          .map((e) =>
              DetectedAllergen.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasConflict: json['has_conflict'] as bool? ?? false,
      // No `?? true`: null must stay null (unknown), not become "compatible".
      veganCompatible: dietFlags['vegan_compatible'] as bool?,
      vegetarianCompatible: dietFlags['vegetarian_compatible'] as bool?,
      diabeticNote: dietFlags['diabetic_note'] as String?,
      healthConditions: (json['health_conditions'] as List<dynamic>? ?? [])
          .map((e) => HealthConditionResult.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      hasSufficientData:
          (json['data_sufficiency'] as String?) != 'insufficient',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matched_allergens': matchedAllergens,
      'allergens': allergens.map((a) => a.toJson()).toList(),
      'has_conflict': hasConflict,
      'data_sufficiency': hasSufficientData ? 'sufficient' : 'insufficient',
      'health_conditions': healthConditions.map((h) => h.toJson()).toList(),
      'diet_flags': {
        'vegan_compatible': veganCompatible,
        'vegetarian_compatible': vegetarianCompatible,
        'diabetic_note': diabeticNote,
      },
    };
  }
}
