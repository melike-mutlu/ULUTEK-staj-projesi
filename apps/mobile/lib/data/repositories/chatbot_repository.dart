// lib/data/repositories/chatbot_repository.dart
import 'package:flutter/foundation.dart';
import '../../shared/services/image_picker_service.dart'; // PickedImage için
import 'package:supabase_flutter/supabase_flutter.dart';


// Yardımcı Sınıf
// Hem backend'den dönen cevabı hem de oturum kimliğini tutar
class ChatbotResponse{
  final String reply;
  final String? sessionId;
  ChatbotResponse({required this.reply, this.sessionId});
}

class ChatbotRepository {
  ChatbotRepository(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<ChatbotResponse> sendMessage(String userMessage, {String? sessionId, PickedImage? image}) async {
    try {
      final body = <String, dynamic>{
        'user_message': userMessage,
      };

      if (sessionId != null) {
        body['session_id'] = sessionId;
      }

      // Eğer kullanıcı fotoğraf seçtiyse Storage'a yükle ve linkini yolla
      if (image != null){
        debugPrint('🤖 [Chatbot] Fotoğraf Storage\'a yükleniyor...');
        final imageUrl = await _uploadImage(image);
        body['image_url'] = imageUrl; // backendde beklenmesi gereken anahtar
        debugPrint('🤖 [Chatbot] Fotoğraf yüklendi, Link: $imageUrl');
      }

      debugPrint('🤖 [Chatbot] Edge Function çağrılıyor...');
      final response = await _supabaseClient.functions.invoke(
        'chatbot',
        body: body,
      );

      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        
        if (data.containsKey('reply')) {
          return ChatbotResponse(
            reply: data['reply'].toString(),
            // Backend'in bize session_id'yi gerçekten bu isimle dönüp dönmediğini kontrol ediyoruz
            sessionId: data['session_id']?.toString(), 
          );
        } else {
          throw Exception('Sunucu yanıtında "reply" alanı bulunamadı.');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.status}');
      }
    } catch (error) {
      throw Exception('Chatbot bağlantı hatası: $error');
    }
  }

  // Storage Yükleme Fonksiyonu
  Future<String> _uploadImage(PickedImage image) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id ?? 'anonymous';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // Resimleri product-images klasöründe chat_temp alt klasörüne koyalım karışmasın
      final storagePath = '$userId/chat_temp_$timestamp.${image.extension}';

      await _supabaseClient.storage.from('product-images').uploadBinary(
        storagePath,
        image.bytes,
      );
      
      return _supabaseClient.storage.from('product-images').getPublicUrl(storagePath);
    } catch (e) {
      debugPrint('🤖 [ChatbotRepository] Fotoğraf yükleme hatası: $e');
      throw Exception('Fotoğraf yüklenemedi: $e');
    }
  }
}
