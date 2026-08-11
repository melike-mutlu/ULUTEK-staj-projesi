import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/models/product_search_result.dart';
import '../../data/repositories/product_search_repository.dart';

enum SearchStatus { idle, loading, results, empty, error }

/// Drives the product name search: debounces keystrokes, calls the repository,
/// and exposes a single [status] the UI switches on. UI has no timing or
/// networking logic of its own.
class SearchViewModel extends ChangeNotifier {
  SearchViewModel(this._repository);

  final ProductSearchRepository _repository;

  /// How long to wait after the last keystroke before searching.
  static const Duration _debounce = Duration(milliseconds: 400);

  SearchStatus status = SearchStatus.idle;
  List<ProductSearchResult> results = const [];
  String query = '';

  Timer? _debounceTimer;

  /// Monotonic token so a slow response for an old query can never overwrite the
  /// results of a newer one.
  int _requestId = 0;

  /// Called on every keystroke; schedules a debounced search.
  void onQueryChanged(String value) {
    query = value;
    _debounceTimer?.cancel();

    if (value.trim().length < ProductSearchRepository.minQueryLength) {
      _requestId++; // Cancel any in-flight request.
      status = SearchStatus.idle;
      results = const [];
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(_debounce, () => _search(value));
  }

  /// Clears the query and returns to the idle state.
  void clear() {
    _debounceTimer?.cancel();
    _requestId++;
    query = '';
    results = const [];
    status = SearchStatus.idle;
    notifyListeners();
  }

  Future<void> _search(String value) async {
    final requestId = ++_requestId;
    status = SearchStatus.loading;
    notifyListeners();

    try {
      final found = await _repository.searchByName(value);
      if (requestId != _requestId) return; // A newer search superseded this one.
      results = found;
      status = found.isEmpty ? SearchStatus.empty : SearchStatus.results;
    } catch (e) {
      if (requestId != _requestId) return;
      debugPrint('[SearchViewModel] search failed: $e');
      results = const [];
      status = SearchStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
