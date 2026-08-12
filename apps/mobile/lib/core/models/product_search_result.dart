/// A single hit from the product name search (Zeynep's Open Food Facts search
/// service). Kept to the fields the results list needs: name, brand, image and
/// the barcode used to open the product detail screen.
class ProductSearchResult {
  const ProductSearchResult({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
  });

  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;

  factory ProductSearchResult.fromJson(Map<String, dynamic> json) {
    return ProductSearchResult(
      barcode: json['barcode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}
