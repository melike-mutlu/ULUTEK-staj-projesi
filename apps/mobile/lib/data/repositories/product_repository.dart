import 'package:flutter/foundation.dart';

import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/supabase_client.dart';

class ProductFetchResult {
  final String status; // "found" | "not_found" | "partial" | "error"
  final Product? product;
  final RuleEngineResult? ruleEngineResult;
  final String? errorMessage;

  const ProductFetchResult({
    required this.status,
    this.product,
    this.ruleEngineResult,
    this.errorMessage,
  });
}

/// docs/architecture.md — Sözleşme 1: Mobil -> Backend `fetch-product`.
class ProductRepository {
  Future<ProductFetchResult> fetchProduct(String barcode) async {
    try {
      final response = await supabase.functions.invoke(
        'fetch-product',
        body: {'barcode': barcode},
      );

      if (response.status != 200) {
        final errorMsg = 'Backend yanıt hatası: status=${response.status}';
        debugPrint('[ProductRepository] fetchProduct HTTP Error: $errorMsg');
        return ProductFetchResult(
          status: 'error',
          errorMessage: errorMsg,
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        const errorMsg = 'Geçersiz sunucu yanıtı formatı.';
        debugPrint('[ProductRepository] fetchProduct Format Error');
        return const ProductFetchResult(
          status: 'error',
          errorMessage: errorMsg,
        );
      }

      final status = data['status'] as String? ?? 'error';

      if (status == 'error') {
        final errorMsg = data['message'] as String? ?? 'Sunucu hatası';
        debugPrint('[ProductRepository] fetchProduct Server Error: $errorMsg');
        return ProductFetchResult(
          status: 'error',
          errorMessage: errorMsg,
        );
      }

      if (status != 'found' && status != 'partial') {
        return ProductFetchResult(status: status);
      }

      return ProductFetchResult(
        status: status,
        product: data['product'] != null
            ? Product.fromJson(data['product'] as Map<String, dynamic>)
            : null,
        ruleEngineResult: data['rule_engine_result'] != null
            ? RuleEngineResult.fromJson(
                data['rule_engine_result'] as Map<String, dynamic>)
            : null,
      );
    } catch (e, stack) {
      debugPrint('[ProductRepository] fetchProduct Exception: $e\n$stack');
      final errStr = e.toString();
      final userMsg = (errStr.contains('SocketException') || errStr.contains('failed host lookup'))
          ? 'Sunucuya ulaşılamadı. Lütfen .env dosyasındaki Supabase URL bilgilerini veya internet bağlantınızı kontrol edin.'
          : 'İstek gerçekleştirilemedi: $errStr';
      return ProductFetchResult(
        status: 'error',
        errorMessage: userMsg,
      );
    }
  }
}
