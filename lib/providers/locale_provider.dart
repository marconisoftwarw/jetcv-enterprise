import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('it', 'IT');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'it';
    final countryCode = prefs.getString('country_code') ?? 'IT';
    _locale = Locale(languageCode, countryCode);
    notifyListeners();
  }

  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    _locale = newLocale;

    // Salva la lingua nelle preferenze
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
    await prefs.setString('country_code', newLocale.countryCode ?? '');

    notifyListeners();
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'it':
        return 'Italiano';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return languageCode;
    }
  }

  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    ];
  }
}
