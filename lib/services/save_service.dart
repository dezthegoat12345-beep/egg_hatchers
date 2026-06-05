import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_state.dart';

/// Persists and restores player progress using shared_preferences.
class SaveService {
  static const _saveKey = 'egg_hatchers_player_state';

  Future<PlayerState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_saveKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PlayerState state) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_saveKey, jsonString);
  }
}
