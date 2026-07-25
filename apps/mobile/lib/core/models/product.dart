class Nutriments {
  final double? energyKcal100g;
  final double? sugars100g;
  final double? fat100g;
  final double? proteins100g;
  final double? salt100g;

  const Nutriments({
    this.energyKcal100g,
    this.sugars100g,
    this.fat100g,
    this.proteins100g,
    this.salt100g,
  });

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      energyKcal100g: (json['energy_kcal_100g'] as num?)?.toDouble(),
      sugars100g: (json['sugars_100g'] as num?)?.toDouble(),
      fat100g: (json['fat_100g'] as num?)?.toDouble(),
      proteins100g: (json['proteins_100g'] as num?)?.toDouble(),
      salt100g: (json['salt_100g'] as num?)?.toDouble(),
    );
  }
}

/// docs/architecture.md — Sözleşme 1 (`fetch-product`) yanıtındaki "product" nesnesi.
class Product {
  final String barcode;
  final String name;
  final String ingredientsText;
  final List<String> additives;
  final List<String> allergensTags;
  final Nutriments nutriments;
  final String? nutriscore;

  const Product({
    required this.barcode,
    required this.name,
    required this.ingredientsText,
    required this.additives,
    required this.allergensTags,
    required this.nutriments,
    this.nutriscore,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      ingredientsText: json['ingredients_text'] as String? ?? '',
      additives: (json['additives'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      allergensTags: (json['allergens_tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      nutriments: Nutriments.fromJson(
          json['nutriments'] as Map<String, dynamic>? ?? {}),
      nutriscore: json['nutriscore'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'ingredients_text': ingredientsText,
      'additives': additives,
      'allergens_tags': allergensTags,
      'nutriments': {
        'energy_kcal_100g': nutriments.energyKcal100g,
        'sugars_100g': nutriments.sugars100g,
        'fat_100g': nutriments.fat100g,
        'proteins_100g': nutriments.proteins100g,
        'salt_100g': nutriments.salt100g,
      },
      'nutriscore': nutriscore,
    };
  }
}
