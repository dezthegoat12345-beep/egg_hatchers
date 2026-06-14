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
  });

  final int coins;
  final List<OwnedAnimal> ownedAnimals;
  final DateTime lastSavedTime;
  final int lifetimeCoinsEarned;
  final int luckLevel;
  final int rebirthLevel;
  final QuestProgress questProgress;

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
  }) {
    return PlayerState(
      coins: coins ?? this.coins,
      ownedAnimals: ownedAnimals ?? this.ownedAnimals,
      lastSavedTime: lastSavedTime ?? this.lastSavedTime,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      luckLevel: luckLevel ?? this.luckLevel,
      rebirthLevel: rebirthLevel ?? this.rebirthLevel,
      questProgress: questProgress ?? this.questProgress,
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
    );
  }
}
