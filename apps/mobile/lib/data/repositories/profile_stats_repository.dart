import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/profile_stats.dart';
import '../../core/supabase_client.dart';

/// Profile dashboard metrics. Kept behind an interface so switching the mocked
/// pieces to a real backend is a single-line change in [profileStatsRepositoryProvider].
abstract class ProfileStatsRepository {
  /// Metrics for the signed-in user; zeros when there is no session.
  Future<ProfileStats> fetch();
}

class SupabaseProfileStatsRepository implements ProfileStatsRepository {
  @override
  Future<ProfileStats> fetch() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return const ProfileStats(
        scannedProducts: 0,
        avoidedAllergens: 0,
        daysSinceSignup: 0,
      );
    }

    // 1. RPC fonksiyonunu çağırıyoruz
    final summaryResponse = await supabase.rpc(
      'get_user_weekly_monthly_summary',
      params: {
        'p_user_id': user.id,
        'p_start_date': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
    );

    int avoidedCount = 0;
    if (summaryResponse != null && summaryResponse is Map<String, dynamic>) {
      avoidedCount = (summaryResponse['conflicts'] ?? 0) as int;
    }

    // 2. await işlemini burada, return'den önce yapıyoruz
    final scannedCount = await _distinctScannedProducts(user.id);

    // 3. Değerleri güvenle döndürüyoruz
    return ProfileStats(
      scannedProducts: scannedCount,
      avoidedAllergens: avoidedCount,
      daysSinceSignup: _daysSince(user.createdAt),
    );
  }

  /// Distinct scanned barcodes; repeated scans of the same product count once.
  Future<int> _distinctScannedProducts(String userId) async {
    final rows = await supabase
        .from('scan_history')
        .select('barcode')
        .eq('user_id', userId);

    final barcodes = <String>{};
    for (final row in rows) {
      final barcode = row['barcode'];
      if (barcode is String && barcode.isNotEmpty) barcodes.add(barcode);
    }
    return barcodes.length;
  }

  /// Whole days between the account creation time and now, never negative.
  int _daysSince(String createdAtIso) {
    final createdAt = DateTime.tryParse(createdAtIso);
    if (createdAt == null) return 0;
    final days = DateTime.now().toUtc().difference(createdAt.toUtc()).inDays;
    return days < 0 ? 0 : days;
  }
}

final profileStatsRepositoryProvider = Provider<ProfileStatsRepository>(
  (ref) => SupabaseProfileStatsRepository(),
);