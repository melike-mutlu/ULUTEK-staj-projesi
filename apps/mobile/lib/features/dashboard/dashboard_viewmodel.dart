import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/scan_history_repository.dart';

/// TODO: Ana Sayfa'nın state'i — selamlama metni, profil özeti,
/// son tarama kısayolu gibi giriş verileri burada tutulur.
class DashboardViewModel extends ChangeNotifier {
    DashboardViewModel(this._scanHistoryRepository);

    final ScanHistoryRepository _scanHistoryRepository;

    bool isLoading = false;
    String userName = '';
    List<Map<String, dynamic>> recentScans = [];

    Future<void> loadDashboardData() async {
        isLoading = true;
        notifyListeners();

        try {
            final user = Supabase.instance.client.auth.currentUser;
            if (user != null) {
                userName = user.email?.split('@').first ?? 'Kullanıcı';
            }
        } catch (e) {
            debugPrint('[DashboardViewModel] Kullanıcı bilgisi alınamadı: $e');
        }

        recentScans = await _scanHistoryRepository.getScanHistory(limit: 3);
        isLoading = false;
        notifyListeners();
    }
}
