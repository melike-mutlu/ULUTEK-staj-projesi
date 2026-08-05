import '../../core/constants/allergen_catalog.dart';
import '../../core/models/explanation.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';

/// One profile entry checked against the product: what the user selected and
/// how this product relates to it.
class ProfileCheck {
  const ProfileCheck({
    required this.label,
    required this.note,
    required this.level,
  });

  /// The user's own wording, e.g. "Vegan" or "Şeker hastalığı".
  final String label;
  final String note;
  final WarningLevel level;
}

/// Diet preferences vs. the product. The rule engine only decides whether the
/// product itself is plant based, so that is the only conflict we can claim.
List<ProfileCheck> dietChecks(UserProfile? profile, RuleEngineResult? rule) {
  final preferences = profile?.dietPreferences ?? const <String>[];
  final isPlantBased = rule?.veganCompatible ?? true;

  return [
    for (final preference in preferences)
      if (_needsPlantBased(preference) && !isPlantBased)
        ProfileCheck(
          label: preference,
          note: 'Bu üründe hayvansal içerik var',
          level: WarningLevel.warning,
        )
      else
        ProfileCheck(
          label: preference,
          note: 'Bu ürün tercihinle uyumlu',
          level: WarningLevel.ok,
        ),
  ];
}

/// Health conditions vs. the product. Only diabetes has a backend note today;
/// the rest are listed as "no specific warning" instead of a fake verdict.
List<ProfileCheck> healthChecks(UserProfile? profile, RuleEngineResult? rule) {
  final conditions = profile?.healthConditions ?? const <String>[];
  final diabeticNote = rule?.diabeticNote?.trim();

  return [
    for (final condition in conditions)
      if (_isDiabetes(condition) &&
          diabeticNote != null &&
          diabeticNote.isNotEmpty)
        ProfileCheck(
          label: condition,
          note: diabeticNote,
          level: _diabeticLevel(diabeticNote),
        )
      else
        ProfileCheck(
          label: condition,
          note: 'Bu ürün için özel bir uyarı yok',
          level: WarningLevel.ok,
        ),
  ];
}

bool _needsPlantBased(String preference) {
  final value = preference.toLowerCase();
  return value.contains('vegan') || value.contains('vejetaryen');
}

bool _isDiabetes(String condition) {
  final value = condition.toLowerCase();
  return value.contains('diyabet') || value.contains('şeker');
}

/// The backend sends the diabetes note as free text; these are the phrases it
/// uses today (ruleEngine.service.ts).
WarningLevel _diabeticLevel(String note) {
  final value = note.toLowerCase();
  if (value.contains('yüksek')) return WarningLevel.warning;
  if (value.contains('orta')) return WarningLevel.caution;
  return WarningLevel.ok;
}

/// Builds the one-paragraph personal warning shown under the verdict, from our
/// own data instead of the LLM's free text: which allergens the product has,
/// which diet it breaks and which health note applies.
///
/// Falls back to the backend explanation when the profile is empty, so an
/// anonymous user still sees something meaningful.
String personalReason({
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final sentences = <String>[];

  final allergens = (rule?.personalRiskKeys ?? const <String>[])
      .map((key) => allergenInfo(key).label.toLowerCase())
      .toList();
  if (allergens.isNotEmpty) {
    sentences.add('Bu ürün ${_join(allergens)} içerir.');
  }

  for (final check in dietChecks(profile, rule)) {
    if (check.level != WarningLevel.ok) {
      sentences.add('${check.label} beslenmesine uygun değil.');
    }
  }

  for (final check in healthChecks(profile, rule)) {
    if (check.level != WarningLevel.ok) {
      sentences.add('${check.label}: ${check.note}.');
    }
  }

  if (sentences.isEmpty) {
    final fallback = explanation.warningMessage.trim();
    return fallback.isNotEmpty ? fallback : explanation.summary;
  }

  return sentences.join(' ');
}

/// "a, b ve c"
String _join(List<String> items) {
  if (items.length == 1) return items.first;
  return '${items.take(items.length - 1).join(', ')} ve ${items.last}';
}
