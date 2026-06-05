import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade300,
            Colors.orange.shade200,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCoinTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Text('🪙', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$coins coins',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                Text(
                  '+$coinsPerSecond / sec',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.brown.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (lifetimeCoinsEarned != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Lifetime Coins Earned: ${formatCoins(lifetimeCoinsEarned!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.brown.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
