import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import '../utils/format_utils.dart';
import '../utils/rebirth_logic.dart';
import '../utils/snackbar_utils.dart';

/// Hatchery panel for rebirth status and confirmation.
class RebirthPanel extends StatelessWidget {
  const RebirthPanel({
    super.key,
    required this.game,
    required this.theme,
  });

  final GameService game;
  final BackgroundTheme theme;

  Future<void> _onRebirthPressed(BuildContext context) async {
    if (!game.canRebirth) {
      showGameSnackBar(
        context,
        message: 'Earn 1,000,000 lifetime coins to rebirth.',
        backgroundColor: Colors.orange.shade700,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _RebirthConfirmDialog(
        game: game,
        theme: theme,
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = game.performRebirth();
      if (success && context.mounted) {
        showGameSnackBar(
          context,
          message: 'Rebirth complete! Permanent income boost increased.',
          backgroundColor: theme.primaryColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rebirthLevel = game.rebirthLevel;
    final currentMultiplier = game.incomeMultiplier;
    final nextMultiplier = RebirthLogic.nextIncomeMultiplier(rebirthLevel);
    final canRebirth = game.canRebirth;
    final lifetime = game.lifetimeCoinsEarned;
    final requirement = RebirthLogic.unlockLifetimeCoins;

    return Container(
      decoration: GameTheme.cardDecoration(
        theme,
        borderColor: canRebirth ? theme.panelAccentColor : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('🔁', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rebirth Level $rebirthLevel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.cardTextPrimaryColor,
                      ),
                    ),
                    Text(
                      canRebirth
                          ? 'Ready to rebirth for a permanent income boost'
                          : 'Reach 1M lifetime coins to unlock rebirth',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.cardTextSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: 'Income',
                value: RebirthLogic.formatMultiplier(currentMultiplier),
                theme: theme,
                color: theme.primaryColor,
              ),
              _InfoChip(
                label: 'Next Rebirth',
                value: RebirthLogic.formatMultiplier(nextMultiplier),
                theme: theme,
                color: theme.secondaryColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Lifetime Coins Earned: ${formatCoins(lifetime.clamp(0, requirement))} / ${formatCoins(requirement)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.cardTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => _onRebirthPressed(context),
            style: GameTheme.filledButton(
              theme,
              color: canRebirth ? theme.panelAccentColor : theme.disabledColor,
              height: 48,
            ),
            child: Text(
              canRebirth ? 'Rebirth · +25% Income' : 'Rebirth Locked',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RebirthConfirmDialog extends StatelessWidget {
  const _RebirthConfirmDialog({
    required this.game,
    required this.theme,
  });

  final GameService game;
  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    final currentLevel = game.rebirthLevel;
    final newLevel = currentLevel + 1;
    final currentMultiplier = game.incomeMultiplier;
    final newMultiplier = RebirthLogic.incomeMultiplier(newLevel);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Rebirth?',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rebirth resets your coins, animals, upgrades, Luck, and quest '
            'progress, but gives a permanent +25% income boost.',
            style: TextStyle(height: 1.4),
          ),
          const SizedBox(height: 16),
          _DialogRow(
            label: 'Rebirth Level',
            current: '$currentLevel',
            next: '$newLevel',
          ),
          const SizedBox(height: 8),
          _DialogRow(
            label: 'Income Multiplier',
            current: RebirthLogic.formatMultiplier(currentMultiplier),
            next: RebirthLogic.formatMultiplier(newMultiplier),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: GameTheme.filledButton(theme, height: 40),
          child: const Text('Rebirth'),
        ),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow({
    required this.label,
    required this.current,
    required this.next,
  });

  final String label;
  final String current;
  final String next;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Text(current, textAlign: TextAlign.center),
        ),
        const Text('→'),
        Expanded(
          child: Text(
            next,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.theme,
    required this.color,
  });

  final String label;
  final String value;
  final BackgroundTheme theme;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.cardTextSecondaryColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.cardTextPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
