/// An egg the player can buy and hatch for a random animal.
class Egg {
  const Egg({
    required this.id,
    required this.name,
    required this.cost,
    required this.possibleAnimalIds,
    required this.emoji,
    this.description = '',
  });

  final String id;
  final String name;
  final int cost;
  final List<String> possibleAnimalIds;
  final String emoji;
  final String description;
}
