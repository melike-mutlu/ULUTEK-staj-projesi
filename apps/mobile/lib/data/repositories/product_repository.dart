import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/supabase_client.dart';

class ProductFetchResult {
  final String status; // "found" | "not_found" | "partial"
  final Product? product;
  final RuleEngineResult? ruleEngineResult;

  const ProductFetchResult({
    required this.status,
    this.product,
    this.ruleEngineResult,
  });
}

/// docs/architecture.md — Sözleşme 1: Mobil -> Backend `fetch-product`.
class ProductRepository {
  Future<ProductFetchResult> fetchProduct(String barcode) async {
    final response = await supabase.functions.invoke(
      'fetch-product',
      body: {'barcode': barcode},
    );

    final data = response.data as Map<String, dynamic>;
    final status = data['status'] as String;

    if (status != 'found' && status != 'partial') {
      return ProductFetchResult(status: status);
    }

    return ProductFetchResult(
      status: status,
      product: Product.fromJson(data['product'] as Map<String, dynamic>),
      ruleEngineResult: RuleEngineResult.fromJson(
          data['rule_engine_result'] as Map<String, dynamic>),
    );
  }
}
