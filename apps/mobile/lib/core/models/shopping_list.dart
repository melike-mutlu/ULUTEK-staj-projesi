class ShoppingListItem {
  final String id;
  final String listId;
  final String productName;
  final String? barcode;
  final String? brand;
  final String? imageUrl;
  final bool isBought;
  final int quantity;
  final DateTime createdAt;

  const ShoppingListItem({
    required this.id,
    required this.listId,
    required this.productName,
    this.barcode,
    this.brand,
    this.imageUrl,
    this.isBought = false,
    this.quantity = 1,
    required this.createdAt,
  });

  ShoppingListItem copyWith({
    String? id,
    String? listId,
    String? productName,
    String? barcode,
    String? brand,
    String? imageUrl,
    bool? isBought,
    int? quantity,
    DateTime? createdAt,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      brand: brand ?? this.brand,
      imageUrl: imageUrl ?? this.imageUrl,
      isBought: isBought ?? this.isBought,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'list_id': listId,
        'product_name': productName,
        'barcode': barcode,
        'brand': brand,
        'image_url': imageUrl,
        'is_bought': isBought,
        'quantity': quantity,
        'created_at': createdAt.toIso8601String(),
      };

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['id'] as String,
      listId: json['list_id'] as String? ?? '',
      productName: json['product_name'] as String? ?? 'Bilinmeyen Ürün',
      barcode: json['barcode'] as String?,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      isBought: json['is_bought'] as bool? ?? false,
      quantity: json['quantity'] as int? ?? 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class ShoppingList {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ShoppingListItem> items;

  const ShoppingList({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  int get totalItems => items.length;
  int get boughtItems => items.where((item) => item.isBought).length;
  double get progress => totalItems == 0 ? 0.0 : boughtItems / totalItems;

  ShoppingList copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ShoppingListItem>? items,
  }) {
    return ShoppingList(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List?;
    final itemsList = rawItems != null
        ? rawItems
            .whereType<Map<String, dynamic>>()
            .map(ShoppingListItem.fromJson)
            .toList()
        : <ShoppingListItem>[];

    return ShoppingList(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Alışveriş Listesi',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      items: itemsList,
    );
  }
}
