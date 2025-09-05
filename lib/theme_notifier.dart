import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  String _lightBg = "assets/light-bg.png";
  String _darkBg = "assets/dark-bg.png";

  bool get isDarkMode => _isDarkMode;
  String get backgroundImage => _isDarkMode ? _darkBg : _lightBg;

  ThemeMode get currentThemeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
