import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light; // Forzato su light mode
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isLightMode => !_isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      // Forza sempre la light mode - dark mode disabilitata
      _themeMode = ThemeMode.light;
      _updateDarkMode();
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    // Dark mode disabilitata - ignora qualsiasi tentativo di cambiare il tema
    // Forza sempre la light mode
    if (_themeMode == ThemeMode.light) return;

    _themeMode = ThemeMode.light;
    _updateDarkMode();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, ThemeMode.light.index);
    } catch (e) {
      print('Error saving theme: $e');
    }

    _safeNotifyListeners();
  }

  void _updateDarkMode() {
    switch (_themeMode) {
      case ThemeMode.light:
        _isDarkMode = false;
        break;
      case ThemeMode.dark:
        _isDarkMode = true;
        break;
      case ThemeMode.system:
        // This will be updated by the system
        break;
    }
  }

  void updateSystemTheme(Brightness brightness) {
    if (_themeMode == ThemeMode.system) {
      _isDarkMode = brightness == Brightness.dark;
      _safeNotifyListeners();
    }
  }

  // Convenience methods - Dark mode disabilitata
  Future<void> toggleTheme() async {
    // Dark mode disabilitata - non fa nulla
    return;
  }

  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  Future<void> setDarkMode() async {
    // Dark mode disabilitata - forza light mode
    await setThemeMode(ThemeMode.light);
  }

  Future<void> setSystemMode() async {
    // Dark mode disabilitata - forza light mode
    await setThemeMode(ThemeMode.light);
  }

  void _safeNotifyListeners() {
    // Evita di chiamare notifyListeners durante la fase di build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
