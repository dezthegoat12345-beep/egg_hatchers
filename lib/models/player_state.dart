import 'owned_animal.dart';

/// All progress the player has made in the game.
class PlayerState {
  const PlayerState({
    required this.coins,
    required this.ownedAnimals,
    required this.lastSavedTime,
  });

  final int coins;
  final List<OwnedAnimal> ownedAnimals;
  final DateTime lastSavedTime;

  static PlayerState initial() {
    return PlayerState(
      coins: 250,
      ownedAnimals: const [],
      lastSavedTime: DateTime.now(),
    );
  }

  PlayerState copyWith({
    int? coins,
    List<OwnedAnimal>? ownedAnimals,
    DateTime? lastSavedTime,
  }) {
    return PlayerState(
      coins: coins ?? this.coins,
      ownedAnimals: ownedAnimals ?? this.ownedAnimals,
      lastSavedTime: lastSavedTime ?? this.lastSavedTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'ownedAnimals': ownedAnimals.map((a) => a.toJson()).toList(),
        'lastSavedTime': lastSavedTime.toIso8601String(),
      };

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      coins: json['coins'] as int,
      ownedAnimals: (json['ownedAnimals'] as List<dynamic>)
          .map((item) => OwnedAnimal.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastSavedTime: DateTime.parse(json['lastSavedTime'] as String),
    );
  }
}
