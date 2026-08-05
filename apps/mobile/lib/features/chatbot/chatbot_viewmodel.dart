
// lib/features/chatbot/chatbot_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/chatbot_repository.dart';

// Basit bir mesaj modeli (UI ile uyumlu olması için)
class ChatMessage {
  ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._chatbotRepository);

  final ChatbotRepository _chatbotRepository;

  bool isLoading = false;
  bool isTyping = false; // Arayüzün aradığı alan
  String? errorMessage;
  
  // Arayüzün okumasını beklediği mesajlar listesi
  final List<ChatMessage> messages = [];

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    // Kullanıcının mesajını listeye ekle ve ekrarı yenile
    messages.add(ChatMessage(text: userMessage, isUser: true));
    errorMessage = null;
    isTyping = true;
    notifyListeners();

    try {
      // Repository üzerinden Edge Function'a git
      final reply = await _chatbotRepository.sendMessage(userMessage);
      
      // Botun cevabını listeye ekle
      messages.add(ChatMessage(text: reply, isUser: false));
    } catch (error) {
      errorMessage = error.toString();
      messages.add(ChatMessage(text: "Bir hata oluştu: $errorMessage", isUser: false));
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }
}
