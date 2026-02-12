import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/constant.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme
  Color? _selectedSeedColor = fallbackColor;
  bool _isDynamicColor = true; // Default to dynamic color

  static const String _themeModeKey = 'themeMode';
  static const String _seedColorIndexKey = 'seedColorIndex';
  static const String _isDynamicColorKey = 'isDynamicColor';

  ThemeProvider() {
    _loadThemeSettings();
  }

  ThemeMode get themeMode => _themeMode;

  Color? get selectedSeedColor => _selectedSeedColor;

  bool get isDynamicColor => _isDynamicColor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeSettings();
    notifyListeners();
  }

  void setSelectedSeedColor(Color? color) {
    _selectedSeedColor = color;
    _isDynamicColor = false; // When a seed color is chosen, dynamic is off
    _saveThemeSettings();
    notifyListeners();
  }

  void setDynamicColor(bool isDynamic) {
    _isDynamicColor = isDynamic;
    if (isDynamic) {
      _selectedSeedColor =
      null; // If dynamic, no specific seed color is selected
    } else if (_selectedSeedColor == null && seedColorList.isNotEmpty) {
      // If turning off dynamic and no color was previously selected, default to first
      _selectedSeedColor = fallbackColor;
    }
    _saveThemeSettings();
    notifyListeners();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey);
    if (themeModeIndex != null) {
      _themeMode = ThemeMode.values[themeModeIndex];
    }

    final isDynamic = prefs.getBool(_isDynamicColorKey);
    if (isDynamic != null) {
      _isDynamicColor = isDynamic;
    }

    final seedColorIndex = prefs.getInt(_seedColorIndexKey);
    if (!_isDynamicColor && seedColorIndex != null &&
        seedColorIndex < seedColorList.length) {
      _selectedSeedColor = seedColorList[seedColorIndex];
    } else if (!_isDynamicColor && seedColorList.isNotEmpty) {
      // Fallback if saved index is invalid or no dynamic color
      _selectedSeedColor = fallbackColor;
    } else {
      _selectedSeedColor = null; // Dynamic color is active
    }

    notifyListeners();
  }

  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
    await prefs.setBool(_isDynamicColorKey, _isDynamicColor);
    if (_selectedSeedColor != null) {
      final index = seedColorList.indexOf(_selectedSeedColor!);
      if (index != -1) {
        await prefs.setInt(_seedColorIndexKey, index);
      }
    } else {
      await prefs.remove(
          _seedColorIndexKey); // Remove if no seed color (dynamic)
    }
  }
}
