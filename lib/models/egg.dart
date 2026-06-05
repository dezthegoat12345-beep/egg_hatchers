/// An egg the player can buy and hatch for a random animal.
class Egg {
  const Egg({
    required this.id,
    required this.name,
    required this.cost,
    required this.possibleAnimalIds,
    required this.emoji,
    this.description = '',
    this.unlockLifetimeCoins = 0,
  });

  final String id;
  final String name;
  final int cost;
  final List<String> possibleAnimalIds;
  final String emoji;
  final String description;

  /// Lifetime coins needed to unlock. 0 means always unlocked.
  final int unlockLifetimeCoins;

  bool isUnlocked(int lifetimeCoinsEarned) =>
      unlockLifetimeCoins <= 0 || lifetimeCoinsEarned >= unlockLifetimeCoins;

  String get unlockMessage {
    if (unlockLifetimeCoins <= 0) return '';
    return 'Unlocks after earning $unlockLifetimeCoins total coins.';
  }
}
