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
  /// Days shown in the weekly breakdown, ending today.
  static const int _weeklyWindowDays = 7;

  // TODO(backend): the avoided-allergen count has no source yet. Melike Dal
  // will expose an RPC/column; until then this constant is the single point to
  // swap for the real value.
  static const int _mockAvoidedAllergens = 12;

  @override
  Future<ProfileStats> fetch() async {
    final user = supabase.auth.currentUser;
    if (user == null) return ProfileStats.empty();

    final rows = await supabase
        .from('scan_history')
        .select('barcode, scanned_at')
        .eq('user_id', user.id);

    final barcodes = <String>{};
    final scanDays = <DateTime>[]; // local midnight per scan
    for (final row in rows) {
      final barcode = row['barcode'];
      if (barcode is String && barcode.isNotEmpty) barcodes.add(barcode);

      final day = _localDay(row['scanned_at']);
      if (day != null) scanDays.add(day);
    }

    return ProfileStats(
      totalScans: scanDays.length,
      distinctProducts: barcodes.length,
      avoidedAllergens: _mockAvoidedAllergens,
      daysSinceSignup: _daysSince(user.createdAt),
      weeklyBreakdown: _weeklyBreakdown(scanDays),
      currentStreak: _currentStreak(scanDays),
    );
  }

  /// Parses a `scanned_at` value into local midnight, or null if unparseable.
  DateTime? _localDay(Object? scannedAt) {
    if (scannedAt is! String) return null;
    final parsed = DateTime.tryParse(scannedAt);
    if (parsed == null) return null;
    final local = parsed.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Scans per day for the last [_weeklyWindowDays] local days, oldest first.
  /// Days with no scans appear with a zero count so the chart keeps its shape.
  List<DailyScanCount> _weeklyBreakdown(List<DateTime> scanDays) {
    final counts = <DateTime, int>{};
    for (final day in scanDays) {
      counts[day] = (counts[day] ?? 0) + 1;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<DailyScanCount>.generate(_weeklyWindowDays, (index) {
      final day = today.subtract(
        Duration(days: _weeklyWindowDays - 1 - index),
      );
      return DailyScanCount(day: day, count: counts[day] ?? 0);
    });
  }

  /// Consecutive local days with a scan, counting back from today. A gap of a
  /// full day breaks the streak; a scan today or yesterday keeps it alive.
  int _currentStreak(List<DateTime> scanDays) {
    if (scanDays.isEmpty) return 0;

    final daySet = scanDays.toSet();
    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);

    // Nothing today yet is fine as long as yesterday counts.
    if (!daySet.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!daySet.contains(cursor)) return 0;
    }

    var streak = 0;
    while (daySet.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
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
