import '../../core/models/shopping_list.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingList>> getLists();
  Future<ShoppingList?> getListById(String id);
  Future<ShoppingList> createList(String name);
  Future<bool> deleteList(String id);
  Future<ShoppingListItem?> addItemToList(String listId, ShoppingListItem item);
  Future<bool> removeItemFromList(String listId, String itemId);
  Future<bool> toggleItemBought(String listId, String itemId);
}

/// Zeynep'in Supabase veritabanı migration'ı tamamlanana kadar kullanılan
/// in-memory Mock Alışveriş Listesi Deposu.
class MockShoppingListRepository implements ShoppingListRepository {
  final List<ShoppingList> _mockLists = [
    ShoppingList(
      id: 'list-1',
      name: 'Haftalık Market Alışverişi',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      items: [
        ShoppingListItem(
          id: 'item-101',
          listId: 'list-1',
          productName: 'Yulaf Ezmesi 500g',
          barcode: '8690504018025',
          brand: 'Eti Lifalif',
          isBought: true,
          quantity: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ShoppingListItem(
          id: 'item-102',
          listId: 'list-1',
          productName: 'Süt 1L (%100 Doğal Organik)',
          barcode: '8690123456789',
          brand: 'Sütaş',
          isBought: false,
          quantity: 2,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        ShoppingListItem(
          id: 'item-103',
          listId: 'list-1',
          productName: 'Organik Zeytinyağı 1L',
          barcode: '8690987654321',
          brand: 'Komili',
          isBought: false,
          quantity: 1,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
      ],
    ),
    ShoppingList(
      id: 'list-2',
      name: 'Kahvaltılık ve Meyve',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      items: [
        ShoppingListItem(
          id: 'item-201',
          listId: 'list-2',
          productName: 'Süzme Peynir 500g',
          brand: 'Pınar',
          isBought: true,
          quantity: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        ShoppingListItem(
          id: 'item-202',
          listId: 'list-2',
          productName: 'Elma Amasya 1kg',
          isBought: true,
          quantity: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ],
    ),
  ];

  @override
  Future<List<ShoppingList>> getLists() async {
    return List.from(_mockLists);
  }

  @override
  Future<ShoppingList?> getListById(String id) async {
    try {
      return _mockLists.firstWhere((list) => list.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<ShoppingList> createList(String name) async {
    final newList = ShoppingList(
      id: 'list-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Yeni Liste' : name.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      items: const [],
    );
    _mockLists.insert(0, newList);
    return newList;
  }

  @override
  Future<bool> deleteList(String id) async {
    _mockLists.removeWhere((list) => list.id == id);
    return true;
  }

  @override
  Future<ShoppingListItem?> addItemToList(String listId, ShoppingListItem item) async {
    final index = _mockLists.indexWhere((l) => l.id == listId);
    if (index == -1) return null;

    final targetList = _mockLists[index];
    final newItem = item.copyWith(
      id: 'item-${DateTime.now().millisecondsSinceEpoch}',
      listId: listId,
      createdAt: DateTime.now(),
    );

    final updatedItems = List<ShoppingListItem>.from(targetList.items)..add(newItem);
    _mockLists[index] = targetList.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );

    return newItem;
  }

  @override
  Future<bool> removeItemFromList(String listId, String itemId) async {
    final index = _mockLists.indexWhere((l) => l.id == listId);
    if (index == -1) return false;

    final targetList = _mockLists[index];
    final updatedItems = targetList.items.where((i) => i.id != itemId).toList();
    _mockLists[index] = targetList.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    return true;
  }

  @override
  Future<bool> toggleItemBought(String listId, String itemId) async {
    final listIndex = _mockLists.indexWhere((l) => l.id == listId);
    if (listIndex == -1) return false;

    final targetList = _mockLists[listIndex];
    final itemIndex = targetList.items.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) return false;

    final currentItem = targetList.items[itemIndex];
    final updatedItem = currentItem.copyWith(isBought: !currentItem.isBought);

    final updatedItems = List<ShoppingListItem>.from(targetList.items);
    updatedItems[itemIndex] = updatedItem;

    _mockLists[listIndex] = targetList.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    );
    return true;
  }
}
