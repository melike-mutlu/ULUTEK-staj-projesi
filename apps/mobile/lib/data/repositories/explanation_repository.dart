import '../../core/models/additive_info.dart';
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

  /// Fetches food additive explanation from Eda's backend edge function,
  /// with a local mock fallback until backend is deployed.
  Future<AdditiveInfo> getAdditiveExplanation(String code) async {
    try {
      final response = await supabase.functions.invoke(
        'get-additive-explanation',
        body: {'code': code},
      );

      if (response.status == 200 && response.data is Map<String, dynamic>) {
        return AdditiveInfo.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Fallback to local mock info if function not deployed yet
    }

    return AdditiveInfo.getMockInfo(code);
  }
}

