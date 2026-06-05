/// Tracks how many of a specific animal/mutation combo the player owns.
class OwnedAnimal {
  const OwnedAnimal({
    required this.animalId,
    required this.quantity,
    this.level = 1,
    this.mutationId = 'none',
  });

  final String animalId;
  final int quantity;
  final int level;
  final String mutationId;

  OwnedAnimal copyWith({int? quantity, int? level, String? mutationId}) {
    return OwnedAnimal(
      animalId: animalId,
      quantity: quantity ?? this.quantity,
      level: level ?? this.level,
      mutationId: mutationId ?? this.mutationId,
    );
  }

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        'quantity': quantity,
        'level': level,
        'mutationId': mutationId,
      };

  factory OwnedAnimal.fromJson(Map<String, dynamic> json) {
    return OwnedAnimal(
      animalId: json['animalId'] as String,
      quantity: json['quantity'] as int,
      // Older saves may not have level or mutationId.
      level: json['level'] as int? ?? 1,
      mutationId: json['mutationId'] as String? ?? 'none',
    );
  }
}
