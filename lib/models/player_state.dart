import 'active_auto_battle.dart';
import 'owned_animal.dart';
import 'quest_progress.dart';

/// All progress the player has made in the game.
class PlayerState {
  const PlayerState({
    required this.coins,
    required this.ownedAnimals,
    required this.lastSavedTime,
    required this.lifetimeCoinsEarned,
    this.luckLevel = 1,
    this.rebirthLevel = 0,
    this.questProgress = const QuestProgress(),
    this.secretSpaceEggClaimed = false,
    this.fullDeveloperToolsUnlocked = false,
    this.battleTokens = 0,
    this.bossWins = const {},
    this.hardPhaseWins = const {},
    this.bossMutationUnlocked = false,
    this.activeAutoBattle,
  });

  final int coins;
  final List<OwnedAnimal> ownedAnimals;
  final DateTime lastSavedTime;
  final int lifetimeCoinsEarned;
  final int luckLevel;
  final int rebirthLevel;
  final QuestProgress questProgress;
  final bool secretSpaceEggClaimed;
  final bool fullDeveloperToolsUnlocked;
  final int battleTokens;
  final Map<String, int> bossWins;
  final Map<String, int> hardPhaseWins;
  final bool bossMutationUnlocked;
  final ActiveAutoBattle? activeAutoBattle;

  static PlayerState initial() {
    return PlayerState(
      coins: 250,
      ownedAnimals: const [],
      lastSavedTime: DateTime.now(),
      lifetimeCoinsEarned: 0,
      luckLevel: 1,
      rebirthLevel: 0,
      questProgress: QuestProgress.initial(),
    );
  }

  PlayerState copyWith({
    int? coins,
    List<OwnedAnimal>? ownedAnimals,
    DateTime? lastSavedTime,
    int? lifetimeCoinsEarned,
    int? luckLevel,
    int? rebirthLevel,
    QuestProgress? questProgress,
    bool? secretSpaceEggClaimed,
    bool? fullDeveloperToolsUnlocked,
    int? battleTokens,
    Map<String, int>? bossWins,
    Map<String, int>? hardPhaseWins,
    bool? bossMutationUnlocked,
    ActiveAutoBattle? activeAutoBattle,
    bool clearActiveAutoBattle = false,
  }) {
    return PlayerState(
      coins: coins ?? this.coins,
      ownedAnimals: ownedAnimals ?? this.ownedAnimals,
      lastSavedTime: lastSavedTime ?? this.lastSavedTime,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      luckLevel: luckLevel ?? this.luckLevel,
      rebirthLevel: rebirthLevel ?? this.rebirthLevel,
      questProgress: questProgress ?? this.questProgress,
      secretSpaceEggClaimed:
          secretSpaceEggClaimed ?? this.secretSpaceEggClaimed,
      fullDeveloperToolsUnlocked:
          fullDeveloperToolsUnlocked ?? this.fullDeveloperToolsUnlocked,
      battleTokens: battleTokens ?? this.battleTokens,
      bossWins: bossWins ?? this.bossWins,
      hardPhaseWins: hardPhaseWins ?? this.hardPhaseWins,
      bossMutationUnlocked:
          bossMutationUnlocked ?? this.bossMutationUnlocked,
      activeAutoBattle: clearActiveAutoBattle
          ? null
          : activeAutoBattle ?? this.activeAutoBattle,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'ownedAnimals': ownedAnimals.map((a) => a.toJson()).toList(),
        'lastSavedTime': lastSavedTime.toIso8601String(),
        'lifetimeCoinsEarned': lifetimeCoinsEarned,
        'luckLevel': luckLevel,
        'rebirthLevel': rebirthLevel,
        'questProgress': questProgress.toJson(),
        'secretSpaceEggClaimed': secretSpaceEggClaimed,
        'fullDeveloperToolsUnlocked': fullDeveloperToolsUnlocked,
        'battleTokens': battleTokens,
        'bossWins': bossWins,
        'hardPhaseWins': hardPhaseWins,
        'bossMutationUnlocked': bossMutationUnlocked,
        if (activeAutoBattle != null)
          'activeAutoBattle': activeAutoBattle!.toJson(),
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    final coins = json['coins'] as int;
    return PlayerState(
      coins: coins,
      ownedAnimals: (json['ownedAnimals'] as List<dynamic>)
          .map((item) => OwnedAnimal.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastSavedTime: DateTime.parse(json['lastSavedTime'] as String),
      // Older saves may not have lifetime coins — use current coins as estimate.
      lifetimeCoinsEarned: json['lifetimeCoinsEarned'] as int? ?? coins,
      luckLevel: json['luckLevel'] as int? ?? 1,
      rebirthLevel: json['rebirthLevel'] as int? ?? 0,
      questProgress: QuestProgress.fromJson(
        json['questProgress'] as Map<String, dynamic>?,
      ),
      secretSpaceEggClaimed: json['secretSpaceEggClaimed'] as bool? ?? false,
      fullDeveloperToolsUnlocked:
          json['fullDeveloperToolsUnlocked'] as bool? ?? false,
      battleTokens: json['battleTokens'] as int? ?? 0,
      bossWins: _bossWinsFromJson(json['bossWins']),
      hardPhaseWins: _bossWinsFromJson(json['hardPhaseWins']),
      bossMutationUnlocked: json['bossMutationUnlocked'] as bool? ?? false,
      activeAutoBattle: json['activeAutoBattle'] is Map<String, dynamic>
          ? ActiveAutoBattle.fromJson(
              json['activeAutoBattle'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  static Map<String, int> _bossWinsFromJson(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        entry.key.toString(): (entry.value as num).toInt(),
    };
  }
}
