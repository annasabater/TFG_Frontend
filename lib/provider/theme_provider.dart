import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const _key = 'isDarkMode';
  static const _daltonicKey = 'isDaltonicMode';
  static const _readingKey = 'isReadingMode';
  bool _isDarkMode = false;
  bool _isDaltonicMode = false;
  bool _isReadingMode = false;

  bool get isDarkMode => _isDarkMode;
  bool get isDaltonicMode => _isDaltonicMode;
  bool get isReadingMode => _isReadingMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveTheme();
  }

  void toggleDaltonicMode() {
    _isDaltonicMode = !_isDaltonicMode;
    notifyListeners();
    _saveDaltonicMode();
  }

  void toggleReadingMode() {
    _isReadingMode = !_isReadingMode;
    notifyListeners();
    _saveReadingMode();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? false;
    _isDaltonicMode = prefs.getBool(_daltonicKey) ?? false;
    _isReadingMode = prefs.getBool(_readingKey) ?? false;
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
  }

  Future<void> _saveDaltonicMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_daltonicKey, _isDaltonicMode);
  }

  Future<void> _saveReadingMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readingKey, _isReadingMode);
  }
} 