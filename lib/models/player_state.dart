import '../utils/battle_upgrade_logic.dart';
import 'active_auto_battle.dart';
import 'daily_quest_progress.dart';
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
    this.nightmareWins = const {},
    this.bossMutationUnlocked = false,
    this.activeAutoBattle,
    this.tutorialCompleted = false,
    this.tutorialSkipped = false,
    this.tutorialVersionCompleted = 0,
    this.battleHomingLevel = 0,
    this.battleShotSpeedLevel = 0,
    this.battleExtraLifeLevel = 0,
    this.lastDailyRewardClaimDate,
    this.dailyRewardStreak = 0,
    this.bestDailyRewardStreak = 0,
    this.dailyQuestDate,
    this.dailyQuests = const [],
    this.lastDailyRewardPopupDismissDate,
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
  final Map<String, int> nightmareWins;
  final bool bossMutationUnlocked;
  final ActiveAutoBattle? activeAutoBattle;
  final bool tutorialCompleted;
  final bool tutorialSkipped;
  final int tutorialVersionCompleted;
  final int battleHomingLevel;
  final int battleShotSpeedLevel;
  final int battleExtraLifeLevel;
  final String? lastDailyRewardClaimDate;
  final int dailyRewardStreak;
  final int bestDailyRewardStreak;
  final String? dailyQuestDate;
  final List<DailyQuestProgress> dailyQuests;
  final String? lastDailyRewardPopupDismissDate;

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
    Map<String, int>? nightmareWins,
    bool? bossMutationUnlocked,
    ActiveAutoBattle? activeAutoBattle,
    bool clearActiveAutoBattle = false,
    bool? tutorialCompleted,
    bool? tutorialSkipped,
    int? tutorialVersionCompleted,
    int? battleHomingLevel,
    int? battleShotSpeedLevel,
    int? battleExtraLifeLevel,
    String? lastDailyRewardClaimDate,
    bool clearLastDailyRewardClaimDate = false,
    int? dailyRewardStreak,
    int? bestDailyRewardStreak,
    String? dailyQuestDate,
    bool clearDailyQuestDate = false,
    List<DailyQuestProgress>? dailyQuests,
    String? lastDailyRewardPopupDismissDate,
    bool clearLastDailyRewardPopupDismissDate = false,
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
      nightmareWins: nightmareWins ?? this.nightmareWins,
      bossMutationUnlocked:
          bossMutationUnlocked ?? this.bossMutationUnlocked,
      activeAutoBattle: clearActiveAutoBattle
          ? null
          : activeAutoBattle ?? this.activeAutoBattle,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      tutorialSkipped: tutorialSkipped ?? this.tutorialSkipped,
      tutorialVersionCompleted:
          tutorialVersionCompleted ?? this.tutorialVersionCompleted,
      battleHomingLevel: battleHomingLevel ?? this.battleHomingLevel,
      battleShotSpeedLevel: battleShotSpeedLevel ?? this.battleShotSpeedLevel,
      battleExtraLifeLevel: battleExtraLifeLevel ?? this.battleExtraLifeLevel,
      lastDailyRewardClaimDate: clearLastDailyRewardClaimDate
          ? null
          : lastDailyRewardClaimDate ?? this.lastDailyRewardClaimDate,
      dailyRewardStreak: dailyRewardStreak ?? this.dailyRewardStreak,
      bestDailyRewardStreak:
          bestDailyRewardStreak ?? this.bestDailyRewardStreak,
      dailyQuestDate: clearDailyQuestDate
          ? null
          : dailyQuestDate ?? this.dailyQuestDate,
      dailyQuests: dailyQuests ?? this.dailyQuests,
      lastDailyRewardPopupDismissDate: clearLastDailyRewardPopupDismissDate
          ? null
          : lastDailyRewardPopupDismissDate ??
              this.lastDailyRewardPopupDismissDate,
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
        'nightmareWins': nightmareWins,
        'bossMutationUnlocked': bossMutationUnlocked,
        if (activeAutoBattle != null)
          'activeAutoBattle': activeAutoBattle!.toJson(),
        'tutorialCompleted': tutorialCompleted,
        'tutorialSkipped': tutorialSkipped,
        'tutorialVersionCompleted': tutorialVersionCompleted,
        'battleHomingLevel': battleHomingLevel,
        'battleShotSpeedLevel': battleShotSpeedLevel,
        'battleExtraLifeLevel': battleExtraLifeLevel,
        if (lastDailyRewardClaimDate != null)
          'lastDailyRewardClaimDate': lastDailyRewardClaimDate,
        'dailyRewardStreak': dailyRewardStreak,
        'bestDailyRewardStreak': bestDailyRewardStreak,
        if (dailyQuestDate != null) 'dailyQuestDate': dailyQuestDate,
        'dailyQuests': dailyQuests.map((quest) => quest.toJson()).toList(),
        if (lastDailyRewardPopupDismissDate != null)
          'lastDailyRewardPopupDismissDate': lastDailyRewardPopupDismissDate,
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
      nightmareWins: _bossWinsFromJson(json['nightmareWins']),
      bossMutationUnlocked: json['bossMutationUnlocked'] as bool? ?? false,
      activeAutoBattle: json['activeAutoBattle'] is Map<String, dynamic>
          ? ActiveAutoBattle.fromJson(
              json['activeAutoBattle'] as Map<String, dynamic>,
            )
          : null,
      tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
      tutorialSkipped: json['tutorialSkipped'] as bool? ?? false,
      tutorialVersionCompleted:
          json['tutorialVersionCompleted'] as int? ?? 0,
      battleHomingLevel: BattleUpgradeLogic.clampLevel(
        json['battleHomingLevel'] as int? ?? 0,
      ),
      battleShotSpeedLevel: BattleUpgradeLogic.clampLevel(
        json['battleShotSpeedLevel'] as int? ?? 0,
      ),
      battleExtraLifeLevel: BattleUpgradeLogic.clampExtraLifeLevel(
        json['battleExtraLifeLevel'] as int? ?? 0,
      ),
      lastDailyRewardClaimDate: json['lastDailyRewardClaimDate'] as String?,
      dailyRewardStreak: (json['dailyRewardStreak'] as num?)?.toInt() ?? 0,
      bestDailyRewardStreak:
          (json['bestDailyRewardStreak'] as num?)?.toInt() ?? 0,
      dailyQuestDate: json['dailyQuestDate'] as String?,
      dailyQuests: _dailyQuestsFromJson(json['dailyQuests']),
      lastDailyRewardPopupDismissDate:
          json['lastDailyRewardPopupDismissDate'] as String?,
    );
  }

  static List<DailyQuestProgress> _dailyQuestsFromJson(Object? raw) {
    if (raw is! List || raw.isEmpty) return const [];
    return raw
        .map(
          (item) => DailyQuestProgress.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Map<String, int> _bossWinsFromJson(Object? raw) {
    if (raw is! Map) return const {};
    return {
      for (final entry in raw.entries)
        entry.key.toString(): (entry.value as num).toInt(),
    };
  }
}
