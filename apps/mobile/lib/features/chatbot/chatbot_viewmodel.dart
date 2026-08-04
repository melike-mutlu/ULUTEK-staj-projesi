import 'package:flutter/foundation.dart';
import '../../data/repositories/scan_history_repository.dart';

class ChatbotViewModel extends ChangeNotifier {
  ChatbotViewModel(this._scanHistoryRepository);

  final ScanHistoryRepository _scanHistoryRepository;

  bool isLoading = false;
  List<Map<String, dynamic>> historyItems = [];

  // Geçmiş ekranı açıldığında bu fonksiyon çağrılacak
  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();

    //geçmişi getir diyoruz (Geçmiş sayfası olduğu için örneğin son 50 taneyi çekebiliriz)
    // Same source as the home cards, so both lists stay consistent.
    historyItems = await _scanHistoryRepository.getUniqueScanHistory(limit: 50);

    isLoading = false;
    notifyListeners();
  }
}