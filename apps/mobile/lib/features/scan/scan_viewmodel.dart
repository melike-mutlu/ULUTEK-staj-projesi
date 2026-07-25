import 'package:flutter/foundation.dart';

import '../../data/repositories/product_repository.dart';

/// Barkod okunduğunda ProductRepository.fetchProduct çağırır,
/// sonucu Ürün Detay ekranına taşır.
class ScanViewModel extends ChangeNotifier {
  ScanViewModel(this._productRepository);

  final ProductRepository _productRepository;

  bool isLoading = false;

  Future<ProductFetchResult> onBarcodeScanned(String barcode) async {
    isLoading = true;
    notifyListeners();
    final result = await _productRepository.fetchProduct(barcode);
    isLoading = false;
    notifyListeners();
    return result;
  }
}
