import 'animal.dart';

/// A special variant that can appear when hatching an egg.
class Mutation {
  const Mutation({
    required this.id,
    required this.displayName,
    required this.chance,
    required this.incomeMultiplier,
    this.icon = '',
    this.prefix = '',
  });

  final String id;
  final String displayName;
  final int chance;
  final int incomeMultiplier;
  final String icon;
  final String prefix;

  bool get isNormal => id == 'none';

  /// Full display name, e.g. "Golden Chicken" or just "Chicken".
  String fullName(Animal animal) {
    if (isNormal) return animal.name;
    return '$prefix ${animal.name}';
  }

  /// Emoji line with optional mutation icon prefix.
  String displayEmoji(Animal animal) {
    if (icon.isEmpty) return animal.emoji;
    return '$icon ${animal.emoji}';
  }

  /// Exciting hatch reveal message.
  String hatchMessage(Animal animal) {
    final name = fullName(animal);
    switch (id) {
      case 'none':
        return 'You hatched a ${animal.name}!';
      case 'golden':
        return '✨ Mutation! You hatched a $name!';
      case 'rainbow':
        return '🌈 Rare mutation! You hatched a $name!';
      case 'shadow':
        return '🌑 Ultra rare mutation! You hatched a $name!';
      default:
        return 'You hatched a $name!';
    }
  }
}
