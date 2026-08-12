/// Small dashboard metrics shown on the profile screen.
class ProfileStats {
  const ProfileStats({
    required this.scannedProducts,
    required this.avoidedAllergens,
    required this.daysSinceSignup,
  });

  /// Distinct products the user has scanned.
  final int scannedProducts;

  /// Times a scan flagged an allergen the user avoids.
  final int avoidedAllergens;

  /// Whole days since the account was created.
  final int daysSinceSignup;
}
