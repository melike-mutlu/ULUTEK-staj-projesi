
import 'package:flutter/foundation.dart';

import '../../core/utils/display_name.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/scan_history_repository.dart';

/// Ana Sayfa'nın state'i — selamlama, profil özeti ve son tarama kısayolu.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._scanHistoryRepository, this._profileRepository);

  final ScanHistoryRepository _scanHistoryRepository;
  final ProfileRepository _profileRepository;

  bool isLoading = false;
  List<Map<String, dynamic>> recentScans = [];

  // --- YENİ EKLENENLER: TÜM GEÇMİŞ PANELİ İÇİN ---
  bool isLoadingHistory = false;
  List<Map<String, dynamic>> fullHistory = [];

  String _displayName = '';
  String? _avatarUrl;

  /// Profildeki ad, yoksa e-posta kullanıcı adı; ikisi de yoksa boş.
  String get displayName => _displayName;

  /// Profil fotoğrafının URL'i; yoksa null (baş harfe düşülür).
  String? get avatarUrl => _avatarUrl;

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

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

    recentScans = await _scanHistoryRepository.getScanHistory(limit: 3);
    isLoading = false;
    notifyListeners();
  }

  // ALT PANEL AÇILINCA ÇAĞRILACAK
  Future<void> loadFullHistory() async {
    isLoadingHistory = true;
    notifyListeners();

    // Bottom sheet için daha fazla veri çekiyoruz
    fullHistory = await _scanHistoryRepository.getScanHistory(limit: 50);

    isLoadingHistory = false;
    notifyListeners();
  }
}



