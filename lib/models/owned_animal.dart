import '../data/game_data.dart';

/// Tracks how many of a specific animal/mutation combo the player owns.
class OwnedAnimal {
  const OwnedAnimal({
    required this.animalId,
    required this.quantity,
    this.level = 1,
    this.mutationId = 'none',
    this.isProtected = false,
    this.isSecretReward = false,
    this.isEliteReward = false,
    this.sourceEggId,
  });

  final String animalId;
  final int quantity;
  final int level;
  final String mutationId;
  final bool isProtected;
  final bool isSecretReward;
  final bool isEliteReward;
  final String? sourceEggId;

  OwnedAnimal copyWith({
    int? quantity,
    int? level,
    String? mutationId,
    bool? isProtected,
    bool? isSecretReward,
    bool? isEliteReward,
    String? sourceEggId,
    bool clearSourceEggId = false,
  }) {
    return OwnedAnimal(
      animalId: animalId,
      quantity: quantity ?? this.quantity,
      level: level ?? this.level,
      mutationId: mutationId ?? this.mutationId,
      isProtected: isProtected ?? this.isProtected,
      isSecretReward: isSecretReward ?? this.isSecretReward,
      isEliteReward: isEliteReward ?? this.isEliteReward,
      sourceEggId: clearSourceEggId ? null : sourceEggId ?? this.sourceEggId,
    );
  }

  String get protectionBadgeLabel {
    if (isEliteReward) return 'Elite';
    if (isSecretReward) return 'Secret Reward';
    return '';
  }

  String get cannotSellMessage {
    if (isEliteReward) return 'Elite animals cannot be sold.';
    if (isSecretReward) return 'Secret reward animals cannot be sold.';
    return 'Protected animals cannot be sold.';
  }

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        'quantity': quantity,
        'level': level,
        'mutationId': mutationId,
        'isProtected': isProtected,
        'isSecretReward': isSecretReward,
        'isEliteReward': isEliteReward,
        if (sourceEggId != null) 'sourceEggId': sourceEggId,
      };

  factory OwnedAnimal.fromJson(Map<String, dynamic> json) {
    final animalId = json['animalId'] as String;
    final isProtected = json['isProtected'] as bool? ?? false;
    final isEliteAnimal =
        GameData.bossVictoryRewardAnimalIds.contains(animalId);
    var isEliteReward = json['isEliteReward'] as bool? ?? false;
    var isSecretReward = json['isSecretReward'] as bool? ?? false;

    if (isEliteAnimal) {
      isEliteReward = true;
      isSecretReward = false;
    } else if (json['isSecretReward'] == null && isProtected) {
      // Legacy protected Secret Void Egg / Secret Reward Badge animals.
      isSecretReward = true;
    }

    return OwnedAnimal(
      animalId: animalId,
      quantity: json['quantity'] as int,
      // Older saves may not have level or mutationId.
      level: json['level'] as int? ?? 1,
      mutationId: json['mutationId'] as String? ?? 'none',
      isProtected: isProtected || isEliteReward,
      isSecretReward: isSecretReward,
      isEliteReward: isEliteReward,
      sourceEggId: json['sourceEggId'] as String?,
    );
  }
}
