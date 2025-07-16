import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum định nghĩa các chế độ theme
enum AppThemeMode { light, dark, system }

/// Provider quản lý theme state
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  bool get isLightMode => _themeMode == AppThemeMode.light;

  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  bool get isSystemMode => _themeMode == AppThemeMode.system;

  /// Khởi tạo theme provider và load theme từ storage
  ThemeProvider() {
    _loadTheme();
  }

  /// Load theme từ SharedPreferences
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? AppThemeMode.system.index;
      _themeMode = AppThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme: $e');
      _themeMode = AppThemeMode.system;
    }
  }

  /// Lưu theme vào SharedPreferences
  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Thay đổi theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
  }

  /// Toggle giữa light và dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == AppThemeMode.light) {
      await setThemeMode(AppThemeMode.dark);
    } else {
      await setThemeMode(AppThemeMode.light);
    }
  }

  /// Chuyển sang light mode
  Future<void> setLightMode() async {
    await setThemeMode(AppThemeMode.light);
  }

  /// Chuyển sang dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(AppThemeMode.dark);
  }

  /// Chuyển sang system mode
  Future<void> setSystemMode() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Reset theme về default (system)
  Future<void> resetTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Lấy theme mode hiện tại dưới dạng string
  String get themeModeString {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Lấy icon phù hợp cho theme mode hiện tại
  IconData get themeIcon {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  /// Lấy Flutter ThemeMode từ custom AppThemeMode
  ThemeMode get flutterThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
