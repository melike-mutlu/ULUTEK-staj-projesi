import 'package:flutter/foundation.dart';

import '../../core/models/additive_info.dart';
import '../../core/models/alternative.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/supabase_client.dart';

class ProductFetchResult {
  final String status; // "found" | "not_found" | "partial" | "error"
  final Product? product;
  final RuleEngineResult? ruleEngineResult;

  /// Safe alternatives the backend recommends; always a list, empty when none.
  final List<Alternative> safeAlternatives;

  /// Plain-language info for every additive (E-code) the product carries.
  final List<AdditiveInfo> additivesDetails;
  final String? errorMessage;

  const ProductFetchResult({
    required this.status,
    this.product,
    this.ruleEngineResult,
    this.safeAlternatives = const [],
    this.additivesDetails = const [],
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

      return _parseLookupResult(data);
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

  /// Birden fazla barkodu tek istekte karşılaştırır (`compare-products`).
  /// fetch-product'ı N kere ayrı ayrı çağırmak yerine — karşılaştırma ekranı
  /// bunu kullanmalı. En fazla 10 barkod, backend'in kabul ettiği üst sınır.
  Future<List<ProductFetchResult>> compareProducts(List<String> barcodes) async {
    if (barcodes.isEmpty) return const [];

    try {
      final response = await supabase.functions.invoke(
        'compare-products',
        body: {'barcodes': barcodes},
      );

      if (response.status != 200) {
        debugPrint('[ProductRepository] compareProducts HTTP Error: ${response.status}');
        return const [];
      }

      final data = response.data;
      final results = data is Map<String, dynamic> ? data['results'] : null;
      if (results is! List) return const [];

      return results
          .whereType<Map<String, dynamic>>()
          .map(_parseLookupResult)
          .toList(growable: false);
    } catch (e, stack) {
      debugPrint('[ProductRepository] compareProducts Exception: $e\n$stack');
      return const [];
    }
  }

  /// fetch-product ve compare-products aynı ProductLookupResult şeklini
  /// paylaşıyor (ikisi de backend'de productLookup.service.ts'i kullanıyor).
  ProductFetchResult _parseLookupResult(Map<String, dynamic> data) {
    final status = data['status'] as String? ?? 'error';

    if (status == 'error') {
      final errorMsg = data['message'] as String? ?? 'Sunucu hatası';
      debugPrint('[ProductRepository] Server Error: $errorMsg');
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
      safeAlternatives: _parseAlternatives(data['safe_alternatives']),
      additivesDetails: _parseAdditivesDetails(data['additives_details']),
    );
  }

  /// Maps the `safe_alternatives` field into models, tolerating a missing or
  /// malformed value by returning an empty list.
  List<Alternative> _parseAlternatives(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Alternative.fromJson)
        .toList(growable: false);
  }

  /// Maps the `additives_details` field into models, tolerating a missing or
  /// malformed value by returning an empty list.
  List<AdditiveInfo> _parseAdditivesDetails(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AdditiveInfo.fromJson)
        .toList(growable: false);
  }
}
