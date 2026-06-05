import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/game_data.dart';
import '../models/custom_sprite_data.dart';

/// Persists per-animal custom pixel sprites in shared_preferences.
class CustomSpriteService extends ChangeNotifier {
  static String _keyFor(String animalId) => 'customSprite_$animalId';

  final Map<String, CustomSpriteData> _sprites = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _sprites.clear();

    for (final animal in GameData.animals) {
      final saved = prefs.getString(_keyFor(animal.id));
      if (saved == null) continue;

      try {
        final sprite = CustomSpriteData.fromJsonString(saved);
        if (sprite.hasVisiblePixels) {
          _sprites[animal.id] = sprite;
        }
      } catch (_) {
        // Ignore corrupt entries.
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  CustomSpriteData? getSprite(String animalId) => _sprites[animalId];

  bool hasCustomSprite(String animalId) => _sprites.containsKey(animalId);

  Future<void> saveSprite(String animalId, CustomSpriteData data) async {
    if (!data.hasVisiblePixels) {
      await resetSprite(animalId);
      return;
    }

    _sprites[animalId] = data;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFor(animalId), data.toJsonString());
  }

  Future<void> resetSprite(String animalId) async {
    _sprites.remove(animalId);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFor(animalId));
  }
}
