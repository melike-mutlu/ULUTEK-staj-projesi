/// A safe alternative product shown in the "Öneriler" section.
///
/// Mirrors the `safe_alternatives[]` items inside the `fetch-product` response,
/// so parsing stays a straight field map with no client-side reshaping.
class Alternative {
  const Alternative({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.imageUrl,
    required this.nutriscoreGrade,
    required this.isSafe,
    required this.recommendationReason,
  });

  /// Lookup key used to open this alternative on the product detail screen.
  final String barcode;
  final String productName;
  final String brand;
  final String imageUrl;

  /// Nutri-Score letter A–E (uppercased); empty when the backend omits it.
  final String nutriscoreGrade;

  /// The backend only lists alternatives it deems safe for the user's profile.
  final bool isSafe;

  /// Short human-readable reason this product is recommended.
  final String recommendationReason;

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      barcode: json['barcode'] as String? ?? '',
      productName: json['product_name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      nutriscoreGrade: (json['nutriscore_grade'] as String? ?? '').toUpperCase(),
      isSafe: json['is_safe'] as bool? ?? false,
      recommendationReason: json['recommendation_reason'] as String? ?? '',
    );
  }
}
