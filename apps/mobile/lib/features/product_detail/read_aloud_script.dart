import '../../core/models/explanation.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../l10n/app_localizations.dart';
import 'profile_checks.dart';

/// Builds the ordered speech segments read aloud when a product is scanned.
///
/// Order (task contract):
/// 1. Pending products are never called "safe": the "not verified yet" line
///    comes first; any real conflict reason follows it.
/// 2. For verified products with an allergen/diet/health conflict, the personal
///    reason is spoken (allergens first — [personalReason] already orders them).
/// 3. Otherwise a short "safe" confirmation.
///
/// Returns plain strings so the caller just feeds each to [TtsService.speak];
/// no widget or engine detail leaks in, keeping this pure and testable.
List<String> buildVerdictSpeech({
  required AppLocalizations l10n,
  required Product product,
  required Explanation explanation,
  required RuleEngineResult? rule,
  required UserProfile? profile,
}) {
  final segments = <String>[];
  final hasConflict = (rule?.hasConflict ?? false) ||
      explanation.level != WarningLevel.ok;

  if (product.isPending) {
    segments.add(l10n.readAloudNotVerified);
    if (hasConflict) {
      segments.add(_reason(l10n, explanation, rule, profile));
    }
    return segments;
  }

  if (hasConflict) {
    segments.add(_reason(l10n, explanation, rule, profile));
  } else {
    segments.add(l10n.readAloudSafe);
  }
  return segments;
}

/// The ingredients list spoken on demand when the user taps "Read Details".
/// Empty when the product has no ingredients text.
String buildIngredientsSpeech({
  required AppLocalizations l10n,
  required Product product,
  required String localeName,
}) {
  final ingredients = product.ingredientsTextFor(localeName).trim();
  if (ingredients.isEmpty) return '';
  return '${l10n.readAloudIngredientsIntro} $ingredients';
}

String _reason(
  AppLocalizations l10n,
  Explanation explanation,
  RuleEngineResult? rule,
  UserProfile? profile,
) {
  return personalReason(
    l10n: l10n,
    explanation: explanation,
    rule: rule,
    profile: profile,
  );
}
