import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/background_theme.dart';

/// Persists visual preferences separately from gameplay save data.
class PreferencesService extends ChangeNotifier {
  static const _backgroundKey = 'selectedBackgroundThemeId';

  BackgroundTheme _selectedTheme = BackgroundThemes.defaultTheme;
  bool _isInitialized = false;

  BackgroundTheme get selectedTheme => _selectedTheme;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_backgroundKey);
    _selectedTheme = savedId != null
        ? BackgroundThemes.byId(savedId)
        : BackgroundThemes.defaultTheme;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setBackgroundTheme(BackgroundTheme theme) async {
    if (_selectedTheme.id == theme.id) return;

    _selectedTheme = theme;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, theme.id);
  }
}
