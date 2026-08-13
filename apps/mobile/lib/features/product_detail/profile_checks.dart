import '../../core/constants/allergen_catalog.dart';
import '../../core/models/explanation.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../l10n/app_localizations.dart';

/// One profile entry checked against the product: what the user selected and
/// how this product relates to it. [level] null = not evaluated: we could not
/// judge it, which must never read as safe.
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

/// Diet preferences vs. the product. Only vegan/vegetarian have a backend
/// compatibility flag; every other diet is reported "not evaluated" rather than
/// falsely marked compatible.
List<ProfileCheck> dietChecks(
    AppLocalizations l10n, UserProfile? profile, RuleEngineResult? rule) {
  final preferences = profile?.dietPreferences ?? const <String>[];
  return [for (final preference in preferences) _dietCheck(l10n, preference, rule)];
}

ProfileCheck _dietCheck(
    AppLocalizations l10n, String preference, RuleEngineResult? rule) {
  // "Diyabet dostu" is a diet preference on the backend (hasDiet(profile,
  // "diyabet_dostu")), but it's judged via diet_flags.diabetic_note (sugar
  // content), not the vegan/vegetarian compatibility flags below — same note
  // and severity the health-condition path already uses.
  if (_isDiabetes(preference)) {
    final diabeticNote = rule?.diabeticNote?.trim();
    if (diabeticNote == null || diabeticNote.isEmpty) {
      return ProfileCheck(
          label: preference, note: l10n.checkNotEvaluated, level: null);
    }
    return ProfileCheck(
      label: preference,
      note: diabeticNote,
      level: _diabeticLevel(diabeticNote),
    );
  }

  final compatible = _dietCompatibility(preference, rule);
  if (compatible == null) {
    return ProfileCheck(
        label: preference, note: l10n.checkNotEvaluated, level: null);
  }
  if (!compatible) {
    return ProfileCheck(
      label: preference,
      note: l10n.dietIncompatibleNote,
      level: WarningLevel.warning,
    );
  }
  return ProfileCheck(
    label: preference,
    note: l10n.dietCompatibleNote,
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
List<ProfileCheck> healthChecks(
    AppLocalizations l10n, UserProfile? profile, RuleEngineResult? rule) {
  final conditions = profile?.healthConditions ?? const <String>[];
  final statuses = <String, String>{
    for (final h in rule?.healthConditions ?? const <HealthConditionResult>[])
      h.condition.toLowerCase(): h.status,
  };
  final diabeticNote = rule?.diabeticNote?.trim();

  return [
    for (final condition in conditions)
      _healthCheck(
          l10n, condition, statuses[condition.toLowerCase()], diabeticNote),
  ];
}

ProfileCheck _healthCheck(AppLocalizations l10n, String condition,
    String? status, String? diabeticNote) {
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
        note: l10n.healthConflictNote,
        level: WarningLevel.warning,
      );
    case 'ok':
      return ProfileCheck(
        label: condition,
        note: l10n.healthOkNote,
        level: WarningLevel.ok,
      );
    default:
      return ProfileCheck(
        label: condition,
        note: l10n.checkNotEvaluated,
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
  required AppLocalizations l10n,
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final spans = <ReasonSpan>[];

  final allergens = (rule?.personalRiskKeys ?? const <String>[])
      .map((key) => allergenLabel(l10n, allergenInfo(key)).toLowerCase())
      .toList();
  if (allergens.isNotEmpty) {
    spans.add(ReasonSpan(l10n.reasonAllergenIntro));
    for (var i = 0; i < allergens.length; i++) {
      if (i > 0) {
        spans.add(ReasonSpan(i == allergens.length - 1 ? l10n.reasonAnd : ', '));
      }
      spans.add(ReasonSpan(allergens[i], highlight: true));
    }
    spans.add(ReasonSpan(l10n.reasonAllergenOutro));
  }

  // Only real conflicts feed the warning; "not evaluated" (null) never does.
  for (final check in dietChecks(l10n, profile, rule)) {
    if (check.level == WarningLevel.warning) {
      spans.add(ReasonSpan(check.label, highlight: true));
      spans.add(ReasonSpan(l10n.reasonDietOutro));
    }
  }

  for (final check in healthChecks(l10n, profile, rule)) {
    if (check.level == WarningLevel.warning) {
      spans.add(ReasonSpan(l10n.reasonHealthIntro));
      spans.add(ReasonSpan(check.label, highlight: true));
      spans.add(ReasonSpan('${l10n.reasonHealthMid}${check.note}. '));
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

/// One bullet per category for the "not suitable" verdict: allergens, then each
/// conflicting diet, then each conflicting health condition. Each line is a
/// short span list with the profile keywords highlighted. Empty when there is
/// no conflict — the caller then shows the flat reason instead.
List<List<ReasonSpan>> personalReasonLines({
  required AppLocalizations l10n,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final lines = <List<ReasonSpan>>[];

  final allergens = (rule?.personalRiskKeys ?? const <String>[])
      .map((key) => allergenLabel(l10n, allergenInfo(key)).toLowerCase())
      .toList();
  if (allergens.isNotEmpty) {
    final line = <ReasonSpan>[];
    if (l10n.reasonAllergenLineIntro.isNotEmpty) {
      line.add(ReasonSpan(l10n.reasonAllergenLineIntro));
    }
    for (var i = 0; i < allergens.length; i++) {
      if (i > 0) {
        line.add(ReasonSpan(i == allergens.length - 1 ? l10n.reasonAnd : ', '));
      }
      line.add(ReasonSpan(allergens[i], highlight: true));
    }
    line.add(ReasonSpan(l10n.reasonAllergenLineOutro));
    lines.add(line);
  }

  for (final check in dietChecks(l10n, profile, rule)) {
    if (check.level == WarningLevel.warning) {
      lines.add([
        ReasonSpan(check.label, highlight: true),
        ReasonSpan(l10n.reasonDietLineOutro),
      ]);
    }
  }

  for (final check in healthChecks(l10n, profile, rule)) {
    if (check.level == WarningLevel.warning) {
      lines.add([
        ReasonSpan(check.label, highlight: true),
        ReasonSpan(l10n.reasonHealthLineOutro),
      ]);
    }
  }

  return lines;
}

/// Plain-text form of [personalReasonSpans].
String personalReason({
  required AppLocalizations l10n,
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  return personalReasonSpans(
    l10n: l10n,
    explanation: explanation,
    rule: rule,
    profile: profile,
  ).map((span) => span.text).join().trim();
}
