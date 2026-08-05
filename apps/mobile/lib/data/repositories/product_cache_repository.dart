import 'package:flutter/foundation.dart';

import '../../core/supabase_client.dart';

/// Reads the shared product cache that `fetch-product` fills in, so screens can
/// show product names without calling the edge function again.
class ProductCacheRepository {
  /// Product names for [barcodes], keyed by barcode. Barcodes that are not in
  /// the cache are simply absent — callers fall back to the barcode itself.
  ///
  /// One request for the whole list, never one per item.
  Future<Map<String, String>> getNamesByBarcodes(List<String> barcodes) async {
    final uniqueBarcodes = barcodes.toSet().toList();
    if (uniqueBarcodes.isEmpty) return {};

    try {
      final response = await supabase
          .from('product_cache')
          .select('barcode, name')
          .inFilter('barcode', uniqueBarcodes);

      final names = <String, String>{};
      for (final row in List<Map<String, dynamic>>.from(response)) {
        final barcode = row['barcode']?.toString();
        final name = row['name']?.toString().trim();
        if (barcode == null || barcode.isEmpty) continue;
        if (name == null || name.isEmpty) continue;
        names[barcode] = name;
      }
      return names;
    } catch (e) {
      // Names are decoration: on failure the list still renders with barcodes.
      debugPrint('[ProductCacheRepository] Ürün adı okuma hatası: $e');
      return {};
    }
  }
}
