// lib/data/repositories/chatbot_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class ChatbotRepository {
  ChatbotRepository(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  /// Kullanıcının mesajını Supabase Edge Function'daki 'chatbot' endpoint'ine gönderir
  /// ve yapay zekanın yanıtını ('reply') geri döndürür.
  Future<String> sendMessage(String userMessage) async {
    try {
      // Supabase Edge Function'ı invoke (tetikleme) etme
      final response = await _supabaseClient.functions.invoke(
        'chatbot',
        body: {
          'user_message': userMessage,
        },
      );

      // Sunucudan dönen yanıtın durumunu ve verisini kontrol et
      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        // Sunucu tarafında belirlediğimiz "reply" anahtarını okuyoruz
        if (data.containsKey('reply')) {
          return data['reply'].toString();
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
}