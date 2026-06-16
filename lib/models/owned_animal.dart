/// Tracks how many of a specific animal/mutation combo the player owns.
class OwnedAnimal {
  const OwnedAnimal({
    required this.animalId,
    required this.quantity,
    this.level = 1,
    this.mutationId = 'none',
    this.isProtected = false,
    this.isSecretReward = false,
  });

  final String animalId;
  final int quantity;
  final int level;
  final String mutationId;
  final bool isProtected;
  final bool isSecretReward;

  OwnedAnimal copyWith({
    int? quantity,
    int? level,
    String? mutationId,
    bool? isProtected,
    bool? isSecretReward,
  }) {
    return OwnedAnimal(
      animalId: animalId,
      quantity: quantity ?? this.quantity,
      level: level ?? this.level,
      mutationId: mutationId ?? this.mutationId,
      isProtected: isProtected ?? this.isProtected,
      isSecretReward: isSecretReward ?? this.isSecretReward,
    );
  }

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        'quantity': quantity,
        'level': level,
        'mutationId': mutationId,
        'isProtected': isProtected,
        'isSecretReward': isSecretReward,
      };

  factory OwnedAnimal.fromJson(Map<String, dynamic> json) {
    final isProtected = json['isProtected'] as bool? ?? false;
    return OwnedAnimal(
      animalId: json['animalId'] as String,
      quantity: json['quantity'] as int,
      // Older saves may not have level or mutationId.
      level: json['level'] as int? ?? 1,
      mutationId: json['mutationId'] as String? ?? 'none',
      isProtected: isProtected,
      // Legacy protected Secret Void Egg animals count as secret reward badge holders.
      isSecretReward:
          json['isSecretReward'] as bool? ?? (isProtected ? true : false),
    );
  }
}
