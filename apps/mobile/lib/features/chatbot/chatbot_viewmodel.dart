
import 'package:flutter/foundation.dart';
import '../../data/repositories/scan_history_repository.dart';

// Mesaj verisini tutacağımız model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._scanHistoryRepository);
  final ScanHistoryRepository _scanHistoryRepository;

  bool isLoading = false;
  bool isTyping = false; // Asistan yazıyor animasyonu için

  List<ChatMessage> messages = [
    ChatMessage(
      text: 'Merhaba! Ben Akıllı Sepet asistanın. Taradığın ürünler veya diyetin hakkında bana her şeyi sorabilirsin.',
      isUser: false,
      timestamp: DateTime.now(),
    )
  ];

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Kullanıcının mesajını ekle
    messages.add(ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // 2. Asistan "yazıyor..." durumunu aç
    isTyping = true;
    notifyListeners();

    // 3. Backend hazır olana kadar sahte (mock) bekleme süresi
    await Future.delayed(const Duration(milliseconds: 1500));

    // 4. Asistanın cevabını ekle
    messages.add(ChatMessage(
      text: 'Henüz Geliştirme Aşamasındayım',
      isUser: false,
      timestamp: DateTime.now(),
    ));

    // 5. Yazıyor animasyonunu kapat
    isTyping = false;
    notifyListeners();
  }
}



