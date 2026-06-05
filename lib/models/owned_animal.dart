/// Tracks how many of a specific animal the player owns and its upgrade level.
class OwnedAnimal {
  const OwnedAnimal({
    required this.animalId,
    required this.quantity,
    this.level = 1,
  });

  final String animalId;
  final int quantity;
  final int level;

  OwnedAnimal copyWith({int? quantity, int? level}) {
    return OwnedAnimal(
      animalId: animalId,
      quantity: quantity ?? this.quantity,
      level: level ?? this.level,
    );
  }

  Map<String, dynamic> toJson() => {
        'animalId': animalId,
        'quantity': quantity,
        'level': level,
      };

  factory OwnedAnimal.fromJson(Map<String, dynamic> json) {
    return OwnedAnimal(
      animalId: json['animalId'] as String,
      quantity: json['quantity'] as int,
      // Older saves may not have a level — default to 1.
      level: json['level'] as int? ?? 1,
    );
  }
}
