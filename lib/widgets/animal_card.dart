import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/mutation.dart';
import '../services/custom_sprite_service.dart';
import '../theme/game_theme.dart';
import 'game_sprite.dart';

/// A rounded card showing one animal, mutation, stats, and an upgrade button.
class AnimalCard extends StatelessWidget {
  const AnimalCard({
    super.key,
    required this.animal,
    required this.theme,
    this.mutation,
    this.quantity,
    this.level,
    this.typeIncome,
    this.upgradeCost,
    this.showUpgradeButton = false,
    this.canAffordUpgrade = false,
    this.onUpgrade,
    this.compact = false,
    this.customSprites,
    this.useBaseNameForTitle = false,
  });

  final Animal animal;
  final BackgroundTheme theme;
  final CustomSpriteService? customSprites;
  final Mutation? mutation;
  final int? quantity;
  final int? level;
  final int? typeIncome;
  final int? upgradeCost;
  final bool showUpgradeButton;
  final bool canAffordUpgrade;
  final VoidCallback? onUpgrade;
  final bool compact;
  final bool useBaseNameForTitle;

  @override
  Widget build(BuildContext context) {
    final isOwned = quantity != null;
    final activeMutation = mutation ?? GameData.mutations.first;
    final displayName = useBaseNameForTitle
        ? animal.name
        : activeMutation.fullName(animal);
    final rarityColor = GameTheme.rarityAccent(animal.rarity);
    final mutationColor = GameTheme.mutationAccent(activeMutation.id);
    final borderColor = activeMutation.isNormal ? rarityColor : mutationColor;
    final textPrimary = activeMutation.isNormal
        ? theme.cardTextPrimaryColor
        : const Color(0xFF5D4037);
    final textSecondary = activeMutation.isNormal
        ? theme.cardTextSecondaryColor
        : const Color(0xFF795548);

    return Container(
      decoration: GameTheme.cardDecoration(
        theme,
        borderColor: borderColor,
        backgroundColor: activeMutation.isNormal
            ? null
            : GameTheme.mutationTint(activeMutation.id),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 14 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 64 : 76,
                  height: compact ? 64 : 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: rarityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: borderColor.withValues(alpha: 0.45),
                      width: 2,
                    ),
                  ),
                  child: GameSprite(
                    customSprite: customSprites?.getDisplaySprite(animal.id),
                    spritePath: animal.spritePath,
                    fallbackEmoji: animal.emoji,
                    size: compact ? 48 : 58,
                    semanticLabel: displayName,
                    emojiFontSize: compact ? 34 : 42,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: compact ? 17 : 21,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _RarityBadge(rarity: animal.rarity),
                          if (!activeMutation.isNormal)
                            _MutationBadge(mutation: activeMutation),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isOwned) ...[
                        _InfoRow(
                          icon: '📦',
                          label: 'Owned: $quantity  •  Level $level',
                          compact: compact,
                          color: activeMutation.isNormal
                              ? theme.primaryColor
                              : const Color(0xFF4DB6AC),
                        ),
                        const SizedBox(height: 4),
                        _InfoRow(
                          icon: '💰',
                          label: 'Income: $typeIncome / sec',
                          compact: compact,
                          highlight: true,
                          color: activeMutation.isNormal
                              ? theme.secondaryColor
                              : const Color(0xFFE65100),
                        ),
                      ] else
                        _InfoRow(
                          icon: '💰',
                          label: 'Base: ${animal.coinsPerSecond} / sec',
                          compact: compact,
                          color: textSecondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (showUpgradeButton && upgradeCost != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.cardBorderColor.withValues(alpha: 0.35),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackUpgrade = constraints.maxWidth < 340;

                    if (stackUpgrade) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Upgrade: 🪙 $upgradeCost',
                            style: TextStyle(
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: onUpgrade,
                              style: GameTheme.filledButton(
                                theme,
                                color: canAffordUpgrade
                                    ? theme.primaryColor
                                    : theme.disabledColor,
                                height: compact ? 44 : 48,
                              ),
                              child: const Text('Upgrade ⬆️'),
                            ),
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Upgrade: 🪙 $upgradeCost',
                            style: TextStyle(
                              fontSize: compact ? 14 : 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: onUpgrade,
                          style: GameTheme.filledButton(
                            theme,
                            color: canAffordUpgrade
                                ? theme.primaryColor
                                : theme.disabledColor,
                            height: compact ? 44 : 48,
                          ).copyWith(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                horizontal: compact ? 14 : 18,
                                vertical: compact ? 10 : 12,
                              ),
                            ),
                            minimumSize: WidgetStatePropertyAll(
                              Size(0, compact ? 44 : 48),
                            ),
                            textStyle: WidgetStatePropertyAll(
                              TextStyle(
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          child: const Text('Upgrade ⬆️'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.compact,
    required this.color,
    this.highlight = false,
  });

  final String icon;
  final String label;
  final bool compact;
  final Color color;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: TextStyle(fontSize: compact ? 13 : 15)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _RarityBadge extends StatelessWidget {
  const _RarityBadge({required this.rarity});

  final Rarity rarity;

  @override
  Widget build(BuildContext context) {
    final color = GameTheme.rarityAccent(rarity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MutationBadge extends StatelessWidget {
  const _MutationBadge({required this.mutation});

  final Mutation mutation;

  @override
  Widget build(BuildContext context) {
    final color = GameTheme.mutationAccent(mutation.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        '${mutation.icon} ${mutation.displayName}'.trim(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
