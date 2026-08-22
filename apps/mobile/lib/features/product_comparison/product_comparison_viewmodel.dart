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

  /// ViewModel başlatılırken isteğe bağlı olarak ilk ürünler verilebilir.
  /// Boş liste geçilirse ekran, kullanıcının "+ Ürün Ekle" ile gerçek ürün
  /// seçmesini beklediği boş slot(lar)la açılır — sahte varsayılan ürün yok.
  void initializeWithProducts(List<Product> initialProducts) {
    _selectedProducts.clear();
    _ruleResults.clear();
    _selectedProducts.addAll(initialProducts.take(maxComparisonCount));

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
  ///
  /// Arama sonucundan eklenen ürünler [ProductSelectorModal]'da içerik/besin
  /// değeri boş bir taslak (stub) olarak geliyor — burada dönen gerçek
  /// [ProductFetchResult.product] ile o taslağın yerini alıyoruz, yoksa
  /// karşılaştırma tablosunda içindekiler/besin değerleri hep boş görünür.
  Future<void> _loadRuleEngineResults() async {
    final repo = _productRepository;
    if (repo == null || _selectedProducts.isEmpty) return;

    try {
      final barcodes = _selectedProducts.map((p) => p.barcode).toList();
      final results = await repo.compareProducts(barcodes);

      for (final result in results) {
        final barcode = result.product?.barcode;
        if (barcode == null) continue;

        if (result.ruleEngineResult != null) {
          _ruleResults[barcode] = result.ruleEngineResult!;
        }

        final index = _selectedProducts.indexWhere((p) => p.barcode == barcode);
        if (index != -1 && result.product != null) {
          _selectedProducts[index] = result.product!;
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
