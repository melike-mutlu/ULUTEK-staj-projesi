import '../../core/models/product_search_result.dart';

/// Searches products by name through Zeynep's `search-products` edge function
/// (Open Food Facts name search).
///
/// The backend is not ready yet, so [searchByName] returns filtered mock data.
/// When the endpoint exists, only the body of [searchByName] changes — the
/// method signature and the UI stay the same.
class ProductSearchRepository {
  /// Trimmed queries shorter than this never hit the network.
  static const int minQueryLength = 2;

  /// Returns products whose name matches [query]. An empty or too-short query
  /// yields no results without a request.
  Future<List<ProductSearchResult>> searchByName(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < minQueryLength) return const [];

    // TODO(backend): call Zeynep's edge function once it lands, e.g.
    //   final response = await supabase.functions.invoke(
    //     'search-products', body: {'query': trimmed});
    // and map response.data['results'] with ProductSearchResult.fromJson.
    return _mockSearch(trimmed);
  }

  /// Case-insensitive substring match over the mock catalogue, mimicking a small
  /// network delay so loading states behave like the real thing.
  Future<List<ProductSearchResult>> _mockSearch(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final lower = query.toLowerCase();
    return _mockCatalogue
        .where((p) =>
            p.name.toLowerCase().contains(lower) ||
            p.brand.toLowerCase().contains(lower))
        .toList(growable: false);
  }
}

const List<ProductSearchResult> _mockCatalogue = [
  ProductSearchResult(
    barcode: '8690504041502',
    name: 'Çikolatalı Gofret',
    brand: 'Ülker',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/869/050/404/1502/front_tr.3.400.jpg',
  ),
  ProductSearchResult(
    barcode: '8690504112233',
    name: 'Süzme Yoğurt 500g',
    brand: 'Sütaş',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/869/050/411/2233/front_tr.3.400.jpg',
  ),
  ProductSearchResult(
    barcode: '8681234567890',
    name: 'Fındık & Kakao Meyve Barı',
    brand: 'Zuber',
    imageUrl: '',
  ),
  ProductSearchResult(
    barcode: '8690000000024',
    name: 'Kuru Meyve Bar',
    brand: 'Seeberger',
    imageUrl: '',
  ),
  ProductSearchResult(
    barcode: '8690000000031',
    name: 'Çikolatalı Yulaf Bar',
    brand: 'Nature Valley',
    imageUrl: '',
  ),
];
