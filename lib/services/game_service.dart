import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/egg.dart';
import '../models/hatch_result.dart';
import '../models/mutation.dart';
import '../models/owned_animal.dart';
import '../models/player_state.dart';
import 'save_service.dart';

/// Central game logic: coins, hatching, mutations, idle income, and saving.
class GameService extends ChangeNotifier {
  GameService({SaveService? saveService, Random? random})
      : _saveService = saveService ?? SaveService(),
        _random = random ?? Random();

  final SaveService _saveService;
  final Random _random;

  PlayerState _state = GameData.startingPlayerState();
  Timer? _idleTimer;
  bool _isInitialized = false;

  // In-memory only — for developer testing, not saved.
  String? _forcedNextAnimalId;
  String? _forcedNextMutationId;

  PlayerState get state => _state;
  bool get isInitialized => _isInitialized;

  static Mutation _mutationFor(OwnedAnimal owned) {
    return GameData.mutationById(owned.mutationId) ?? GameData.mutations.first;
  }

  /// Income: base × mutationMultiplier × quantity × level.
  static int incomeFor(Animal animal, OwnedAnimal owned) {
    final mutation = _mutationFor(owned);
    return animal.coinsPerSecond *
        mutation.incomeMultiplier *
        owned.quantity *
        owned.level;
  }

  /// Upgrade cost: base × level × 50 (mutation does not affect cost).
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

  List<OwnedAnimal> get normalAnimals =>
      _state.ownedAnimals.where((o) => o.mutationId == 'none').toList();

  List<OwnedAnimal> get mutatedAnimals =>
      _state.ownedAnimals.where((o) => o.mutationId != 'none').toList();

  bool get hasForcedNextHatch =>
      _forcedNextAnimalId != null && _forcedNextMutationId != null;

  String? get forcedNextAnimalId => _forcedNextAnimalId;
  String? get forcedNextMutationId => _forcedNextMutationId;

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

  Future<void> save() async {
    _state = _state.copyWith(lastSavedTime: DateTime.now());
    await _saveService.save(_state);
  }

  bool canAfford(Egg egg) => _state.coins >= egg.cost;

  bool buyEgg(Egg egg) {
    if (!canAfford(egg)) return false;

    _state = _state.copyWith(coins: _state.coins - egg.cost);
    notifyListeners();
    save();
    return true;
  }

  void setCoins(int amount) {
    _state = _state.copyWith(coins: amount < 0 ? 0 : amount);
    notifyListeners();
    save();
  }

  void addCoins(int amount) {
    setCoins(_state.coins + amount);
  }

  void resetCoins() {
    setCoins(GameData.startingPlayerState().coins);
  }

  void setForcedNextHatch(String animalId, String mutationId) {
    _forcedNextAnimalId = animalId;
    _forcedNextMutationId = mutationId;
    notifyListeners();
  }

  void clearForcedNextHatch() {
    _forcedNextAnimalId = null;
    _forcedNextMutationId = null;
    notifyListeners();
  }

  /// Hatch a purchased egg, roll for mutation, and add to the collection.
  HatchResult hatchEgg(Egg egg) {
    final Animal animal;
    final Mutation mutation;

    if (hasForcedNextHatch) {
      animal = GameData.animalById(_forcedNextAnimalId!)!;
      mutation =
          GameData.mutationById(_forcedNextMutationId!) ?? GameData.mutations.first;
      clearForcedNextHatch();
    } else {
      final animalId = egg
          .possibleAnimalIds[_random.nextInt(egg.possibleAnimalIds.length)];
      animal = GameData.animalById(animalId)!;
      mutation = GameData.rollMutation(_random);
    }

    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final existingIndex = updatedAnimals.indexWhere(
      (owned) =>
          owned.animalId == animal.id && owned.mutationId == mutation.id,
    );

    if (existingIndex >= 0) {
      final existing = updatedAnimals[existingIndex];
      updatedAnimals[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedAnimals.add(
        OwnedAnimal(
          animalId: animal.id,
          quantity: 1,
          level: 1,
          mutationId: mutation.id,
        ),
      );
    }

    _state = _state.copyWith(ownedAnimals: updatedAnimals);
    notifyListeners();
    save();
    return HatchResult(animal: animal, mutation: mutation);
  }

  OwnedAnimal? ownedAnimal(String animalId, {String mutationId = 'none'}) {
    for (final owned in _state.ownedAnimals) {
      if (owned.animalId == animalId && owned.mutationId == mutationId) {
        return owned;
      }
    }
    return null;
  }

  bool canAffordUpgrade(String animalId, String mutationId) {
    final owned = ownedAnimal(animalId, mutationId: mutationId);
    final animal = GameData.animalById(animalId);
    if (owned == null || animal == null) return false;
    return _state.coins >= upgradeCostFor(animal, owned);
  }

  /// Upgrade a specific animal/mutation combo. Returns new level or null.
  int? upgradeAnimal(String animalId, String mutationId) {
    final owned = ownedAnimal(animalId, mutationId: mutationId);
    final animal = GameData.animalById(animalId);
    if (owned == null || animal == null) return null;

    final cost = upgradeCostFor(animal, owned);
    if (_state.coins < cost) return null;

    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final index = updatedAnimals.indexWhere(
      (entry) =>
          entry.animalId == animalId && entry.mutationId == mutationId,
    );
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

  @override
  void dispose() {
    _idleTimer?.cancel();
    save();
    super.dispose();
  }
}
