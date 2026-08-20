import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the "Simple Mode" product-detail preference and persists it across
/// launches. Off by default: the full detail screen shows until opted in.
class SimpleModeViewModel extends ChangeNotifier {
  static const String _keyEnabled = 'simple_mode_enabled';

  bool _isEnabled = false;

  SimpleModeViewModel() {
    _load();
  }

  bool get isEnabled => _isEnabled;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_keyEnabled) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('[SimpleModeViewModel] _load error: $e');
    }
  }

  Future<void> toggle(bool enabled) async {
    if (_isEnabled == enabled) return;
    _isEnabled = enabled;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, enabled);
    } catch (e) {
      debugPrint('[SimpleModeViewModel] toggle error: $e');
    }
  }
}

final simpleModeViewModelProvider =
    ChangeNotifierProvider<SimpleModeViewModel>((ref) {
  return SimpleModeViewModel();
});
