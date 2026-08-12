// lib/data/repositories/chatbot_repository.dart

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

  Future<ChatbotResponse> sendMessage(String userMessage, {String? sessionId}) async {
    try {
      final body = <String, dynamic>{
        'user_message': userMessage,
      };

      if (sessionId != null) {
        body['session_id'] = sessionId;
      }

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
}