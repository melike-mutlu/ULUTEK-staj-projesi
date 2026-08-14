import 'package:flutter/foundation.dart';
import '../../data/repositories/chatbot_repository.dart';
import '../../shared/services/image_picker_service.dart';

class ChatMessage {
  ChatMessage({
    required this.text, 
    required this.isUser,
    this.isSuggestion = false,
    this.suggestedField,
    this.suggestedValue,
    this.attachedImageBytes,
  });
  
  final String text;
  final bool isUser;
  final bool isSuggestion;
  final String? suggestedField;
  final String? suggestedValue;
  final Uint8List? attachedImageBytes;
}

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._chatbotRepository);

  final ChatbotRepository _chatbotRepository;

  bool isLoading = false;
  bool isTyping = false; 
  String? errorMessage;
  final List<ChatMessage> messages = [];

  /// Yapay zekanın sohbet geçmişini hatırlaması için gereken kimlik
  String? currentSessionId;

  /// Text another screen wants prefilled into the input, e.g. the profile
  /// "danış" suggestion. The view writes it into its controller and calls
  /// [consumePendingInput] so it never re-appears on a later tab visit.
  String? pendingInput;

  PickedImage? selectedImage;
  void setSelectedImage(PickedImage? image) {
    selectedImage = image;
    notifyListeners();
  }

  void removeSelectedImage() {
    selectedImage = null;
    notifyListeners();
  }

  void setPendingInput(String text) {
    pendingInput = text;
    notifyListeners();
  }

  /// Clears the prefill without notifying: the view already applied it, so a
  /// rebuild here would only risk a loop.
  void consumePendingInput() {
    pendingInput = null;
  }

  void clearMessages() {
    messages.clear();
    errorMessage = null;
    // Yeni sohbet başladığında hafızayı sıfırla
    currentSessionId = null;
    selectedImage = null;
    notifyListeners();
  }

  /// [errorText] is the localized message shown as a bot reply if the request
  /// fails; the View supplies it so the ViewModel stays free of localization.
  Future<void> sendMessage(String userMessage, {required String errorText}) async {
    if (userMessage.trim().isEmpty && selectedImage == null) return;

    messages.add(ChatMessage(
      text: userMessage, 
      isUser: true,
      attachedImageBytes: selectedImage?.bytes,
      ));

    // Gönderim için resmi geçici değişkene alıp UI'dan temizliyoruz
    final imageToSend = selectedImage;
    selectedImage = null;

    errorMessage = null;
    isTyping = true;
    notifyListeners();

    try {
      // 1. GERÇEK API'YE İSTEK (Elimizdeki sessionId'yi de gönderiyoruz)
      final result = await _chatbotRepository.sendMessage(
        userMessage,
        sessionId: currentSessionId,
        image: imageToSend,
      );

      // Backend'den dönen yeni/güncel session_id'yi alıyoruz
      if (result.sessionId != null) {
        currentSessionId = result.sessionId;
      }

      final reply = result.reply;  

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
      if (kDebugMode) debugPrint('ChatbotViewModel: sendMessage failed <- $error');
      messages.add(ChatMessage(text: errorText, isUser: false));
    } finally {
      isTyping = false;
      notifyListeners();
    }
  }

  /// [handledLabel] is the localized "added to your profile" note appended to
  /// the message, passed in by the View to keep localization out of here.
  void markSuggestionAsHandled(int messageIndex, String handledLabel) {
    if (messageIndex >= 0 && messageIndex < messages.length) {
       final oldMsg = messages[messageIndex];
       messages[messageIndex] = ChatMessage(
         text: "${oldMsg.text}\n\n*($handledLabel)*",
         isUser: false,
         attachedImageBytes: oldMsg.attachedImageBytes,
       );
       notifyListeners();
    }
  }
}
