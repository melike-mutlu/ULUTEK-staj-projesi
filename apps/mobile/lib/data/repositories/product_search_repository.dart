import '../../core/models/product_search_result.dart';
import '../../core/supabase_client.dart';

/// Searches products by name through Zeynep's `search-products` edge function
/// (Open Food Facts name search).
class ProductSearchRepository {
  /// Trimmed queries shorter than this never hit the network.
  static const int minQueryLength = 2;

  /// Returns products whose name matches [query]. An empty or too-short query
  /// yields no results without a request.
  Future<List<ProductSearchResult>> searchByName(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < minQueryLength) return const [];

    final response = await supabase.functions.invoke(
      'search-products',
      body: {'query': trimmed},
    );

    if (response.status != 200) return const [];

    final data = response.data;
    final results = data is Map<String, dynamic> ? data['results'] : null;
    if (results is! List) return const [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(ProductSearchResult.fromJson)
        .toList(growable: false);
  }
}
