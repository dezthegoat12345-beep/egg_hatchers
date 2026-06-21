import 'package:flutter/material.dart';

import '../models/boss_battle.dart';
import '../utils/boss_battle_logic.dart';

/// Pulsing red aura shown when a multi-life boss reaches its final life.
class BossLastLifeGlow extends StatefulWidget {
  const BossLastLifeGlow({
    super.key,
    required this.boss,
    required this.bossLivesRemaining,
    required this.bossMaxLives,
    required this.size,
    required this.child,
  });

  final BossBattleDefinition boss;
  final int bossLivesRemaining;
  final int bossMaxLives;
  final double size;
  final Widget child;

  @override
  State<BossLastLifeGlow> createState() => _BossLastLifeGlowState();
}

class _BossLastLifeGlowState extends State<BossLastLifeGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (_active) _pulse.repeat(reverse: true);
  }

  bool get _active => BossBattleLogic.showManualLastLifeGlow(
        widget.boss,
        livesRemaining: widget.bossLivesRemaining,
        maxLives: widget.bossMaxLives,
      );

  @override
  void didUpdateWidget(covariant BossLastLifeGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasActive = BossBattleLogic.showManualLastLifeGlow(
      oldWidget.boss,
      livesRemaining: oldWidget.bossLivesRemaining,
      maxLives: oldWidget.bossMaxLives,
    );
    if (_active && !wasActive) {
      _pulse.forward(from: 0);
      _pulse.repeat(reverse: true);
    } else if (!_active && wasActive) {
      _pulse.stop();
      _pulse.value = 0;
    } else if (_active && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_active) return widget.child;

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final pulse = 0.35 + _pulse.value * 0.4;
        final spread = 2 + _pulse.value * 5;
        final blur = 12 + _pulse.value * 10;
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size * 1.38,
              height: widget.size * 1.38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF1744).withValues(alpha: pulse * 0.55),
                    blurRadius: blur,
                    spreadRadius: spread,
                  ),
                  BoxShadow(
                    color: const Color(0xFFB71C1C).withValues(alpha: pulse * 0.35),
                    blurRadius: blur * 1.4,
                    spreadRadius: spread * 0.5,
                  ),
                ],
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}
