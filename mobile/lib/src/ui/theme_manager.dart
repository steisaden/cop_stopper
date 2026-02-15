import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';
import 'figma_theme.dart';

/// Theme manager for handling theme switching, persistence, and animation
class ThemeManager extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _highContrastKey = 'high_contrast';

  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = AppColors.primary;
  bool _isHighContrastEnabled = false;

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  bool get isHighContrastEnabled => _isHighContrastEnabled;

  ThemeManager() {
    _loadPreferences();
  }

  /// Load theme preferences from shared preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme mode
    final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
    _themeMode = _parseThemeMode(themeModeString);
    
    // Load accent color
    final accentColorInt = prefs.getInt(_accentColorKey) ?? AppColors.primary.value;
    _accentColor = Color(accentColorInt);
    
    // Load high contrast setting
    _isHighContrastEnabled = prefs.getBool(_highContrastKey) ?? false;
    
    notifyListeners();
  }

  /// Save theme preferences to shared preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_themeModeKey, _themeMode.name);
    await prefs.setInt(_accentColorKey, _accentColor.value);
    await prefs.setBool(_highContrastKey, _isHighContrastEnabled);
  }

  /// Change the theme mode
  void changeThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _savePreferences();
    notifyListeners();
  }

  /// Change the accent color
  void changeAccentColor(Color color) {
    _accentColor = color;
    _savePreferences();
    notifyListeners();
  }

  /// Toggle high contrast mode
  void toggleHighContrast(bool enabled) {
    _isHighContrastEnabled = enabled;
    _savePreferences();
    notifyListeners();
  }

  /// Get the current theme data based on settings - Using Figma theme
  ThemeData getTheme(BuildContext context) {
    final Brightness brightness = _themeMode == ThemeMode.dark
        ? Brightness.dark
        : _themeMode == ThemeMode.light
            ? Brightness.light
            : MediaQuery.of(context).platformBrightness;

    // Use Figma theme as the primary theme
    return FigmaTheme.getTheme(brightness);
  }

  /// Parse theme mode from string
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}