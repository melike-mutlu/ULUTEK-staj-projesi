import '../../core/constants/allergen_catalog.dart';
import '../../core/models/explanation.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';

/// One profile entry checked against the product: what the user selected and
/// how this product relates to it. [level] null = "değerlendirilemedi": we
/// could not judge it, which must never read as safe.
class ProfileCheck {
  const ProfileCheck({
    required this.label,
    required this.note,
    required this.level,
  });

  /// The user's own wording, e.g. "Vegan" or "Şeker hastalığı".
  final String label;
  final String note;
  final WarningLevel? level;
}

const _notEvaluatedNote = 'Bu ürün için değerlendirilemedi';

/// Diet preferences vs. the product. Only vegan/vegetarian have a backend
/// compatibility flag; every other diet is reported "not evaluated" rather than
/// falsely marked compatible.
List<ProfileCheck> dietChecks(UserProfile? profile, RuleEngineResult? rule) {
  final preferences = profile?.dietPreferences ?? const <String>[];
  return [for (final preference in preferences) _dietCheck(preference, rule)];
}

ProfileCheck _dietCheck(String preference, RuleEngineResult? rule) {
  final compatible = _dietCompatibility(preference, rule);
  if (compatible == null) {
    return ProfileCheck(
        label: preference, note: _notEvaluatedNote, level: null);
  }
  if (!compatible) {
    return ProfileCheck(
      label: preference,
      note: 'Bu üründe uygun olmayan içerik var',
      level: WarningLevel.warning,
    );
  }
  return ProfileCheck(
    label: preference,
    note: 'Bu ürün tercihinle uyumlu',
    level: WarningLevel.ok,
  );
}

/// null = couldn't evaluate (unknown flag, or a diet the engine doesn't judge).
bool? _dietCompatibility(String preference, RuleEngineResult? rule) {
  final value = preference.toLowerCase();
  if (value.contains('vegan')) return rule?.veganCompatible;
  if (value.contains('vejetaryen')) return rule?.vegetarianCompatible;
  return null;
}

/// Health conditions vs. the product, driven by the rule engine's per-condition
/// result. Diabetes keeps its descriptive sugar note; unmapped or unjudged
/// conditions are "not evaluated", never a fake all-clear.
List<ProfileCheck> healthChecks(UserProfile? profile, RuleEngineResult? rule) {
  final conditions = profile?.healthConditions ?? const <String>[];
  final statuses = <String, String>{
    for (final h in rule?.healthConditions ?? const <HealthConditionResult>[])
      h.condition.toLowerCase(): h.status,
  };
  final diabeticNote = rule?.diabeticNote?.trim();

  return [
    for (final condition in conditions)
      _healthCheck(condition, statuses[condition.toLowerCase()], diabeticNote),
  ];
}

ProfileCheck _healthCheck(
    String condition, String? status, String? diabeticNote) {
  // Diabetes carries a descriptive note; keep it when the backend flagged it.
  if (_isDiabetes(condition) &&
      diabeticNote != null &&
      diabeticNote.isNotEmpty &&
      status != 'not_evaluated') {
    return ProfileCheck(
      label: condition,
      note: diabeticNote,
      level: _diabeticLevel(diabeticNote),
    );
  }

  switch (status) {
    case 'conflict':
      return ProfileCheck(
        label: condition,
        note: 'Bu üründe durumun için riskli içerik var',
        level: WarningLevel.warning,
      );
    case 'ok':
      return ProfileCheck(
        label: condition,
        note: 'Bu ürün için özel bir uyarı yok',
        level: WarningLevel.ok,
      );
    default:
      return ProfileCheck(
        label: condition,
        note: _notEvaluatedNote,
        level: null,
      );
  }
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

/// A piece of the personal warning. [highlight] marks the words that come
/// straight from the user's own profile, so the UI can colour them.
class ReasonSpan {
  const ReasonSpan(this.text, {this.highlight = false});

  final String text;
  final bool highlight;
}

/// Builds the personal warning shown under the verdict from our own data
/// instead of the LLM's free text: the allergens the user reacts to, the diet
/// this product breaks and any health note that applies.
///
/// Falls back to the backend explanation when the profile is empty, so an
/// anonymous user still sees something meaningful.
List<ReasonSpan> personalReasonSpans({
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final spans = <ReasonSpan>[];

  final allergens = (rule?.personalRiskKeys ?? const <String>[])
      .map((key) => allergenInfo(key).label.toLowerCase())
      .toList();
  if (allergens.isNotEmpty) {
    spans.add(const ReasonSpan('Sende alerji yapan '));
    for (var i = 0; i < allergens.length; i++) {
      if (i > 0) {
        spans.add(ReasonSpan(i == allergens.length - 1 ? ' ve ' : ', '));
      }
      spans.add(ReasonSpan(allergens[i], highlight: true));
    }
    spans.add(const ReasonSpan(' içeriyor. '));
  }

  // Only real conflicts feed the warning; "not evaluated" (null) never does.
  for (final check in dietChecks(profile, rule)) {
    if (check.level == WarningLevel.warning) {
      spans.add(ReasonSpan(check.label, highlight: true));
      spans.add(const ReasonSpan(' beslenmene uygun değil. '));
    }
  }

  for (final check in healthChecks(profile, rule)) {
    if (check.level == WarningLevel.warning) {
      spans.add(const ReasonSpan('Profilindeki '));
      spans.add(ReasonSpan(check.label, highlight: true));
      spans.add(ReasonSpan(' için: ${check.note}. '));
    }
  }

  if (spans.isEmpty) {
    final fallback = explanation.warningMessage.trim();
    return [
      ReasonSpan(fallback.isNotEmpty ? fallback : explanation.summary),
    ];
  }

  return spans;
}

/// One bullet per category for the "uygun değil" verdict: allergens, then each
/// conflicting diet, then each conflicting health condition. Each line is a
/// short span list with the profile keywords highlighted. Empty when there is
/// no conflict — the caller then shows the flat reason instead.
List<List<ReasonSpan>> personalReasonLines({
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final lines = <List<ReasonSpan>>[];

  final allergens = (rule?.personalRiskKeys ?? const <String>[])
      .map((key) => allergenInfo(key).label.toLowerCase())
      .toList();
  if (allergens.isNotEmpty) {
    final line = <ReasonSpan>[];
    for (var i = 0; i < allergens.length; i++) {
      if (i > 0) {
        line.add(ReasonSpan(i == allergens.length - 1 ? ' ve ' : ', '));
      }
      line.add(ReasonSpan(allergens[i], highlight: true));
    }
    line.add(const ReasonSpan(' içeriyor.'));
    lines.add(line);
  }

  for (final check in dietChecks(profile, rule)) {
    if (check.level == WarningLevel.warning) {
      lines.add([
        ReasonSpan(check.label, highlight: true),
        const ReasonSpan(' beslenmene uygun değil.'),
      ]);
    }
  }

  for (final check in healthChecks(profile, rule)) {
    if (check.level == WarningLevel.warning) {
      lines.add([
        ReasonSpan(check.label, highlight: true),
        const ReasonSpan(' durumu için uygun değil.'),
      ]);
    }
  }

  return lines;
}

/// Plain-text form of [personalReasonSpans].
String personalReason({
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  return personalReasonSpans(
    explanation: explanation,
    rule: rule,
    profile: profile,
  ).map((span) => span.text).join().trim();
}
