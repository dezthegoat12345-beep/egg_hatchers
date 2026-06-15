import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/game_data.dart';
import '../data/quest_data.dart';
import '../models/animal.dart';
import '../models/custom_egg.dart';
import '../models/egg.dart';
import '../models/forced_hatch_result.dart';
import '../models/hatch_result.dart';
import '../utils/custom_egg_logic.dart';
import '../utils/luck_logic.dart';
import '../models/mutation.dart';
import '../models/owned_animal.dart';
import '../models/player_state.dart';
import '../models/quest.dart';
import '../models/quest_progress.dart';
import '../utils/quest_logic.dart';
import '../utils/rebirth_logic.dart';
import '../utils/animal_sell_logic.dart';
import '../utils/sprite_rating_logic.dart';
import 'save_service.dart';
import 'sprite_reference_overlay_service.dart';

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
  String? _pendingQuestNotification;
  bool _questNotificationDeferred = false;

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

  /// Sell value for one animal from this owned stack.
  static int sellValueFor(Animal animal, OwnedAnimal owned) {
    return AnimalSellLogic.sellValueFor(animal, owned);
  }

  bool canSellOwnedAnimal(
    String animalId,
    String mutationId, {
    int quantity = 1,
  }) {
    if (quantity < 1) return false;
    final owned = ownedAnimal(animalId, mutationId: mutationId);
    return owned != null && owned.quantity >= quantity;
  }

  /// Sells animals from a specific stack. Returns coins granted, or null.
  int? sellOwnedAnimal(
    String animalId,
    String mutationId, {
    int quantity = 1,
  }) {
    if (!canSellOwnedAnimal(animalId, mutationId, quantity: quantity)) {
      return null;
    }

    final owned = ownedAnimal(animalId, mutationId: mutationId)!;
    final animal = GameData.animalById(animalId);
    if (animal == null) return null;

    final unitValue = sellValueFor(animal, owned);
    final coinsGranted = unitValue * quantity;
    if (coinsGranted <= 0) return null;

    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final index = updatedAnimals.indexWhere(
      (entry) =>
          entry.animalId == animalId && entry.mutationId == mutationId,
    );
    if (index < 0) return null;

    final remaining = owned.quantity - quantity;
    if (remaining <= 0) {
      updatedAnimals.removeAt(index);
    } else {
      updatedAnimals[index] = owned.copyWith(quantity: remaining);
    }

    _state = _state.copyWith(
      coins: _state.coins + coinsGranted,
      ownedAnimals: updatedAnimals,
    );
    notifyListeners();
    save();
    return coinsGranted;
  }

  /// Total coins earned per second from all owned animals (includes rebirth).
  int get coinsPerSecond {
    var total = 0;
    for (final owned in _state.ownedAnimals) {
      final animal = GameData.animalById(owned.animalId);
      if (animal != null) {
        total += incomeFor(animal, owned);
      }
    }
    return RebirthLogic.applyMultiplier(total, _state.rebirthLevel);
  }

  int get baseCoinsPerSecond {
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
  int get luckLevel => _state.luckLevel;
  int get rebirthLevel => _state.rebirthLevel;
  double get incomeMultiplier =>
      RebirthLogic.incomeMultiplier(_state.rebirthLevel);
  bool get canRebirth => RebirthLogic.canRebirth(_state.lifetimeCoinsEarned);
  int get rebirthRequirement => RebirthLogic.unlockLifetimeCoins;
  bool get secretToolsCoinsClaimed => _state.secretToolsCoinsClaimed;
  static const int secretToolsCoinReward = 500;
  QuestProgress get questProgress => _state.questProgress;
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

    _silenceExistingQuestNotifications();
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
    _refreshQuestNotifications();
  }

  /// Returns and clears a pending quest completion notification message.
  String? consumePendingQuestNotification() {
    if (_questNotificationDeferred) return null;
    final message = _pendingQuestNotification;
    _pendingQuestNotification = null;
    return message;
  }

  /// Releases a hatch-deferred notification after the reveal dialog closes.
  String? releaseDeferredQuestNotification() {
    if (!_questNotificationDeferred) return null;
    _questNotificationDeferred = false;
    final message = _pendingQuestNotification;
    _pendingQuestNotification = null;
    return message;
  }

  bool get isQuestNotificationDeferred => _questNotificationDeferred;

  void _silenceExistingQuestNotifications() {
    final progress = _state.questProgress;
    final toAdd = <String>[];
    for (final quest in QuestData.all) {
      if (progress.wasCompletionNotified(quest.id)) continue;
      final status = QuestLogic.status(quest, _state);
      if (status == QuestStatus.readyToClaim || status == QuestStatus.claimed) {
        toAdd.add(quest.id);
      }
    }
    if (toAdd.isEmpty) return;

    _state = _state.copyWith(
      questProgress: progress.copyWith(
        notifiedCompletedQuestIds: [
          ...progress.notifiedCompletedQuestIds,
          ...toAdd,
        ],
      ),
    );
    _saveQuietly();
  }

  void _refreshQuestNotifications({bool deferDisplay = false}) {
    final newlyCompleted = QuestLogic.newlyCompletedUnnotified(_state);
    if (newlyCompleted.isEmpty) return;

    _pendingQuestNotification =
        QuestLogic.completionNotificationMessage(newlyCompleted);
    if (deferDisplay) {
      _questNotificationDeferred = true;
    }
    final progress = _state.questProgress;
    _state = _state.copyWith(
      questProgress: progress.copyWith(
        notifiedCompletedQuestIds: [
          ...progress.notifiedCompletedQuestIds,
          ...newlyCompleted.map((quest) => quest.id),
        ],
      ),
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
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void addLifetimeCoinsEarned(int amount) {
    setLifetimeCoinsEarned(_state.lifetimeCoinsEarned + amount);
  }

  void resetLifetimeCoinsEarned() {
    setLifetimeCoinsEarned(0);
  }

  int get luckUpgradeCost => LuckLogic.upgradeCost(_state.luckLevel);

  bool get isLuckMaxed => _state.luckLevel >= LuckLogic.maxLevel;

  bool canAffordLuckUpgrade() =>
      !isLuckMaxed && _state.coins >= luckUpgradeCost;

  /// Upgrade luck if affordable. Returns new level or null on failure.
  int? upgradeLuck() {
    if (isLuckMaxed) return null;
    final cost = luckUpgradeCost;
    if (_state.coins < cost) return null;

    final newLevel = _state.luckLevel + 1;
    _state = _state.copyWith(
      coins: _state.coins - cost,
      luckLevel: newLevel,
      questProgress: _state.questProgress.copyWith(
        totalLuckUpgrades: _state.questProgress.totalLuckUpgrades + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
    return newLevel;
  }

  void setLuckLevel(int level) {
    _state = _state.copyWith(luckLevel: LuckLogic.clampLevel(level));
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void resetLuckLevel() => setLuckLevel(LuckLogic.minLevel);

  void maxLuckLevel() => setLuckLevel(LuckLogic.maxLevel);

  /// Rebirth if eligible. Resets progress and increases rebirth level.
  bool performRebirth() {
    if (!canRebirth) return false;

    final newRebirthLevel = _state.rebirthLevel + 1;
    final secretClaimed = _state.secretToolsCoinsClaimed;
    _state = PlayerState(
      coins: GameData.startingPlayerState().coins,
      ownedAnimals: const [],
      lastSavedTime: DateTime.now(),
      lifetimeCoinsEarned: 0,
      luckLevel: 1,
      rebirthLevel: newRebirthLevel,
      questProgress: QuestProgress.initial(),
      secretToolsCoinsClaimed: secretClaimed,
    );
    _pendingQuestNotification = null;
    _questNotificationDeferred = false;
    _refreshQuestNotifications();
    notifyListeners();
    save();
    return true;
  }

  void setRebirthLevel(int level) {
    _state = _state.copyWith(rebirthLevel: level < 0 ? 0 : level);
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devIncrementRebirthLevel() => setRebirthLevel(_state.rebirthLevel + 1);

  void resetRebirthLevel() => setRebirthLevel(0);

  /// Claim a completed quest reward. Returns coins granted, or null on failure.
  int? claimQuest(String questId) {
    Quest? quest;
    for (final candidate in QuestData.all) {
      if (candidate.id == questId) {
        quest = candidate;
        break;
      }
    }
    if (quest == null) return null;
    if (_state.questProgress.isQuestClaimed(questId)) return null;
    if (!QuestLogic.isComplete(quest, _state)) return null;

    if (quest.showsSecretHintOnClaim) {
      _state = _state.copyWith(
        questProgress: _state.questProgress.copyWith(
          claimedQuestIds: [
            ..._state.questProgress.claimedQuestIds,
            questId,
          ],
        ),
      );
      notifyListeners();
      save();
      return 0;
    }

    _state = _state.copyWith(
      coins: _state.coins + quest.rewardCoins,
      questProgress: _state.questProgress.copyWith(
        claimedQuestIds: [
          ..._state.questProgress.claimedQuestIds,
          questId,
        ],
      ),
    );
    notifyListeners();
    save();
    return quest.rewardCoins;
  }

  /// Grants sprite rating bonus coins without affecting lifetime earnings.
  int? grantSpriteRatingReward(int coins) {
    if (coins <= 0) return null;
    _state = _state.copyWith(coins: _state.coins + coins);
    notifyListeners();
    save();
    return coins;
  }

  /// One-time secret hatchery coin bonus — does not affect lifetime earnings.
  int? claimSecretToolsCoins() {
    if (_state.secretToolsCoinsClaimed) return null;
    _state = _state.copyWith(
      coins: _state.coins + secretToolsCoinReward,
      secretToolsCoinsClaimed: true,
    );
    notifyListeners();
    save();
    return secretToolsCoinReward;
  }

  /// One-time reference overlay unlock cost for an animal.
  int referenceOverlayCostForAnimal(
    String animalId, {
    int? displayedReward,
  }) {
    return SpriteRatingLogic.referenceOverlayCostForAnimal(
      animalId: animalId,
      currentCoins: _state.coins,
      displayedReward: displayedReward,
    );
  }

  bool canAffordReferenceOverlay(
    String animalId, {
    int? displayedReward,
  }) {
    final cost = referenceOverlayCostForAnimal(
      animalId,
      displayedReward: displayedReward,
    );
    return cost > 0 && _state.coins >= cost;
  }

  /// Spends coins for a reference overlay unlock without affecting lifetime earnings.
  Future<bool> unlockReferenceOverlay(
    String animalId,
    SpriteReferenceOverlayService overlayService, {
    int? displayedReward,
  }) async {
    if (overlayService.isUnlocked(animalId)) return true;

    final cost = referenceOverlayCostForAnimal(
      animalId,
      displayedReward: displayedReward,
    );
    if (cost <= 0 || _state.coins < cost) return false;

    _state = _state.copyWith(coins: _state.coins - cost);
    notifyListeners();
    save();
    await overlayService.unlock(animalId);
    recordReferenceOverlayUnlocked();
    return true;
  }

  /// Records a successful Rate Sprite (Beta) rating on a supported animal.
  void recordSpriteRated({
    required String animalId,
    required int score,
    required String spriteHash,
  }) {
    var progress = _state.questProgress.copyWith(
      totalSpritesRated: _state.questProgress.totalSpritesRated + 1,
      bestSpriteRatingScore: max(
        _state.questProgress.bestSpriteRatingScore,
        score,
      ),
    );

    if (score == 10) {
      final perfectKey = '$animalId:$spriteHash';
      if (!progress.perfectRatedSpriteKeys.contains(perfectKey)) {
        progress = progress.copyWith(
          totalPerfectSpriteRatings: progress.totalPerfectSpriteRatings + 1,
          perfectRatedSpriteKeys: [
            ...progress.perfectRatedSpriteKeys,
            perfectKey,
          ],
        );
      }
    }

    _state = _state.copyWith(questProgress: progress);
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  /// Records a successful sprite rating reward claim (not a duplicate).
  void recordSpriteRatingRewardClaimed() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalSpriteRatingRewardsClaimed:
            _state.questProgress.totalSpriteRatingRewardsClaimed + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  /// Records a newly purchased reference overlay unlock.
  void recordReferenceOverlayUnlocked() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalReferenceOverlaysUnlocked:
            _state.questProgress.totalReferenceOverlaysUnlocked + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void recordCustomEggCreated() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalCustomEggsCreated:
            _state.questProgress.totalCustomEggsCreated + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddEggsHatched(int count) {
    if (count <= 0) return;
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalEggsHatched: _state.questProgress.totalEggsHatched + count,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddMutationHatched({String mutationId = 'golden'}) {
    var progress = _state.questProgress.copyWith(
      totalMutationsHatched: _state.questProgress.totalMutationsHatched + 1,
    );
    switch (mutationId) {
      case 'golden':
        progress = progress.copyWith(
          totalGoldenHatched: progress.totalGoldenHatched + 1,
        );
      case 'rainbow':
        progress = progress.copyWith(
          totalRainbowHatched: progress.totalRainbowHatched + 1,
        );
      case 'shadow':
        progress = progress.copyWith(
          totalShadowHatched: progress.totalShadowHatched + 1,
        );
    }
    _state = _state.copyWith(questProgress: progress);
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddAnimalUpgrade() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalAnimalUpgrades: _state.questProgress.totalAnimalUpgrades + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  /// Grants one normal copy of every base animal not yet owned.
  void devCollectAllAnimals() {
    final updatedAnimals = List<OwnedAnimal>.from(_state.ownedAnimals);
    final ownedIds = updatedAnimals.map((owned) => owned.animalId).toSet();

    for (final animal in GameData.animals) {
      if (ownedIds.contains(animal.id)) continue;
      updatedAnimals.add(
        OwnedAnimal(animalId: animal.id, quantity: 1),
      );
      ownedIds.add(animal.id);
    }

    _state = _state.copyWith(ownedAnimals: updatedAnimals);
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devResetQuestStats() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalEggsHatched: 0,
        totalSingleHatches: 0,
        totalTripleHatches: 0,
        totalMutationsHatched: 0,
        totalGoldenHatched: 0,
        totalRainbowHatched: 0,
        totalShadowHatched: 0,
        totalAnimalUpgrades: 0,
        totalLuckUpgrades: 0,
        totalCustomEggsCreated: 0,
        totalCustomEggHatches: 0,
        totalCustomTripleHatches: 0,
        totalSpritesRated: 0,
        totalSpriteRatingRewardsClaimed: 0,
        bestSpriteRatingScore: 0,
        totalPerfectSpriteRatings: 0,
        totalReferenceOverlaysUnlocked: 0,
        perfectRatedSpriteKeys: const [],
        notifiedCompletedQuestIds: const [],
      ),
    );
    notifyListeners();
    save();
  }

  void devClearClaimedQuests() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(claimedQuestIds: const []),
    );
    notifyListeners();
    save();
  }

  void devResetSpriteQuestStats() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalSpritesRated: 0,
        totalSpriteRatingRewardsClaimed: 0,
        bestSpriteRatingScore: 0,
        totalPerfectSpriteRatings: 0,
        totalReferenceOverlaysUnlocked: 0,
        perfectRatedSpriteKeys: const [],
        notifiedCompletedQuestIds: const [],
      ),
    );
    notifyListeners();
    save();
  }

  void devSetBestSpriteRatingScore(int score) {
    final clamped = score.clamp(0, 10);
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        bestSpriteRatingScore: clamped,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddSpriteRated() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalSpritesRated: _state.questProgress.totalSpritesRated + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddSpriteRewardClaimed() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalSpriteRatingRewardsClaimed:
            _state.questProgress.totalSpriteRatingRewardsClaimed + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
  }

  void devAddOverlayUnlocked() {
    _state = _state.copyWith(
      questProgress: _state.questProgress.copyWith(
        totalReferenceOverlaysUnlocked:
            _state.questProgress.totalReferenceOverlaysUnlocked + 1,
      ),
    );
    _refreshQuestNotifications();
    notifyListeners();
    save();
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
    _recordHatchSession(
      results: [result],
      isTripleHatch: false,
      isCustomEgg: customEgg != null,
    );
    _refreshQuestNotifications(deferDisplay: true);
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

    _recordHatchSession(
      results: results,
      isTripleHatch: isTripleHatchSession,
      isCustomEgg: customEgg != null,
    );
    _refreshQuestNotifications(deferDisplay: true);
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
      mutation = LuckLogic.rollMutation(_random, _state.luckLevel);
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

  void _recordHatchSession({
    required List<HatchResult> results,
    required bool isTripleHatch,
    required bool isCustomEgg,
  }) {
    if (results.isEmpty) return;

    var progress = _state.questProgress;
    progress = progress.copyWith(
      totalEggsHatched: progress.totalEggsHatched + results.length,
      totalSingleHatches: isTripleHatch
          ? progress.totalSingleHatches
          : progress.totalSingleHatches + 1,
      totalTripleHatches: isTripleHatch
          ? progress.totalTripleHatches + 1
          : progress.totalTripleHatches,
    );

    if (isCustomEgg) {
      progress = progress.copyWith(
        totalCustomEggHatches:
            progress.totalCustomEggHatches + results.length,
      );
      if (isTripleHatch) {
        progress = progress.copyWith(
          totalCustomTripleHatches: progress.totalCustomTripleHatches + 1,
        );
      }
    }

    for (final result in results) {
      if (result.mutation.isNormal) continue;
      progress = progress.copyWith(
        totalMutationsHatched: progress.totalMutationsHatched + 1,
      );
      switch (result.mutation.id) {
        case 'golden':
          progress = progress.copyWith(
            totalGoldenHatched: progress.totalGoldenHatched + 1,
          );
        case 'rainbow':
          progress = progress.copyWith(
            totalRainbowHatched: progress.totalRainbowHatched + 1,
          );
        case 'shadow':
          progress = progress.copyWith(
            totalShadowHatched: progress.totalShadowHatched + 1,
          );
      }
    }

    _state = _state.copyWith(questProgress: progress);
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
      questProgress: _state.questProgress.copyWith(
        totalAnimalUpgrades: _state.questProgress.totalAnimalUpgrades + 1,
      ),
    );
    _refreshQuestNotifications();
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
