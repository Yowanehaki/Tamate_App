import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePreferenceKey = 'theme_preference';
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemePreference();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeData get currentTheme => _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePreferenceKey, _isDarkMode);
    
    notifyListeners();
  }
}