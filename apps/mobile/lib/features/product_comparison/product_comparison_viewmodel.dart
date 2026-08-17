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
    _fetchRuleResultForProduct(product);
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
    _fetchRuleResultForProduct(newProduct);
    notifyListeners();
  }

  void _loadRuleEngineResults() {
    for (final product in _selectedProducts) {
      _fetchRuleResultForProduct(product);
    }
  }

  Future<void> _fetchRuleResultForProduct(Product product) async {
    if (_productRepository != null) {
      try {
        final res = await _productRepository.fetchProduct(product.barcode);
        if (res.ruleEngineResult != null) {
          _ruleResults[product.barcode] = res.ruleEngineResult!;
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('[ProductComparisonViewModel] Error fetching rule engine: $e');
      }
    }

    // Backend isteği yapılamıyorsa veya kural sonucu boşsa mock kural sonucu
    _ruleResults[product.barcode] = _generateMockRuleResult(product);
    notifyListeners();
  }

  RuleEngineResult _generateMockRuleResult(Product product) {
    final hasMilk = product.allergensTags.contains('en:milk');
    final hasGluten = product.allergensTags.contains('en:gluten');

    return RuleEngineResult(
      matchedAllergens: hasGluten ? ['gluten'] : [],
      hasConflict: hasGluten,
      veganCompatible: !hasMilk,
      vegetarianCompatible: true,
      healthConditions: [
        HealthConditionResult(
          condition: 'Gluten Hassasiyeti',
          status: hasGluten ? 'conflict' : 'ok',
        ),
      ],
    );
  }

  /// Sevde'nin yazdığı özel sağlık durumu bilgi kartı metnini ürün özelinde üretir
  String getHealthInfoTextForProduct(Product product) {
    if (product.nutriscore == 'a' || product.nutriscore == 'b') {
      return '${product.name}, düşük doymuş yağ ve dengeli besin değerleri ile günlük tüketime son derece uygundur. Diyabet ve yüksek tansiyon takibi yapan bireyler için güvenli bir alternatif oluşturur.';
    } else if (product.nutriscore == 'e' || product.nutriscore == 'd') {
      return '${product.name}, yüksek ilave şeker ve kalori yoğunluğuna sahiptir. İnsülin direnci, diyabet veya porsiyon kontrolü yapan bireylerin porsiyon miktarını kısıtlayarak tüketmesi önerilir.';
    }
    return '${product.name} içeriğindeki bileşenler dengeli porsiyonlarda tüketilmelidir. Özel diyet ve beslenme takibiniz varsa porsiyon ölçüsüne dikkat ediniz.';
  }

  /// Sevde'nin yazdığı bilgi kartı başlığını döner
  String getHealthInfoTitleForProduct(Product product) {
    if (product.allergensTags.contains('en:gluten')) {
      return 'Gluten & Sindirim Rehberi';
    } else if (product.allergensTags.contains('en:milk')) {
      return 'Laktoz & Süt Protein Rehberi';
    } else if ((product.nutriments.sugars100g ?? 0) > 10) {
      return 'Diyabet & Şeker Dengesi Notu';
    }
    return 'Sağlıklı Beslenme Bilgi Notu';
  }
}
