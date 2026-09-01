import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/sp_keys.dart';
import '_base.dart';

class LanguageProvider extends BaseProvider {
  Locale _locale = const Locale('en', '');

  LanguageProvider() : super(name: "LanguageProvider") {
    _loadLanguageFromPrefs();
  }

  Locale get locale => _locale;

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyLanguageCode, locale.languageCode);
  }

  Future<void> _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(keyLanguageCode);
    if (langCode != null && langCode.isNotEmpty) {
      _locale = Locale(langCode, '');
      notifyListeners();
    }
  }
}
