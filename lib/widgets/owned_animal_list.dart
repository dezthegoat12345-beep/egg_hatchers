import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/background_theme.dart';
import '../models/owned_animal.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import 'animal_card.dart';

/// Lists owned animals in separate Normal and Mutated sections.
class OwnedAnimalList extends StatelessWidget {
  const OwnedAnimalList({
    super.key,
    required this.game,
    required this.onUpgrade,
    required this.theme,
    this.compact = false,
    this.separatorHeight = 8,
    this.embedInParentScroll = false,
    this.customSprites,
    this.showSellButtons = false,
    this.onSellOne,
    this.onSellAll,
  });

  final GameService game;
  final BackgroundTheme theme;
  final CustomSpriteService? customSprites;
  final void Function(
    String animalId,
    String mutationId,
    String displayName,
    bool isProtected,
  ) onUpgrade;
  final void Function(
    String animalId,
    String mutationId,
    String displayName,
    int coins,
    bool isProtected,
  )? onSellOne;
  final void Function(
    String animalId,
    String mutationId,
    String displayName,
    int quantity,
    int totalCoins,
    bool isProtected,
  )? onSellAll;
  final bool showSellButtons;
  final bool compact;
  final double separatorHeight;
  final bool embedInParentScroll;

  @override
  Widget build(BuildContext context) {
    final normal = _sorted(game.normalAnimals);
    final mutated = _sorted(game.mutatedAnimals);

    if (normal.isEmpty && mutated.isEmpty) {
      return const SizedBox.shrink();
    }

    final children = <Widget>[
      if (normal.isNotEmpty) ...[
        _SectionHeader(
          title: '🐾 Normal Animals',
          compact: compact,
          theme: theme,
        ),
        SizedBox(height: separatorHeight),
        ..._buildCards(normal),
      ],
      if (mutated.isNotEmpty) ...[
        SizedBox(height: separatorHeight * 2),
        _SectionHeader(
          title: '✨ Mutated Animals',
          compact: compact,
          theme: theme,
        ),
        SizedBox(height: separatorHeight),
        ..._buildCards(mutated),
      ],
    ];

    if (embedInParentScroll) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    return ListView(
      children: children,
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
    final canSell = showSellButtons && !owned.isProtected;

    return AnimalCard(
      animal: animal,
      theme: theme,
      mutation: mutation,
      quantity: owned.quantity,
      level: owned.level,
      typeIncome: GameService.incomeFor(animal, owned),
      upgradeCost: GameService.upgradeCostFor(animal, owned),
      showUpgradeButton: true,
      canAffordUpgrade: game.canAffordUpgrade(
        animal.id,
        owned.mutationId,
        isProtected: owned.isProtected,
      ),
      onUpgrade: () => onUpgrade(
        animal.id,
        owned.mutationId,
        displayName,
        owned.isProtected,
      ),
      showSellButtons: canSell,
      isProtected: owned.isProtected,
      sellValue: canSell ? GameService.sellValueFor(animal, owned) : null,
      onSellOne: canSell && onSellOne != null
          ? () {
              final coins = GameService.sellValueFor(animal, owned);
              onSellOne!(
                animal.id,
                owned.mutationId,
                displayName,
                coins,
                owned.isProtected,
              );
            }
          : null,
      onSellAll: canSell && owned.quantity > 1 && onSellAll != null
          ? () {
              final unit = GameService.sellValueFor(animal, owned);
              onSellAll!(
                animal.id,
                owned.mutationId,
                displayName,
                owned.quantity,
                unit * owned.quantity,
                owned.isProtected,
              );
            }
          : null,
      compact: compact,
      customSprites: customSprites,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.compact,
    required this.theme,
  });

  final String title;
  final bool compact;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GameTheme.sectionTitle(
        theme,
        size: compact ? 16 : 18,
      ),
    );
  }
}
