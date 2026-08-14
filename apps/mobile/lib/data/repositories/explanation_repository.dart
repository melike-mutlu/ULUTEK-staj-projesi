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
    final response = await supabase.functions.invoke(
      'explain-product',
      body: {
        'product': product.toJson(),
        'rule_engine_result': ruleEngineResult.toJson(),
        'user_profile': userProfile.toJson(),
      },
    );

    return Explanation.fromJson(response.data as Map<String, dynamic>);
  }
}

