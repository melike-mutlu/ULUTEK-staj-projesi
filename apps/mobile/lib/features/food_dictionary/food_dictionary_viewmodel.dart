import 'package:flutter/foundation.dart';
import 'data/food_dictionary_data.dart';
import 'models/food_dictionary_model.dart';

class FoodDictionaryViewModel extends ChangeNotifier {
  FoodDictionaryCategory _selectedCategory = FoodDictionaryCategory.all;
  String _searchQuery = '';

  FoodDictionaryCategory get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<FoodTerm> get filteredTerms {
    return FoodDictionaryData.searchTerms(
      query: _searchQuery,
      category: _selectedCategory,
    );
  }

  void selectCategory(FoodDictionaryCategory category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = FoodDictionaryCategory.all;
    _searchQuery = '';
    notifyListeners();
  }
}
