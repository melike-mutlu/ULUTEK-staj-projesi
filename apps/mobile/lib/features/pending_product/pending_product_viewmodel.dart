import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/pending_product_repository.dart';

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
  String? errorMessage;
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
      } else if (type == 'nutrition') {
        imageNutrition = picked;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[PendingProductViewModel] Pick image error: $e');
    }
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
      errorMessage = 'Lütfen geçerli bir barkod giriniz.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
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
      errorMessage = result.errorMessage ?? 'Gönderim başarısız oldu.';
      notifyListeners();
      return false;
    }
  }
}
