import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/mutation.dart';
import '../services/custom_sprite_service.dart';
import '../theme/game_theme.dart';
import 'game_sprite.dart';
import 'battling_dots_text.dart';

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
    this.showSellButtons = false,
    this.sellValue,
    this.onSellOne,
    this.onSellAll,
    this.isProtected = false,
    this.isAutoBattling = false,
    this.autoBattleBossName,
    this.autoBattleCurrentHp,
    this.autoBattleMaxHp,
    this.autoBattleWins,
    this.autoBattleTimeRemaining,
    this.onBattlingTap,
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
  final bool showSellButtons;
  final int? sellValue;
  final VoidCallback? onSellOne;
  final VoidCallback? onSellAll;
  final bool isProtected;
  final bool isAutoBattling;
  final String? autoBattleBossName;
  final int? autoBattleCurrentHp;
  final int? autoBattleMaxHp;
  final int? autoBattleWins;
  final Duration? autoBattleTimeRemaining;
  final VoidCallback? onBattlingTap;

  String _formatCountdown(Duration duration) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return 'Resolving...';
    if (totalSeconds >= 60) {
      return '${totalSeconds ~/ 60}m ${totalSeconds % 60}s';
    }
    return '${totalSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isOwned = quantity != null;
    final activeMutation = mutation ?? GameData.mutations.first;
    final displayName = useBaseNameForTitle
        ? animal.name
        : activeMutation.fullName(animal);
    final rarityColor = GameTheme.rarityAccent(animal.rarity);
    final rarityBorder = GameTheme.rarityBorderColor(animal.rarity, theme);
    final mutationColor = GameTheme.mutationAccent(activeMutation.id);
    final borderColor = activeMutation.isNormal ? rarityBorder : mutationColor;
    final textPrimary = activeMutation.isNormal
        ? theme.cardTextPrimaryColor
        : const Color(0xFF5D4037);
    final textSecondary = activeMutation.isNormal
        ? theme.cardTextSecondaryColor
        : const Color(0xFF795548);
    final showUpgrade = showUpgradeButton && !isAutoBattling;
    final showSell = showSellButtons && !isAutoBattling;

    final card = Container(
      decoration: GameTheme.cardDecoration(
        theme,
        borderColor: borderColor,
        backgroundColor: activeMutation.isNormal
            ? null
            : GameTheme.mutationTint(activeMutation.id),
        extraShadows: activeMutation.isNormal
            ? GameTheme.rarityCardShadows(animal.rarity, theme)
            : null,
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
                      color: borderColor.withValues(
                        alpha: animal.rarity == Rarity.unknown ? 0.95 : 0.45,
                      ),
                      width: animal.rarity == Rarity.unknown ? 2.5 : 2,
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
                          _RarityBadge(rarity: animal.rarity, theme: theme),
                          if (!activeMutation.isNormal)
                            _MutationBadge(mutation: activeMutation),
                          if (isProtected)
                            const _ProtectedBadge(),
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
            if (showUpgrade && upgradeCost != null) ...[
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
            if (showSell && !isProtected && sellValue != null && isOwned) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.secondaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.cardBorderColor.withValues(alpha: 0.35),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final stackActions = constraints.maxWidth < 340;
                    final sellAllVisible =
                        (quantity ?? 0) > 1 && onSellAll != null;

                    final sellLabel = Text(
                      'Sell: 🪙 $sellValue',
                      style: TextStyle(
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    );

                    final sellOneButton = FilledButton(
                      onPressed: onSellOne,
                      style: GameTheme.filledButton(
                        theme,
                        color: theme.secondaryColor,
                        height: compact ? 40 : 44,
                      ).copyWith(
                        padding: WidgetStatePropertyAll(
                          EdgeInsets.symmetric(
                            horizontal: compact ? 12 : 16,
                            vertical: compact ? 8 : 10,
                          ),
                        ),
                        minimumSize: WidgetStatePropertyAll(
                          Size(0, compact ? 40 : 44),
                        ),
                      ),
                      child: const Text('Sell 1'),
                    );

                    final sellAllButton = sellAllVisible
                        ? OutlinedButton(
                            onPressed: onSellAll,
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(0, compact ? 40 : 44),
                              side: BorderSide(color: theme.secondaryColor),
                              foregroundColor: theme.secondaryColor,
                            ),
                            child: const Text('Sell All'),
                          )
                        : null;

                    if (stackActions) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          sellLabel,
                          const SizedBox(height: 10),
                          sellOneButton,
                          if (sellAllButton != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: sellAllButton,
                            ),
                          ],
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: sellLabel),
                        const SizedBox(width: 8),
                        sellOneButton,
                        if (sellAllButton != null) ...[
                          const SizedBox(width: 8),
                          sellAllButton,
                        ],
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

    if (!isAutoBattling) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: 0.45,
          child: IgnorePointer(child: card),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBattlingTap,
              borderRadius: BorderRadius.circular(GameTheme.cardRadius),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(GameTheme.cardRadius),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BattlingDotsText(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                    if (autoBattleBossName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'vs $autoBattleBossName',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (autoBattleCurrentHp != null &&
                        autoBattleMaxHp != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'HP ${autoBattleCurrentHp!} / ${autoBattleMaxHp!}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (autoBattleWins != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Wins: $autoBattleWins',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (autoBattleTimeRemaining != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Next fight: ${_formatCountdown(autoBattleTimeRemaining!)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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
  const _RarityBadge({
    required this.rarity,
    required this.theme,
  });

  final Rarity rarity;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    final isUnknown = rarity == Rarity.unknown;
    final color = GameTheme.rarityAccent(rarity);
    final borderColor = GameTheme.rarityBorderColor(rarity, theme);
    final textColor = GameTheme.rarityBadgeTextColor(rarity, theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: isUnknown
            ? null
            : LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.08),
                ],
              ),
        color: isUnknown ? GameTheme.rarityBadgeFill(rarity) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isUnknown ? 2 : 1.5,
        ),
        boxShadow: isUnknown
            ? GameTheme.rarityCardShadows(rarity, theme)
            : null,
      ),
      child: Text(
        rarity.label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: isUnknown ? 0.5 : 0,
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

class _ProtectedBadge extends StatelessWidget {
  const _ProtectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF7E57C2).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7E57C2), width: 1.5),
      ),
      child: const Text(
        'Secret Reward',
        style: TextStyle(
          color: Color(0xFF7E57C2),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
