import 'package:flutter/foundation.dart';

import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../data/repositories/product_repository.dart';

/// Ürün karşılaştırma ekranının state yönetimi (Riverpod ViewModel).
class ProductComparisonViewModel extends ChangeNotifier {
  ProductComparisonViewModel([this._productRepository]);

  final ProductRepository? _productRepository;

  final List<Product> _selectedProducts = [];
  final Map<String, RuleEngineResult> _ruleResults = {};
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get selectedProducts => List.unmodifiable(_selectedProducts);
  Map<String, RuleEngineResult> get ruleResults => Map.unmodifiable(_ruleResults);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Karşılaştırmaya izin verilen maksimum ürün sayısı (Mobil için 3)
  static const int maxComparisonCount = 3;

  /// Varsayılan test ürünleri (Eğer ekran boş açılırsa kullanıcıya hemen gösterilecek 2 ürün)
  static const Product _defaultProduct1 = Product(
    barcode: '8690504018001',
    name: 'Tam Yağlı Taze Süt 1L',
    brand: 'Sütaş',
    imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=300',
    ingredientsText: 'Pastörize inek sütü.',
    additives: [],
    allergensTags: ['en:milk'],
    nutriments: Nutriments(
      energyKcal100g: 62,
      sugars100g: 4.7,
      fat100g: 3.3,
      proteins100g: 3.2,
      salt100g: 0.1,
      carbohydrates100g: 4.7,
    ),
    nutriscore: 'b',
    status: 'VERIFIED',
  );

  static const Product _defaultProduct2 = Product(
    barcode: '8690504018002',
    name: 'Yulaf Sütü Organik 1L',
    brand: 'Alpro',
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=300',
    ingredientsText: 'Su, yulaf (%10), ayçiçek yağı, deniz tuzu.',
    additives: [],
    allergensTags: ['en:gluten'],
    nutriments: Nutriments(
      energyKcal100g: 44,
      sugars100g: 3.2,
      fat100g: 1.5,
      proteins100g: 0.8,
      salt100g: 0.08,
      carbohydrates100g: 6.8,
    ),
    nutriscore: 'a',
    status: 'VERIFIED',
  );

  /// ViewModel başlatılırken isteğe bağlı olarak ilk ürünler verilebilir.
  void initializeWithProducts(List<Product> initialProducts) {
    _selectedProducts.clear();
    _ruleResults.clear();

    if (initialProducts.isNotEmpty) {
      _selectedProducts.addAll(initialProducts.take(maxComparisonCount));
    } else {
      // Varsayılan 2 ürün ile açılış
      _selectedProducts.addAll([_defaultProduct1, _defaultProduct2]);
    }

    _loadRuleEngineResults();
    notifyListeners();
  }

  /// Karşılaştırmaya yeni ürün ekler (Max 3 ürün)
  void addProduct(Product product) {
    if (_selectedProducts.length >= maxComparisonCount) return;

    // Aynı ürün varsa tekrar ekleme
    if (_selectedProducts.any((p) => p.barcode == product.barcode)) return;

    _selectedProducts.add(product);
    _loadRuleEngineResults();
    notifyListeners();
  }

  /// Belirtilen indeksteki ürünü çıkartır
  void removeProductAt(int index) {
    if (index < 0 || index >= _selectedProducts.length) return;
    final removed = _selectedProducts.removeAt(index);
    _ruleResults.remove(removed.barcode);
    notifyListeners();
  }

  /// Belirtilen indeksteki ürünü yenisiyle değiştirir
  void replaceProductAt(int index, Product newProduct) {
    if (index < 0 || index >= _selectedProducts.length) return;
    final old = _selectedProducts[index];
    _ruleResults.remove(old.barcode);
    _selectedProducts[index] = newProduct;
    _loadRuleEngineResults();
    notifyListeners();
  }

  /// Seçili ürünlerin hepsi için kural motoru sonucunu TEK istekte çeker
  /// (compare-products) — her ürün için ayrı ayrı fetchProduct çağırmak yerine.
  Future<void> _loadRuleEngineResults() async {
    final repo = _productRepository;
    if (repo == null || _selectedProducts.isEmpty) return;

    try {
      final barcodes = _selectedProducts.map((p) => p.barcode).toList();
      final results = await repo.compareProducts(barcodes);

      for (final result in results) {
        final barcode = result.product?.barcode;
        if (barcode != null && result.ruleEngineResult != null) {
          _ruleResults[barcode] = result.ruleEngineResult!;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[ProductComparisonViewModel] compareProducts error: $e');
    }
  }

  // NOT: getHealthInfoTextForProduct/getHealthInfoTitleForProduct buradan
  // kaldırıldı — sadece Nutri-Score'a bakarak "diyabet/tansiyon hastaları
  // için güvenli" gibi kullanıcının gerçek profiline hiç bakmayan, kural
  // motorunu bypass eden sağlık iddiaları üretiyordu. Bu ekran şu an
  // UserProfile'a erişemiyor; doğru yapmak için önce profili buraya
  // taşımak gerekiyor.
}
