import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing text size preferences
class TextSizeService {
  static const String _textScaleFactorKey = 'text_scale_factor';

  final SharedPreferences _prefs;

  TextSizeService(this._prefs);

  /// Get the current text scale factor (default is 1.0)
  double get textScaleFactor => _prefs.getDouble(_textScaleFactorKey) ?? 1.0;

  /// Set the text scale factor
  Future<void> setTextScaleFactor(double factor) async {
    // Constrain the factor between reasonable limits
    final clampedFactor = factor.clamp(0.8, 2.0);
    await _prefs.setDouble(_textScaleFactorKey, clampedFactor);
  }

  /// Increase text size by 0.1
  Future<void> increaseTextSize() async {
    final currentFactor = textScaleFactor;
    await setTextScaleFactor(currentFactor + 0.1);
  }

  /// Decrease text size by 0.1
  Future<void> decreaseTextSize() async {
    final currentFactor = textScaleFactor;
    await setTextScaleFactor(currentFactor - 0.1);
  }

  /// Reset to default text size
  Future<void> resetTextSize() async {
    await _prefs.remove(_textScaleFactorKey);
  }
}