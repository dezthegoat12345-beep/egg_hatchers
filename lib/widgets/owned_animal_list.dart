import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/owned_animal.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import 'animal_card.dart';

/// Lists owned animals in separate Normal and Mutated sections.
class OwnedAnimalList extends StatelessWidget {
  const OwnedAnimalList({
    super.key,
    required this.game,
    required this.onUpgrade,
    this.compact = false,
    this.separatorHeight = 8,
    this.isDark = false,
  });

  final GameService game;
  final void Function(
    String animalId,
    String mutationId,
    String displayName,
  ) onUpgrade;
  final bool compact;
  final double separatorHeight;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final normal = _sorted(game.normalAnimals);
    final mutated = _sorted(game.mutatedAnimals);

    if (normal.isEmpty && mutated.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView(
      children: [
        if (normal.isNotEmpty) ...[
          _SectionHeader(
            title: '🐾 Normal Animals',
            compact: compact,
            isDark: isDark,
          ),
          SizedBox(height: separatorHeight),
          ..._buildCards(normal),
        ],
        if (mutated.isNotEmpty) ...[
          SizedBox(height: separatorHeight * 2),
          _SectionHeader(
            title: '✨ Mutated Animals',
            compact: compact,
            isDark: isDark,
          ),
          SizedBox(height: separatorHeight),
          ..._buildCards(mutated),
        ],
      ],
    );
  }

  List<OwnedAnimal> _sorted(List<OwnedAnimal> entries) {
    final copy = List<OwnedAnimal>.from(entries);
    copy.sort(
      (a, b) => GameData.compareOwnedAnimals(a.animalId, b.animalId),
    );
    return copy;
  }

  List<Widget> _buildCards(List<OwnedAnimal> entries) {
    return [
      for (var i = 0; i < entries.length; i++) ...[
        if (i > 0) SizedBox(height: separatorHeight),
        _buildCard(entries[i]),
      ],
    ];
  }

  Widget _buildCard(OwnedAnimal owned) {
    final animal = GameData.animalById(owned.animalId);
    if (animal == null) return const SizedBox.shrink();

    final mutation = GameData.mutationById(owned.mutationId) ??
        GameData.mutations.first;
    final displayName = mutation.fullName(animal);

    return AnimalCard(
      animal: animal,
      mutation: mutation,
      quantity: owned.quantity,
      level: owned.level,
      typeIncome: GameService.incomeFor(animal, owned),
      upgradeCost: GameService.upgradeCostFor(animal, owned),
      showUpgradeButton: true,
      canAffordUpgrade:
          game.canAffordUpgrade(animal.id, owned.mutationId),
      onUpgrade: () => onUpgrade(animal.id, owned.mutationId, displayName),
      compact: compact,
      isDark: isDark,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.compact,
    required this.isDark,
  });

  final String title;
  final bool compact;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GameTheme.sectionTitle(
        size: compact ? 16 : 18,
        isDark: isDark,
      ),
    );
  }
}
