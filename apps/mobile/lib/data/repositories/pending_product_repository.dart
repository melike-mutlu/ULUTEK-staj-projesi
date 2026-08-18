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

  /// Görüntüden Metin Çıkarma için extract-ingredients Edge Function'ını çağırır
  Future<String?> extractTextFromImage(XFile imageFile) async {
    try {
      
      // Geçici bir dosya adı oluştur
      final userId = supabase.auth.currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.name.split('.').last.toLowerCase();
      final storagePath = '$userId/ocr_temp_$timestamp.$extension';

      // Zaten var olan fonksiyonunla resmi Storage'a yükle ve linkini al
      final imageUrl = await _uploadImage(imageFile, storagePath);

      final response = await supabase.functions.invoke(
        'extract-ingredients',
        body: {
          'image_urls': [imageUrl], 
        },
      );

      if (response.status == 200) {
        final data = response.data as Map<String, dynamic>?;
        if (data != null && data['ingredients_text'] != null) {
          return data['ingredients_text'] as String;
        } else {
           debugPrint('📸 [OCR] HATA: Yanıt 200 OK geldi ama "ingredients_text" yok.');
        }
      } else {
        debugPrint('📸 [OCR] HTTP HATASI: Status Code ${response.status}');
      }
      return null;
    } catch (e) {
      debugPrint('📸 [OCR] BEKLENMEYEN HATA: $e');
      return null;
    }
  }

  // --- TOPLULUK DOĞRULAMASI (OYLAMA) METODLARI ---

  /// RPC (Remote Procedure Call) ile gerçek onay/red sayılarını çeker.
  Future<Map<String, int>> getVoteCounts(String pendingProductId) async {
    try {
      final response = await supabase.rpc(
        'get_pending_product_vote_counts',
        params: {'p_pending_product_id': pendingProductId},
      );
      
      // SUPABASE'DEN GELEN GERÇEK RAW VERİYİ KONSOLA YAZALIM
       

      Map<String, dynamic>? data;

      // Eğer yanıt bir Liste ise ve boş değilse, ilk elemanını al
      if (response is List && response.isNotEmpty) {
        data = response.first as Map<String, dynamic>;
      } 
      // Eğer yanıt direkt Sözlük (Map) ise direkt al
      else if (response is Map) {
        data = response as Map<String, dynamic>;
      }

      if (data != null) {
        return {
          'upvotes': (data['approve_count'] as num?)?.toInt() ?? 0,
          'downvotes': (data['reject_count'] as num?)?.toInt() ?? 0,
        };
      }
      
      return {'upvotes': 0, 'downvotes': 0};
    } catch (e) {
      debugPrint('[PendingProductRepository] getVoteCounts Error: $e');
      return {'upvotes': 0, 'downvotes': 0};
    }
  }

  /// Kullanıcının oyunu veritabanına yazar.
  /// (Upsert kullanıyoruz: Kullanıcı fikrini değiştirirse eski oyu ezilsin diye)
  /// Kullanıcının oyunu veritabanına yazar.
  /// (Upsert kullanıyoruz: Kullanıcı fikrini değiştirirse eski oyu ezilsin diye)
/// Kullanıcının oyunu veritabanına yazar veya oyu geri çeker.
  Future<void> castVote(String pendingProductId, bool? isUpvote) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Oy vermek için giriş yapmalısınız.');

      // Ranim'in tasarımına uygun olarak: Oy verse de, geri alsa da hep UPSERT atıyoruz.
      // Eğer oyu geri çektiyse isUpvote 'null' olarak gidecek.
      await supabase.from('pending_product_votes').upsert({
        'pending_product_id': pendingProductId,
        'user_id': userId,
        'is_approve': isUpvote, // true, false veya null
        'created_at': DateTime.now().toIso8601String(),
      }, onConflict: 'pending_product_id, user_id'); 

    } catch (e) {
      debugPrint('[PendingProductRepository] castVote Error: $e');
      throw Exception('Oyunuz kaydedilemedi.');
    }
  }
  

}

final pendingProductRepositoryProvider = Provider<PendingProductRepository>((ref) {
  return PendingProductRepository();
});
