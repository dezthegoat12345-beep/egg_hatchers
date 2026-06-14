import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/custom_egg.dart';
import '../models/egg.dart';
import '../models/forced_hatch_result.dart';
import '../models/hatch_result.dart';
import '../utils/custom_egg_logic.dart';
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
  ForcedHatchMode _forcedHatchMode = ForcedHatchMode.none;
  List<ForcedHatchResult> _forcedHatchQueue = [];

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

  /// Upgrade cost: base × level × 30 (mutation does not affect cost).
  static int upgradeCostFor(Animal animal, OwnedAnimal owned) {
    return animal.coinsPerSecond * owned.level * 30;
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
  int get lifetimeCoinsEarned => _state.lifetimeCoinsEarned;
  List<OwnedAnimal> get ownedAnimals => List.unmodifiable(_state.ownedAnimals);

  List<OwnedAnimal> get normalAnimals =>
      _state.ownedAnimals.where((o) => o.mutationId == 'none').toList();

  List<OwnedAnimal> get mutatedAnimals =>
      _state.ownedAnimals.where((o) => o.mutationId != 'none').toList();

  bool get hasForcedNextHatch => _forcedHatchQueue.isNotEmpty;

  bool get isForcedTripleHatch =>
      _forcedHatchMode == ForcedHatchMode.triple && _forcedHatchQueue.length >= 3;

  List<ForcedHatchResult> get forcedHatchQueue =>
      List<ForcedHatchResult>.unmodifiable(_forcedHatchQueue);

  String? get forcedNextAnimalId =>
      _forcedHatchQueue.isEmpty ? null : _forcedHatchQueue.first.animalId;

  String? get forcedNextMutationId =>
      _forcedHatchQueue.isEmpty ? null : _forcedHatchQueue.first.mutationId;

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
      _addEarnedCoins(earned, lastSavedTime: now);
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

    _addEarnedCoins(income);
    notifyListeners();
    _saveQuietly();
  }

  /// Adds coins from animal income and tracks lifetime earnings.
  void _addEarnedCoins(int amount, {DateTime? lastSavedTime}) {
    if (amount <= 0) return;
    _state = _state.copyWith(
      coins: _state.coins + amount,
      lifetimeCoinsEarned: _state.lifetimeCoinsEarned + amount,
      lastSavedTime: lastSavedTime ?? DateTime.now(),
    );
  }

  Future<void> _saveQuietly() async {
    await _saveService.save(_state);
  }

  Future<void> save() async {
    _state = _state.copyWith(lastSavedTime: DateTime.now());
    await _saveService.save(_state);
  }

  bool isEggUnlocked(Egg egg) =>
      egg.isUnlocked(_state.lifetimeCoinsEarned);

  bool canAfford(Egg egg) => _state.coins >= egg.cost;

  bool canBuyEgg(Egg egg) => isEggUnlocked(egg) && canAfford(egg);

  /// Triple Hatch costs 3.5× the egg price, rounded up.
  static int tripleHatchCost(Egg egg) => (egg.cost * 3.5).ceil();

  bool canAffordTripleHatch(Egg egg) =>
      isEggUnlocked(egg) && _state.coins >= tripleHatchCost(egg);

  bool buyEgg(Egg egg) {
    if (!canBuyEgg(egg)) return false;

    _state = _state.copyWith(coins: _state.coins - egg.cost);
    notifyListeners();
    save();
    return true;
  }

  bool buyTripleHatch(Egg egg) {
    if (!isEggUnlocked(egg)) return false;

    final cost = tripleHatchCost(egg);
    if (_state.coins < cost) return false;

    _state = _state.copyWith(coins: _state.coins - cost);
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

  void setLifetimeCoinsEarned(int amount) {
    _state = _state.copyWith(
      lifetimeCoinsEarned: amount < 0 ? 0 : amount,
    );
    notifyListeners();
    save();
  }

  void addLifetimeCoinsEarned(int amount) {
    setLifetimeCoinsEarned(_state.lifetimeCoinsEarned + amount);
  }

  void resetLifetimeCoinsEarned() {
    setLifetimeCoinsEarned(0);
  }

  void setForcedNextHatch(String animalId, String mutationId) {
    _forcedHatchQueue = [
      ForcedHatchResult(animalId: animalId, mutationId: mutationId),
    ];
    _forcedHatchMode = ForcedHatchMode.single;
    notifyListeners();
  }

  void setForcedNextTripleHatch(List<ForcedHatchResult> results) {
    _forcedHatchQueue = results
        .take(3)
        .map(
          (r) => ForcedHatchResult(
            animalId: r.animalId,
            mutationId: r.mutationId,
          ),
        )
        .toList();
    _forcedHatchMode = _forcedHatchQueue.length >= 3
        ? ForcedHatchMode.triple
        : ForcedHatchMode.single;
    notifyListeners();
  }

  void clearForcedNextHatch() {
    _forcedHatchQueue = [];
    _forcedHatchMode = ForcedHatchMode.none;
    notifyListeners();
  }

  /// Hatch a purchased egg, roll for mutation, and add to the collection.
  ///
  /// Pass [customEgg] when hatching a player-created custom egg so weighted
  /// chances apply. Built-in eggs use equal random selection.
  HatchResult hatchEgg(Egg egg, {CustomEgg? customEgg}) {
    final result = _rollAndApplyHatch(
      egg,
      customEgg: customEgg,
      slotIndex: 0,
      isTripleHatchSession: false,
    );
    notifyListeners();
    save();
    return result;
  }

  /// Hatch multiple animals from one purchase.
  List<HatchResult> hatchEggMultiple(
    Egg egg,
    int count, {
    CustomEgg? customEgg,
  }) {
    if (count <= 0) return const [];

    final isTripleHatchSession = count >= 3;
    final results = <HatchResult>[];
    for (var i = 0; i < count; i++) {
      results.add(
        _rollAndApplyHatch(
          egg,
          customEgg: customEgg,
          slotIndex: i,
          isTripleHatchSession: isTripleHatchSession,
        ),
      );
    }

    notifyListeners();
    save();
    return results;
  }

  ForcedHatchResult? _forcedResultForSlot(int slotIndex) {
    if (_forcedHatchQueue.isEmpty) return null;

    if (_forcedHatchMode == ForcedHatchMode.single) {
      return slotIndex == 0 ? _forcedHatchQueue.first : null;
    }

    if (slotIndex < _forcedHatchQueue.length) {
      return _forcedHatchQueue[slotIndex];
    }
    return null;
  }

  void _afterForcedSlotConsumed(
    int slotIndex, {
    required bool isTripleHatchSession,
  }) {
    if (_forcedHatchQueue.isEmpty) return;

    if (_forcedHatchMode == ForcedHatchMode.single) {
      if (slotIndex == 0) clearForcedNextHatch();
      return;
    }

    if (!isTripleHatchSession) {
      clearForcedNextHatch();
      return;
    }

    if (slotIndex >= 2) {
      clearForcedNextHatch();
    }
  }

  HatchResult _rollAndApplyHatch(
    Egg egg, {
    CustomEgg? customEgg,
    required int slotIndex,
    required bool isTripleHatchSession,
  }) {
    final Animal animal;
    final Mutation mutation;

    final forced = _forcedResultForSlot(slotIndex);
    if (forced != null) {
      animal = GameData.animalById(forced.animalId)!;
      mutation =
          GameData.mutationById(forced.mutationId) ?? GameData.mutations.first;
      _afterForcedSlotConsumed(
        slotIndex,
        isTripleHatchSession: isTripleHatchSession,
      );
    } else {
      final String animalId;
      if (customEgg != null &&
          customEgg.isValid &&
          customEgg.id == egg.id) {
        animalId = CustomEggLogic.weightedRandomAnimal(
          customEgg,
          _random,
          lifetimeCoinsEarned: _state.lifetimeCoinsEarned,
        );
      } else {
        animalId = egg
            .possibleAnimalIds[_random.nextInt(egg.possibleAnimalIds.length)];
      }
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
