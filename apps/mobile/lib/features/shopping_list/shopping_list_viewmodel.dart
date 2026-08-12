import 'package:flutter/foundation.dart';
import '../../core/models/scan_history_entry.dart';
import '../../core/models/shopping_list.dart';
import '../../data/repositories/scan_history_repository.dart';
import '../../data/repositories/shopping_list_repository.dart';

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel(
    this._repository,
    this._scanHistoryRepository,
  );

  final ShoppingListRepository _repository;
  final ScanHistoryRepository _scanHistoryRepository;

  List<ShoppingList> _lists = [];
  ShoppingList? _activeList;
  List<ScanHistoryEntry> _recentScans = [];
  bool _isLoading = false;
  bool _isLoadingRecentScans = false;

  List<ShoppingList> get lists => _lists;
  ShoppingList? get activeList => _activeList;
  List<ScanHistoryEntry> get recentScans => _recentScans;
  bool get isLoading => _isLoading;
  bool get isLoadingRecentScans => _isLoadingRecentScans;

  Future<void> loadLists() async {
    _isLoading = true;
    notifyListeners();

    try {
      _lists = await _repository.getLists();
    } catch (e) {
      debugPrint('[ShoppingListViewModel] loadLists error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadListDetail(String listId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _activeList = await _repository.getListById(listId);
    } catch (e) {
      debugPrint('[ShoppingListViewModel] loadListDetail error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ShoppingList?> createList(String name) async {
    try {
      final newList = await _repository.createList(name);
      await loadLists();
      return newList;
    } catch (e) {
      debugPrint('[ShoppingListViewModel] createList error: $e');
      return null;
    }
  }

  Future<bool> deleteList(String listId) async {
    try {
      final success = await _repository.deleteList(listId);
      if (success) {
        if (_activeList?.id == listId) {
          _activeList = null;
        }
        await loadLists();
      }
      return success;
    } catch (e) {
      debugPrint('[ShoppingListViewModel] deleteList error: $e');
      return false;
    }
  }

  Future<bool> addItemToList({
    required String listId,
    required String productName,
    String? barcode,
    String? brand,
    String? imageUrl,
    int quantity = 1,
  }) async {
    try {
      final item = ShoppingListItem(
        id: '',
        listId: listId,
        productName: productName,
        barcode: barcode,
        brand: brand,
        imageUrl: imageUrl,
        quantity: quantity,
        createdAt: DateTime.now(),
      );

      final result = await _repository.addItemToList(listId, item);
      if (result != null) {
        await loadLists();
        if (_activeList?.id == listId) {
          await loadListDetail(listId);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[ShoppingListViewModel] addItemToList error: $e');
      return false;
    }
  }

  Future<bool> removeItemFromList(String listId, String itemId) async {
    try {
      final success = await _repository.removeItemFromList(listId, itemId);
      if (success) {
        await loadLists();
        if (_activeList?.id == listId) {
          await loadListDetail(listId);
        }
      }
      return success;
    } catch (e) {
      debugPrint('[ShoppingListViewModel] removeItemFromList error: $e');
      return false;
    }
  }

  Future<bool> toggleItemBought(String listId, String itemId) async {
    try {
      final success = await _repository.toggleItemBought(listId, itemId);
      if (success) {
        await loadLists();
        if (_activeList?.id == listId) {
          await loadListDetail(listId);
        }
      }
      return success;
    } catch (e) {
      debugPrint('[ShoppingListViewModel] toggleItemBought error: $e');
      return false;
    }
  }

  /// Öneri amaçlı scan_history'den son taranan benzersiz ürünleri çeker.
  Future<void> loadRecentScans() async {
    _isLoadingRecentScans = true;
    notifyListeners();

    try {
      _recentScans = await _scanHistoryRepository.getUniqueScanHistory(limit: 10);
    } catch (e) {
      debugPrint('[ShoppingListViewModel] loadRecentScans error: $e');
      _recentScans = [];
    } finally {
      _isLoadingRecentScans = false;
      notifyListeners();
    }
  }
}
