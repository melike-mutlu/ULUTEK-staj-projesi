/// Scans made on a single calendar day, in the device's local timezone.
class DailyScanCount {
  const DailyScanCount({required this.day, required this.count});

  /// Local date at midnight; only the y/m/d parts are meaningful.
  final DateTime day;

  /// Number of scans (repeats included) on that day.
  final int count;
}

/// Dashboard metrics shown on the profile and stats detail screens.
class ProfileStats {
  const ProfileStats({
    required this.totalScans,
    required this.distinctProducts,
    required this.avoidedAllergens,
    required this.daysSinceSignup,
    required this.weeklyBreakdown,
    required this.currentStreak,
  });

  /// All scans the user has made, repeats included.
  final int totalScans;

  /// Distinct products the user has scanned.
  final int distinctProducts;

  /// Times a scan flagged an allergen the user avoids.
  final int avoidedAllergens;

  /// Whole days since the account was created.
  final int daysSinceSignup;

  /// Scans per day for the last 7 local days, oldest first.
  final List<DailyScanCount> weeklyBreakdown;

  /// Consecutive local days with at least one scan, ending today.
  final int currentStreak;

  /// Zeroed metrics for a signed-out or failed state.
  static ProfileStats empty() => const ProfileStats(
        totalScans: 0,
        distinctProducts: 0,
        avoidedAllergens: 0,
        daysSinceSignup: 0,
        weeklyBreakdown: <DailyScanCount>[],
        currentStreak: 0,
      );
}
