import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatbotViewModel extends ChangeNotifier {
  bool isTyping = false;

  List<ChatMessage> messages = [
    ChatMessage(
      text: 'Merhaba! Ben Akıllı Sepet asistanın. Taradığın ürünler veya diyetin hakkında bana her şeyi sorabilirsin.',
      isUser: false,
      timestamp: DateTime.now(),
    )
  ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    messages.add(ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    isTyping = true;
    notifyListeners();

    // TODO(backend): chatbot Edge Function'ına bağlanınca mock bekleme kaldırılacak.
    await Future.delayed(const Duration(milliseconds: 1500));

    messages.add(ChatMessage(
      text: 'Henüz Geliştirme Aşamasındayım',
      isUser: false,
      timestamp: DateTime.now(),
    ));

    isTyping = false;
    notifyListeners();
  }
}
