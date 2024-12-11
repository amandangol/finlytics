import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'system';

    switch (savedTheme) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.light;
        break;
      default:
        _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        prefs.setString('theme', 'light');
        break;
      case ThemeMode.dark:
        prefs.setString('theme', 'dark');
        break;
      case ThemeMode.system:
        prefs.setString('theme', 'system');
        break;
    }

    notifyListeners();
  }
}
