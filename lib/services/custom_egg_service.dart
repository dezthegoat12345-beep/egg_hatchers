import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_egg.dart';
import '../models/egg.dart';

/// Persists player-created custom eggs in shared_preferences.
class CustomEggService extends ChangeNotifier {
  static const _storageKey = 'customEggs';

  final List<CustomEgg> _eggs = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  List<CustomEgg> get allEggs => List.unmodifiable(_eggs);

  /// Enabled custom eggs with at least one valid animal, for the shop.
  List<CustomEgg> get shopEggs =>
      _eggs.where((egg) => egg.isEnabled && egg.isValid).toList();

  List<Egg> get shopEggModels =>
      shopEggs.map((egg) => egg.toEgg()).toList(growable: false);

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _eggs.clear();

    final saved = prefs.getString(_storageKey);
    if (saved != null) {
      _eggs.addAll(CustomEgg.listFromJsonString(saved));
    }

    _isInitialized = true;
    notifyListeners();
  }

  CustomEgg? getById(String id) {
    for (final egg in _eggs) {
      if (egg.id == id) return egg;
    }
    return null;
  }

  Future<void> saveEgg(CustomEgg egg) async {
    final index = _eggs.indexWhere((e) => e.id == egg.id);
    if (index >= 0) {
      _eggs[index] = egg;
    } else {
      _eggs.add(egg);
    }

    notifyListeners();
    await _persist();
  }

  Future<void> deleteEgg(String id) async {
    _eggs.removeWhere((egg) => egg.id == id);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, CustomEgg.listToJsonString(_eggs));
  }
}
