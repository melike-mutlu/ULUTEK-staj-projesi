import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/data/repositories/shopping_list_repository.dart';
import 'package:akilli_sepet/data/repositories/scan_history_repository.dart';
import 'package:akilli_sepet/features/shopping_list/shopping_list_viewmodel.dart';

class DummyScanHistoryRepository extends ScanHistoryRepository {
  @override
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async {
    return [];
  }
}

void main() {
  group('ShoppingList Test Suite', () {
    late MockShoppingListRepository repository;
    late ShoppingListViewModel viewModel;

    setUp(() {
      repository = MockShoppingListRepository();
      viewModel = ShoppingListViewModel(repository, DummyScanHistoryRepository());
    });

    test('Initial mock lists load correctly', () async {
      await viewModel.loadLists();
      expect(viewModel.lists.isNotEmpty, true);
      expect(viewModel.lists.length, 2);
    });

    test('Create new shopping list', () async {
      await viewModel.loadLists();
      final initialCount = viewModel.lists.length;

      final newList = await viewModel.createList('Hafta Sonu Pikniği');
      expect(newList, isNotNull);
      expect(newList!.name, 'Hafta Sonu Pikniği');
      expect(viewModel.lists.length, initialCount + 1);
    });

    test('Add item to shopping list', () async {
      final newList = await viewModel.createList('Test Listesi');
      expect(newList, isNotNull);

      final success = await viewModel.addItemToList(
        listId: newList!.id,
        productName: 'Organik Bal 500g',
        barcode: '8690000111222',
        brand: 'Balparmak',
      );

      expect(success, true);

      await viewModel.loadListDetail(newList.id);
      expect(viewModel.activeList, isNotNull);
      expect(viewModel.activeList!.items.length, 1);
      expect(viewModel.activeList!.items.first.productName, 'Organik Bal 500g');
    });

    test('Toggle item bought status', () async {
      final newList = await viewModel.createList('Test Listesi 2');
      await viewModel.addItemToList(
        listId: newList!.id,
        productName: 'Ekmek',
      );

      await viewModel.loadListDetail(newList.id);
      final item = viewModel.activeList!.items.first;
      expect(item.isBought, false);

      await viewModel.toggleItemBought(newList.id, item.id);
      expect(viewModel.activeList!.items.first.isBought, true);
    });

    test('Delete shopping list', () async {
      final newList = await viewModel.createList('Silinecek Liste');
      expect(newList, isNotNull);

      final success = await viewModel.deleteList(newList!.id);
      expect(success, true);

      final foundList = await repository.getListById(newList.id);
      expect(foundList, isNull);
    });
  });
}
