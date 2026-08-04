import 'package:flutter/foundation.dart';

import '../../core/utils/display_name.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/scan_history_repository.dart';

/// Ana Sayfa'nın state'i — selamlama, profil özeti ve son tarama kısayolu.
///
/// Oturum bilgisi Supabase'den doğrudan değil [ProfileRepository] üzerinden
/// okunur: hem UI/veri katmanı ayrımı korunur hem de ekran testte sahte bir
/// repository ile ayağa kalkabilir.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._scanHistoryRepository, this._profileRepository);

  final ScanHistoryRepository _scanHistoryRepository;
  final ProfileRepository _profileRepository;

  bool isLoading = false;
  List<Map<String, dynamic>> recentScans = [];

  String _displayName = '';
  String? _avatarUrl;

  /// Profildeki ad, yoksa e-posta kullanıcı adı; ikisi de yoksa boş.
  String get displayName => _displayName;

  /// Profil fotoğrafının URL'i; yoksa null (baş harfe düşülür).
  String? get avatarUrl => _avatarUrl;

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    // Profil okunamazsa ekran düşmesin: ad boş kalır, geçmiş yine yüklenir.
    try {
      final userId = _profileRepository.currentUserId;
      final profile =
          userId == null ? null : await _profileRepository.getProfile(userId);

      _displayName = resolveDisplayName(
        displayName: profile?.displayName,
        email: _profileRepository.currentUserEmail,
      );
      _avatarUrl = profile?.avatarUrl;
    } catch (_) {
      _displayName = '';
      _avatarUrl = null;
    }

    // Unique per barcode: a product scanned twice must not fill two cards.
    recentScans = await _scanHistoryRepository.getUniqueScanHistory(limit: 3);
    isLoading = false;
    notifyListeners();
  }
}
