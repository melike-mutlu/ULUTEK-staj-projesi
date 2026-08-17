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
  // TODO(backend): the avoided-allergen count has no source yet. Melike Dal
  // will expose an RPC/column; until then this constant is the single point to
  // swap for the real value.
  static const int _mockAvoidedAllergens = 12;

  @override
  Future<ProfileStats> fetch() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return const ProfileStats(
        distinctProducts: 0,
        avoidedAllergens: 0,
        daysSinceSignup: 0,
      );
    }

    return ProfileStats(
      distinctProducts: await _distinctScannedProducts(user.id),
      avoidedAllergens: _mockAvoidedAllergens,
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
