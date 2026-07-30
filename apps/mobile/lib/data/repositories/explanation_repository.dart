import '../../core/models/explanation.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../core/supabase_client.dart';

/// docs/architecture.md — Sözleşme 2: Mobil -> AI `explain-product`.
class ExplanationRepository {
  Future<Explanation> explainProduct({
    required Product product,
    required RuleEngineResult ruleEngineResult,
    required UserProfile userProfile,
  }) async {
    try {
      final response = await supabase.functions.invoke(
        'explain-product',
        body: {
          'product': product.toJson(),
          'rule_engine_result': ruleEngineResult.toJson(),
          'user_profile': userProfile.toJson(),
        },
      );

      return Explanation.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // Supabase Edge Function (explain-product) henüz yayında değilse fallback oluştur
      final hasConflict = ruleEngineResult.hasConflict || ruleEngineResult.matchedAllergens.isNotEmpty;
      final matchedAllergens = ruleEngineResult.matchedAllergens;

      WarningLevel level;
      String warningMessage;

      if (hasConflict) {
        level = WarningLevel.warning;
        final allergenStr = matchedAllergens.map((e) => e.toUpperCase()).join(', ');
        warningMessage = matchedAllergens.isNotEmpty
            ? 'Bu üründe $allergenStr tespit edildi. Profilinizdeki alerji kayıtlarınız ile çakışmaktadır!'
            : 'Bu ürün diyet veya sağlık tercihlerinize kısıtlama getirmektedir.';
      } else if (ruleEngineResult.diabeticNote != null && ruleEngineResult.diabeticNote!.isNotEmpty) {
        level = WarningLevel.caution;
        warningMessage = 'Alerjen çakışması yok ancak diyet uyarısı mevcut: ${ruleEngineResult.diabeticNote}';
      } else {
        level = WarningLevel.ok;
        warningMessage = 'Tebrikler! Bu ürün kişisel profilinize ve diyet tercihlerinize tam uygundur.';
      }

      return Explanation(
        summary: '${product.name}${product.brand != null ? " (${product.brand})" : ""} ürün analizi.',
        level: level,
        warningMessage: warningMessage,
        dietNote: ruleEngineResult.diabeticNote,
        disclaimer: 'Bu bilgi tıbbi tavsiye niteliği taşımaz.',
      );
    }
  }
}
