import 'package:flutter/material.dart';

import '../theme/game_theme.dart';
import '../utils/format_utils.dart';

/// Shows the player's coin balance and income rate at the top of a screen.
class CoinHeader extends StatelessWidget {
  const CoinHeader({
    super.key,
    required this.coins,
    required this.coinsPerSecond,
    this.lifetimeCoinsEarned,
    this.onCoinTap,
  });

  final int coins;
  final int coinsPerSecond;
  final int? lifetimeCoinsEarned;
  final VoidCallback? onCoinTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: GameTheme.panelDecoration(accent: const Color(0xFFFFB300)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onCoinTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GameTheme.softYellow.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.4),
                ),
              ),
              child: const Text('🪙', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatCoins(coins),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'coins',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      icon: '⚡',
                      label: '+$coinsPerSecond / sec',
                      color: const Color(0xFF4DB6AC),
                    ),
                    if (lifetimeCoinsEarned != null)
                      _StatChip(
                        icon: '🏆',
                        label: '${formatCoins(lifetimeCoinsEarned!)} lifetime',
                        color: const Color(0xFFFFB74D),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final String icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}
