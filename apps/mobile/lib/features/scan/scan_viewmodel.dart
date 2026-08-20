import 'package:flutter/foundation.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../../data/repositories/product_repository.dart';

/// Barkod okunduğunda ProductRepository.fetchProduct çağırır,
/// sonucu Ürün Detay ekranına taşır.
class ScanViewModel extends ChangeNotifier {
  ScanViewModel(this._productRepository, this._scanHistoryRepository);

  final ProductRepository _productRepository;

  final ScanHistoryRepository _scanHistoryRepository;

  bool isLoading = false;

  Future onBarcodeScanned(String barcode) async {
    isLoading = true;
    notifyListeners();

    // 1. ÖNCE ÜRÜNÜ GETİR
    // Tarama geçmişine "had_conflict" olarak dogru degeri yazabilmek icin
    // kural motoru sonucunun (rule engine result) once gelmesi gerekiyor.
    final result = await _productRepository.fetchProduct(barcode);

    // 2. SONRA SUPABASE'E KAYDETMEYİ DENE
    // Eğer burada bir hata olursa bile catch bloğu sayesinde kod çökmeyecek
    // ve ürün detayları ekranda gösterilmeye devam edecek.
    try {
      await _scanHistoryRepository.saveScanHistory(
        barcode,
        hadConflict: result.ruleEngineResult?.hasConflict ?? false,
      );
    } catch (e) {
       print('ViewModel de kayıt hatası yakalandı: $e');
    }

    isLoading = false;
    notifyListeners();

    return result;
  }


}
