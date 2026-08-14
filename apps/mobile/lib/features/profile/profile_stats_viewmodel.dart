import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profile_stats.dart';
import '../../data/repositories/profile_stats_repository.dart';

/// Loads the small profile dashboard metrics. Read-only: no user action drives
/// it, so it only exposes [stats] and a loading flag.
class ProfileStatsViewModel extends ChangeNotifier {
  ProfileStatsViewModel(this._repository);

  final ProfileStatsRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProfileStats? _stats;
  ProfileStats? get stats => _stats;

  bool _disposed = false;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      _stats = await _repository.fetch();
    } catch (error) {
      // Stats are non-critical: on failure the section simply hides itself.
      if (kDebugMode) debugPrint('ProfileStatsViewModel: load failed <- $error');
      _stats = null;
    }

    _isLoading = false;
    // autoDispose provider: user can navigate away before fetch() resolves.
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final profileStatsViewModelProvider =
    ChangeNotifierProvider.autoDispose<ProfileStatsViewModel>(
  (ref) => ProfileStatsViewModel(ref.watch(profileStatsRepositoryProvider)),
);
