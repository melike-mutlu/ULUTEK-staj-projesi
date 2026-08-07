
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

/// Text another screen wants prefilled into the input, e.g. the profile
  /// "danış" suggestion. The view writes it into its controller and calls
  /// [consumePendingInput] so it never re-appears on a later tab visit.
  String? pendingInput;

  void setPendingInput(String text) {
    pendingInput = text;
    notifyListeners();
  }

  /// Clears the prefill without notifying: the view already applied it, so a
  /// rebuild here would only risk a loop.
  void consumePendingInput() {
    pendingInput = null;
  }

  // Yeni sohbet başlatma fonksiyonu
  void clearMessages() {
    messages.clear();
    errorMessage = null;
    notifyListeners();
  }
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
