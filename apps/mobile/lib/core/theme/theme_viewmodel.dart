import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  static const String _keyThemeMode = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeViewModel() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_keyThemeMode) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeViewModel] _loadTheme error: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyThemeMode, isDark);
    } catch (e) {
      debugPrint('[ThemeViewModel] toggleTheme error: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyThemeMode, mode == ThemeMode.dark);
    } catch (e) {
      debugPrint('[ThemeViewModel] setThemeMode error: $e');
    }
  }
}

final themeViewModelProvider = ChangeNotifierProvider<ThemeViewModel>((ref) {
  return ThemeViewModel();
});
