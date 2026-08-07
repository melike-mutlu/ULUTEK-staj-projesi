import 'package:flutter/foundation.dart';
import '../../data/repositories/chatbot_repository.dart';

class ChatMessage {
  ChatMessage({
    required this.text, 
    required this.isUser,
    this.isSuggestion = false,
    this.suggestedField,
    this.suggestedValue,
  });
  
  final String text;
  final bool isUser;
  final bool isSuggestion;
  final String? suggestedField;
  final String? suggestedValue;
}

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._chatbotRepository);

  final ChatbotRepository _chatbotRepository;

  bool isLoading = false;
  bool isTyping = false; 
  String? errorMessage;
  
  final List<ChatMessage> messages = [];

  void clearMessages() {
    messages.clear();
    errorMessage = null;
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    messages.add(ChatMessage(text: userMessage, isUser: true));
    errorMessage = null;
    isTyping = true;
    notifyListeners();

    try {
      // 1. GERÇEK API'YE İSTEK (Sevde'nin tarafı)
      final reply = await _chatbotRepository.sendMessage(userMessage);

      // 2. GELEN CEVAPTA GİZLİ ŞİFRE KONTROLÜ
      final suggestionRegex = RegExp(r'\[SUGGESTION:\s*(\w+)=([^\]]+)\]');
      final match = suggestionRegex.firstMatch(reply);

      if (match != null) {
        final field = match.group(1); 
        final value = match.group(2); 
        final cleanText = reply.replaceAll(suggestionRegex, '').trim();

        messages.add(ChatMessage(
          text: cleanText, 
          isUser: false,
          isSuggestion: true, // Şifre varsa onay kartı çizdirir
          suggestedField: field,
          suggestedValue: value,
        ));
      } else {
        // Şifre yoksa normal mesaj çizdirir
        messages.add(ChatMessage(text: reply, isUser: false));
      }

    } catch (error) {
      errorMessage = error.toString();
      messages.add(ChatMessage(text: "Bir hata oluştu: $errorMessage", isUser: false));
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  void markSuggestionAsHandled(int messageIndex) {
    if (messageIndex >= 0 && messageIndex < messages.length) {
       final oldMsg = messages[messageIndex];
       messages[messageIndex] = ChatMessage(
         text: oldMsg.text + "\n\n*(Profilinize eklendi)*", 
         isUser: false
       );
       notifyListeners();
    }
  }
}