class Nutriments {
  final double? energyKcal100g;
  final double? sugars100g;
  final double? fat100g;
  final double? proteins100g;
  final double? salt100g;

  /// fetch-product bu alani henuz gondermiyor; gelene kadar "—" gosterilir.
  final double? carbohydrates100g;

  const Nutriments({
    this.energyKcal100g,
    this.sugars100g,
    this.fat100g,
    this.proteins100g,
    this.salt100g,
    this.carbohydrates100g,
  });

  /// En az bir besin değeri var mı — "besin değerleri" bölümünü göstermeye değer.
  bool get hasAny =>
      energyKcal100g != null ||
      sugars100g != null ||
      fat100g != null ||
      proteins100g != null ||
      salt100g != null ||
      carbohydrates100g != null;

  factory Nutriments.fromJson(Map<String, dynamic> json) {
    return Nutriments(
      energyKcal100g: (json['energy_kcal_100g'] as num?)?.toDouble(),
      sugars100g: (json['sugars_100g'] as num?)?.toDouble(),
      fat100g: (json['fat_100g'] as num?)?.toDouble(),
      proteins100g: (json['proteins_100g'] as num?)?.toDouble(),
      salt100g: (json['salt_100g'] as num?)?.toDouble(),
      carbohydrates100g: (json['carbohydrates_100g'] as num?)?.toDouble(),
    );
  }
}

/// docs/architecture.md — Sözleşme 1 (`fetch-product`) yanıtındaki "product" nesnesi.
class Product {
  final String barcode;
  final String? pendingProductId; //Backend'den gelecek olan asıl tablo kimliği
  final String name;
  final String? brand;
  final String? imageUrl;
  final String ingredientsText;

  /// English ingredients, filled by the backend (`ingredients_text_en` column).
  /// Null/empty until the backend populates it; [ingredientsTextFor] then falls
  /// back to the default [ingredientsText].
  final String? ingredientsTextEn;
  final List<String> additives;
  final List<String> allergensTags;
  final Nutriments nutriments;
  final String? nutriscore;
  final String? status;

  /// Topluluk tarafından eklenmiş ve henüz onay bekleyen/doğrulanmamış ürün göstergesi.
  final bool isPending;

  const Product({
    required this.barcode,
    this.pendingProductId,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.ingredientsText,
    this.ingredientsTextEn,
    required this.additives,
    required this.allergensTags,
    required this.nutriments,
    this.nutriscore,
    this.status,
    bool? isPending,
  }) : isPending = isPending ?? (status == 'PENDING');

  /// Ingredients text for the given [localeName] (e.g. `l10n.localeName`):
  /// the English column for English UIs when available, otherwise the default.
  String ingredientsTextFor(String localeName) {
    final wantsEnglish = localeName.toLowerCase().startsWith('en');
    final en = ingredientsTextEn?.trim() ?? '';
    if (wantsEnglish && en.isNotEmpty) return en;
    return ingredientsText;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final statusVal = json['status'] as String?;
    final verified = json['verified'] as bool?;
    final isPendingVal = json['is_pending'] as bool? ??
        (statusVal?.toUpperCase() == 'PENDING' || verified == false);

    return Product(
      barcode: json['barcode'] as String,
      pendingProductId: json['pending_product_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String,
      brand: json['brand'] as String? ?? json['brands'] as String?,
      imageUrl: json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          json['image_front_url'] as String? ??
          json['image_url_small'] as String? ??
          json['image_front_small_url'] as String?,
      ingredientsText: json['ingredients_text'] as String? ?? '',
      ingredientsTextEn: json['ingredients_text_en'] as String?,
      additives: (json['additives'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      allergensTags: (json['allergens_tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      nutriments: json['nutriments'] != null
          ? Nutriments.fromJson(
              Map<String, dynamic>.from(json['nutriments'] as Map))
          : const Nutriments(),
      nutriscore: json['nutriscore'] as String?,
      status: statusVal,
      isPending: isPendingVal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'name': name,
      'brand': brand,
      if (imageUrl != null) 'image_url': imageUrl,
      'ingredients_text': ingredientsText,
      if (ingredientsTextEn != null) 'ingredients_text_en': ingredientsTextEn,
      'additives': additives,
      'allergens_tags': allergensTags,
      'nutriments': {
        'energy_kcal_100g': nutriments.energyKcal100g,
        'sugars_100g': nutriments.sugars100g,
        'fat_100g': nutriments.fat100g,
        'proteins_100g': nutriments.proteins100g,
        'salt_100g': nutriments.salt100g,
        'carbohydrates_100g': nutriments.carbohydrates100g,
      },
      'nutriscore': nutriscore,
      if (status != null) 'status': status,
      'is_pending': isPending,
    };
  }
}
