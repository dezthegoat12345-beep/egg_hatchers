/// Tracks how many of a specific animal/mutation combo the player owns.
class OwnedAnimal {
  const OwnedAnimal({
    required this.animalId,
    required this.quantity,
    this.level = 1,
    this.mutationId = 'none',
    this.isProtected = false,
  });

  final String animalId;
  final int quantity;
  final int level;
  final String mutationId;
  final bool isProtected;

  OwnedAnimal copyWith({
    int? quantity,
    int? level,
    String? mutationId,
    bool? isProtected,
  }) {
    return OwnedAnimal(
      animalId: animalId,
      quantity: quantity ?? this.quantity,
      level: level ?? this.level,
      mutationId: mutationId ?? this.mutationId,
      isProtected: isProtected ?? this.isProtected,
    );
  }

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        'quantity': quantity,
        'level': level,
        'mutationId': mutationId,
        'isProtected': isProtected,
      };

  factory OwnedAnimal.fromJson(Map<String, dynamic> json) {
    return OwnedAnimal(
      animalId: json['animalId'] as String,
      quantity: json['quantity'] as int,
      // Older saves may not have level or mutationId.
      level: json['level'] as int? ?? 1,
      mutationId: json['mutationId'] as String? ?? 'none',
      isProtected: json['isProtected'] as bool? ?? false,
    );
  }
}
