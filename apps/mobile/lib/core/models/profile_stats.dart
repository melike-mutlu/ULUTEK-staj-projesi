/// Small dashboard metrics shown on the profile screen.
class ProfileStats {
  const ProfileStats({
    required this.distinctProducts,
    required this.avoidedAllergens,
    required this.daysSinceSignup,
  });

  /// Distinct products the user has scanned.
  final int distinctProducts;

  /// Times a scan flagged an allergen the user avoids.
  final int avoidedAllergens;

  /// Whole days since the account was created.
  final int daysSinceSignup;
}
