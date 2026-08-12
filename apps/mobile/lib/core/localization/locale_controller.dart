import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's language choice and persists it across launches.
///
/// A null [locale] means "follow the device locale": `MaterialApp.locale`
/// receives null and Flutter resolves the active locale against
/// `supportedLocales`.
class LocaleController extends ChangeNotifier {
  LocaleController() {
    _load();
  }

  static const String _prefsKey = 'app_locale';

  Locale? _locale;
  Locale? get locale => _locale;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) return; // System default.
    _locale = Locale(code);
    notifyListeners();
  }

  /// Persists [locale] (null = follow the device) and notifies listeners.
  Future<void> setLocale(Locale? locale) async {
    if (locale?.languageCode == _locale?.languageCode) return;
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
