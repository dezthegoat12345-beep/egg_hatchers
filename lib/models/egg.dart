/// Currency used to purchase an egg.
enum EggCostCurrency {
  coins,
  battleTokens,
}

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
    this.unlockRebirthLevel = 0,
    this.animalWeights = const {},
    this.spritePath,
    this.costCurrency = EggCostCurrency.coins,
  });

  final String id;
  final String name;
  final int cost;
  final List<String> possibleAnimalIds;
  final String emoji;
  final String description;

  /// Optional sprite asset path. Emoji is used when null or if load fails.
  final String? spritePath;

  /// Lifetime coins needed to unlock. 0 means no lifetime requirement.
  final int unlockLifetimeCoins;

  /// Minimum rebirth level required. 0 means no rebirth requirement.
  final int unlockRebirthLevel;

  /// Relative hatch weights per animal id. Empty means equal chance.
  final Map<String, int> animalWeights;

  /// Coins or Battle Tokens required to buy this egg.
  final EggCostCurrency costCurrency;

  bool get usesBattleTokens => costCurrency == EggCostCurrency.battleTokens;

  bool isUnlocked({
    required int lifetimeCoinsEarned,
    required int rebirthLevel,
  }) {
    if (unlockRebirthLevel > 0 && rebirthLevel < unlockRebirthLevel) {
      return false;
    }
    if (unlockLifetimeCoins > 0 &&
        lifetimeCoinsEarned < unlockLifetimeCoins) {
      return false;
    }
    return true;
  }

  String get unlockMessage {
    if (unlockRebirthLevel > 0) {
      return 'Requires Rebirth Level $unlockRebirthLevel';
    }
    if (unlockLifetimeCoins <= 0) return '';
    return 'Unlocks after earning $unlockLifetimeCoins total coins.';
  }

  /// Snackbar copy when the player taps a rebirth-locked egg.
  String get rebirthUnlockSnackbarMessage {
    return 'Reach Rebirth Level $unlockRebirthLevel to unlock this egg.';
  }
}
