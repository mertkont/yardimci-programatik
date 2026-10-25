import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide preferences: theme mode and language. Persisted with
/// shared_preferences and exposed as a [ChangeNotifier] so the root
/// [MaterialApp] rebuilds when they change.
class SettingsController extends ChangeNotifier {
  SettingsController._();
  static final SettingsController instance = SettingsController._();

  static const _kTheme = 'theme_mode';
  static const _kLang = 'lang';

  ThemeMode _themeMode = ThemeMode.system;
  String _lang = 'system'; // 'system' | 'en' | 'tr'

  ThemeMode get themeMode => _themeMode;
  String get lang => _lang;

  /// null means "follow the device language".
  Locale? get locale => _lang == 'system' ? null : Locale(_lang);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = switch (prefs.getString(_kTheme)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _lang = prefs.getString(_kLang) ?? 'system';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, mode.name);
  }

  Future<void> setLang(String code) async {
    if (code == _lang) return;
    _lang = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, code);
  }

  /// Resolve whether Turkish should be used right now, honouring the override
  /// and falling back to the device language. Used for notification text.
  bool isTrFor(Locale deviceLocale) {
    if (_lang == 'tr') return true;
    if (_lang == 'en') return false;
    return deviceLocale.languageCode == 'tr';
  }
}

/// Global accessor.
SettingsController get appSettings => SettingsController.instance;
