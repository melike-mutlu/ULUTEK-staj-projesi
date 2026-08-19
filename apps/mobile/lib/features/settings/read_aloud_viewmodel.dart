import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the "Read Aloud" accessibility preference and persists it across
/// launches. Off by default: speech only starts once the user opts in.
class ReadAloudViewModel extends ChangeNotifier {
  static const String _keyEnabled = 'read_aloud_enabled';

  bool _isEnabled = false;

  ReadAloudViewModel() {
    _load();
  }

  bool get isEnabled => _isEnabled;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_keyEnabled) ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('[ReadAloudViewModel] _load error: $e');
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
      debugPrint('[ReadAloudViewModel] toggle error: $e');
    }
  }
}

final readAloudViewModelProvider =
    ChangeNotifierProvider<ReadAloudViewModel>((ref) {
  return ReadAloudViewModel();
});
