import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/supabase_client.dart';

class PendingProductResult {
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  const PendingProductResult({
    required this.isSuccess,
    this.errorMessage,
    this.data,
  });
}

class PendingProductRepository {
  /// Fotoğrafları Supabase Storage ("product-images" bucket) içine yükler,
  /// ardından `submit-pending-product` Edge Function'ını çağırır.
  Future<PendingProductResult> submitPendingProduct({
    required String barcode,
    String? productName,
    String? ingredientsText,
    XFile? imageFront,
    XFile? imageIngredients,
    XFile? imageNutrition,
  }) async {
    try {
      String? frontUrl;
      String? ingredientsUrl;
      String? nutritionUrl;

      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (imageFront != null) {
        frontUrl = await _uploadImage(imageFront, '$userId/${barcode}_front_$timestamp.jpg');
      }
      if (imageIngredients != null) {
        ingredientsUrl = await _uploadImage(imageIngredients, '$userId/${barcode}_ing_$timestamp.jpg');
      }
      if (imageNutrition != null) {
        nutritionUrl = await _uploadImage(imageNutrition, '$userId/${barcode}_nutr_$timestamp.jpg');
      }

      final response = await supabase.functions.invoke(
        'submit-pending-product',
        body: {
          'barcode': barcode,
          'product_name': productName,
          'ingredients_text': ingredientsText,
          'image_front_url': frontUrl,
          'image_ingredients_url': ingredientsUrl,
          'image_nutrition_url': nutritionUrl,
        },
      );

      if (response.status != 200) {
        final msg = 'Sunucu yanıtı hatası (Status: ${response.status})';
        debugPrint('[PendingProductRepository] Submit HTTP error: $msg');
        return PendingProductResult(isSuccess: false, errorMessage: msg);
      }

      final resData = response.data as Map<String, dynamic>?;
      if (resData == null || resData['status'] != 'success') {
        final msg = resData?['message'] as String? ?? 'Ürün bildirimi kaydedilemedi';
        debugPrint('[PendingProductRepository] Submit Error: $msg');
        return PendingProductResult(isSuccess: false, errorMessage: msg);
      }

      return PendingProductResult(isSuccess: true, data: resData);
    } catch (e, stack) {
      debugPrint('[PendingProductRepository] submitPendingProduct Exception: $e\n$stack');
      final errStr = e.toString();
      final userMsg = (errStr.contains('SocketException') || errStr.contains('failed host lookup'))
          ? 'Sunucuya ulaşılamadı. Lütfen .env dosyasındaki Supabase URL bilgilerini veya internet bağlantınızı kontrol edin.'
          : errStr.startsWith('Fotoğraf yüklenemedi')
              ? errStr
              : 'Bildirim gönderilirken hata oluştu: $errStr';
      return PendingProductResult(
        isSuccess: false,
        errorMessage: userMsg,
      );
    }
  }

  /// Yükleme başarısız olursa hatayı yutup yerel dosya yolunu URL gibi
  /// döndürmez — bu, submit-pending-product'a asla açılamayacak bozuk bir
  /// link kaydedilmesine yol açardı. Bunun yerine hatayı fırlatır, çağıran
  /// (submitPendingProduct) bunu yakalayıp kullanıcıya gösterir.
  Future<String> _uploadImage(XFile file, String storagePath) async {
    try {
      final bytes = await file.readAsBytes();
      await supabase.storage.from('product-images').uploadBinary(
            storagePath,
            bytes,
          );
      return supabase.storage.from('product-images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('[PendingProductRepository] Photo upload error: $e');
      throw Exception('Fotoğraf yüklenemedi: $e');
    }
  }


  /// Görüntüden Metin Çıkarma için Eda'nın Edge Function'ını çağırır
  Future<String?> extractTextFromImage(XFile imageFile) async {
    try {
      // 1. Görüntüyü base64'e çevir (Edge function'a doğrudan yollamak için)
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 2. Edge Function'ı çağır
      final response = await supabase.functions.invoke(
        'extract-ingredients', // Eda'nın fonksiyonunun adı
        body: {
          'image_base64': base64Image,
          'mime_type': 'image/jpeg', // veya image/png
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>?;
        if (data != null && data['ingredients_text'] != null) {
          return data['ingredients_text'] as String;
        }
      } else {
        debugPrint('[PendingProductRepository] Extraction HTTP error: ${response.status}');
      }
      return null;
    } catch (e) {
      debugPrint('[PendingProductRepository] extractTextFromImage Hatası: $e');
      return null;
    }
  }
}

final pendingProductRepositoryProvider = Provider<PendingProductRepository>((ref) {
  return PendingProductRepository();
});
