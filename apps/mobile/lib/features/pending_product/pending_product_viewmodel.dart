import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/pending_product_repository.dart';
import 'pending_product_error.dart';

class PendingProductViewModel extends ChangeNotifier {
  PendingProductViewModel(this._repository, {String? initialBarcode}) {
    if (initialBarcode != null && initialBarcode.isNotEmpty) {
      barcode = initialBarcode;
    }
  }

  final PendingProductRepository _repository;
  final ImagePicker _picker = ImagePicker();

  String barcode = '';
  String productName = '';
  String ingredientsText = '';

  XFile? imageFront;
  XFile? imageIngredients;
  XFile? imageNutrition;

  bool isLoading = false;

  /// Last failure reason, or null. The View maps this to a localized message.
  PendingProductError? error;
  bool isSuccess = false;

  void setBarcode(String value) {
    barcode = value;
    notifyListeners();
  }

  void setProductName(String value) {
    productName = value;
    notifyListeners();
  }

  void setIngredientsText(String value) {
    ingredientsText = value;
    notifyListeners();
  }

  Future<void> pickImage(String type, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      if (type == 'front') {
        imageFront = picked;
      } else if (type == 'ingredients') {
        imageIngredients = picked;
        notifyListeners(); //Fotoğrafın UI'da hemen görünmesi için
        _extractIngredientsText(picked); //İçindekiler fotoğrafı seçilir seçilmez metni çıkarmaya başla
      } else if (type == 'nutrition') {
        imageNutrition = picked;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[PendingProductViewModel] Pick image error: $e');
    }
  }
  // Yapay zeka ile metni çeker

  bool isExtractingText = false; //Yükleniyor animasyonu için
  Future<void> _extractIngredientsText(XFile image) async{
    isExtractingText = true;
    notifyListeners();

    final extractedText = await _repository.extractTextFromImage(image);
    isExtractingText = false;

    //Eğer yapay zeka metin bulabildiyse, UI'daki metin kutusunu doldur
    if (extractedText != null && extractedText.trim().isNotEmpty) {
      //Eğer kullanıcı halihazırda birşeyler yazdıysa üstüne yazma, sonuna ekle
      if (ingredientsText.trim().isEmpty) {
        ingredientsText = extractedText;
      } else {
        ingredientsText = '$ingredientsText\n$extractedText';
      }
    }
    notifyListeners();
  }

  void removeImage(String type) {
    if (type == 'front') {
      imageFront = null;
    } else if (type == 'ingredients') {
      imageIngredients = null;
    } else if (type == 'nutrition') {
      imageNutrition = null;
    }
    notifyListeners();
  }

  Future<bool> submit() async {
    if (barcode.trim().isEmpty) {
      error = PendingProductError.invalidBarcode;
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    isSuccess = false;
    notifyListeners();

    final result = await _repository.submitPendingProduct(
      barcode: barcode.trim(),
      productName: productName.trim().isEmpty ? null : productName.trim(),
      ingredientsText: ingredientsText.trim().isEmpty ? null : ingredientsText.trim(),
      imageFront: imageFront,
      imageIngredients: imageIngredients,
      imageNutrition: imageNutrition,
    );

    isLoading = false;

    if (result.isSuccess) {
      isSuccess = true;
      notifyListeners();
      return true;
    } else {
      if (kDebugMode) {
        debugPrint('[PendingProductViewModel] submit failed <- ${result.errorMessage}');
      }
      error = PendingProductError.submitFailed;
      notifyListeners();
      return false;
    }
  }
}
