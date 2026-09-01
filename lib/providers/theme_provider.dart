import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/sp_keys.dart';
import '_base.dart';

class ThemeProvider extends BaseProvider {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() : super(name: "ThemeProvider") {
    _loadThemeFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyThemeMode, mode.name);
  }

  void toggleTheme() {
    setThemeMode(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(keyThemeMode);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.light,
      );
      notifyListeners();
    }
  }
}
