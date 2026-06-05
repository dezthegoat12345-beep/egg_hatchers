import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/egg.dart';
import '../models/owned_animal.dart';
import '../models/player_state.dart';
import 'save_service.dart';

/// Central game logic: coins, hatching, idle income, and saving.
class GameService extends ChangeNotifier {
  GameService({SaveService? saveService, Random? random})
      : _saveService = saveService ?? SaveService(),
        _random = random ?? Random();

  final SaveService _saveService;
  final Random _random;

  PlayerState _state = GameData.startingPlayerState();
  Timer? _idleTimer;
  bool _isInitialized = false;

  PlayerState get state => _state;
  bool get isInitialized => _isInitialized;

  /// Income for one owned animal type: base × quantity × level.
  static int incomeFor(Animal animal, OwnedAnimal owned) {
    return animal.coinsPerSecond * owned.quantity * owned.level;
  }

  /// Upgrade cost: baseCoinsPerSecond × current level × 50.
  static int upgradeCostFor(Animal animal, OwnedAnimal owned) {
    return animal.coinsPerSecond * owned.level * 50;
  }

  /// Total coins earned per second from all owned animals.
  int get coinsPerSecond {
    var total = 0;
    for (final owned in _state.ownedAnimals) {
      final animal = GameData.animalById(owned.animalId);
      if (animal != null) {
        total += incomeFor(animal, owned);
      }
    }
    return total;
  }

  int get coins => _state.coins;
  List<OwnedAnimal> get ownedAnimals => List.unmodifiable(_state.ownedAnimals);

  /// Load saved progress, apply offline earnings, and start idle income.
  Future<void> initialize() async {
    final saved = await _saveService.load();
    if (saved != null) {
      _state = saved;
      _applyOfflineEarnings();
    } else {
      _state = GameData.startingPlayerState();
    }

    _isInitialized = true;
    _startIdleTimer();
    notifyListeners();
  }

  /// Apply coins earned while the app was closed.
  void _applyOfflineEarnings() {
    final now = DateTime.now();
    final elapsed = now.difference(_state.lastSavedTime);
    if (elapsed.isNegative) return;

    final earned = (coinsPerSecond * elapsed.inSeconds).floor();
    if (earned > 0) {
      _state = _state.copyWith(
        coins: _state.coins + earned,
        lastSavedTime: now,
      );
    }
  }

  void _startIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickIdleIncome();
    });
  }

  void _tickIdleIncome() {
    final income = coinsPerSecond;
    if (income <= 0) return;

    _state = _state.copyWith(
      coins: _state.coins + income,
      lastSavedTime: DateTime.now(),
    );
    notifyListeners();
    _saveQuietly();
  }

  Future<void> _saveQuietly() async {
    await _saveService.save(_state);
  }

  /// Save progress when leaving the app or after important actions.
  Future<void> save() async {
    _state = _state.copyWith(lastSavedTime: DateTime.now());
    await _saveService.save(_state);
  }

  bool canAfford(Egg egg) => _state.coins >= egg.cost;

  /// Spend coins to buy an egg. Returns false if the player cannot afford it.
  bool buyEgg(Egg egg) {
    if (!canAfford(egg)) return false;

    _state = _state.copyWith(coins: _state.coins - egg.cost);
    notifyListeners();
    save();
    return true;
  }

  /// Hatch a purchased egg and add the random animal to the collection.
  Animal hatchEgg(Egg egg) {
    final animalId = egg.possibleAnimalIds[
        _random.nextInt(egg.possibleAnimalIds.length)];
    final animal = GameData.animalById(animalId)!;

    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final existingIndex =
        updatedAnimals.indexWhere((owned) => owned.animalId == animal.id);

    if (existingIndex >= 0) {
      final existing = updatedAnimals[existingIndex];
      updatedAnimals[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedAnimals.add(
        OwnedAnimal(animalId: animal.id, quantity: 1, level: 1),
      );
    }

    _state = _state.copyWith(ownedAnimals: updatedAnimals);
    notifyListeners();
    save();
    return animal;
  }

  OwnedAnimal? ownedAnimal(String animalId) {
    for (final owned in _state.ownedAnimals) {
      if (owned.animalId == animalId) return owned;
    }
    return null;
  }

  bool canAffordUpgrade(String animalId) {
    final owned = ownedAnimal(animalId);
    final animal = GameData.animalById(animalId);
    if (owned == null || animal == null) return false;
    return _state.coins >= upgradeCostFor(animal, owned);
  }

  /// Upgrade an owned animal. Returns the new level, or null if it failed.
  int? upgradeAnimal(String animalId) {
    final owned = ownedAnimal(animalId);
    final animal = GameData.animalById(animalId);
    if (owned == null || animal == null) return null;

    final cost = upgradeCostFor(animal, owned);
    if (_state.coins < cost) return null;

    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final index =
        updatedAnimals.indexWhere((entry) => entry.animalId == animalId);
    if (index < 0) return null;

    final newLevel = owned.level + 1;
    updatedAnimals[index] = owned.copyWith(level: newLevel);

    _state = _state.copyWith(
      coins: _state.coins - cost,
      ownedAnimals: updatedAnimals,
    );
    notifyListeners();
    save();
    return newLevel;
  }

  int quantityOf(String animalId) {
    for (final owned in _state.ownedAnimals) {
      if (owned.animalId == animalId) return owned.quantity;
    }
    return 0;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    save();
    super.dispose();
  }
}
