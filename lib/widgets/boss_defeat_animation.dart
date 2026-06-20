import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../utils/format_utils.dart';

/// Abstract boss-defeat celebration overlay for manual battle victories.
class BossDefeatAnimation extends StatefulWidget {
  const BossDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.mode,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.onComplete,
  });

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final ManualBattleMode mode;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final VoidCallback onComplete;

  static String victoryTitle({
    required ManualBattleMode mode,
    required bool isEliteBoss,
  }) {
    if (isEliteBoss) return 'ELITE BOSS DEFEATED!';
    return switch (mode) {
      ManualBattleMode.hard => 'HARD PHASE CLEAR!',
      ManualBattleMode.nightmare => 'NIGHTMARE CLEARED!',
      ManualBattleMode.normal => 'BOSS DEFEATED!',
    };
  }

  @override
  State<BossDefeatAnimation> createState() => _BossDefeatAnimationState();
}

class _BossDefeatAnimationState extends State<BossDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2200);
  static const _totalMs = 2200.0;

  late final AnimationController _controller;
  late final List<_BurstParticle> _particles;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _particles = _BurstParticle.generate(18);
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onStatusChanged)
      ..forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _finish();
    }
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    widget.onComplete();
  }

  void _trySkip() {
    if (_controller.value < 500 / _totalMs) return;
    _finish();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  double _interval(double start, double end) {
    final t = _controller.value;
    if (t <= start) return 0;
    if (t >= end) return 1;
    return (t - start) / (end - start);
  }

  double _phase(int startMs, int endMs) {
    return _interval(startMs / _totalMs, endMs / _totalMs);
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;
    final flash = (1 - (_phase(0, 250) * 2).clamp(0, 1)).abs();
    final shakeAmount = (1 - _phase(0, 350)) * 6;
    final shakeX = math.sin(t * math.pi * 14) * shakeAmount;
    final shakeY = math.cos(t * math.pi * 11) * shakeAmount * 0.6;

    final silhouetteScale = 1 + _phase(250, 500) * 0.08;
    final silhouetteOpacity =
        (1 - Curves.easeIn.transform(_phase(350, 800))).clamp(0.0, 1.0);
    final crackOpacity = Curves.easeOut.transform(_phase(400, 700));

    final titleProgress = Curves.elasticOut.transform(_phase(800, 1150));
    final titleOpacity = Curves.easeOut.transform(_phase(800, 950));

    final rewardsOpacity = Curves.easeOut.transform(_phase(1300, 1550));
    final rewardsSlide = (1 - rewardsOpacity) * 28;

    final victoryTitle = BossDefeatAnimation.victoryTitle(
      mode: widget.mode,
      isEliteBoss: widget.boss.isEliteBoss,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Material(
          color: Colors.black.withValues(alpha: 0.72),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _trySkip,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: Colors.white.withValues(alpha: flash * 0.55),
                ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: child,
                ),
              ],
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _BurstParticlePainter(
              particles: _particles,
              progress: Curves.easeOut.transform(_phase(180, 900)),
              fade: (1 - _phase(650, 950)).clamp(0.0, 1.0),
            ),
          ),
          Opacity(
            opacity: silhouetteOpacity,
            child: Transform.scale(
              scale: silhouetteScale,
              child: _BossSilhouette(
                bossEmoji: widget.boss.emoji,
                crackOpacity: crackOpacity,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 120),
              Opacity(
                opacity: titleOpacity,
                child: Transform.scale(
                  scale: 0.75 + titleProgress * 0.25,
                  child: Text(
                    victoryTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Color(0xFFFFEB3B),
                      shadows: [
                        Shadow(
                          color: Colors.black87,
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: titleOpacity * 0.9,
                child: Text(
                  widget.boss.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.theme.cardTextPrimaryColor.withValues(
                      alpha: 0.95,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Opacity(
                opacity: rewardsOpacity,
                child: Transform.translate(
                  offset: Offset(0, rewardsSlide),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (widget.coinReward > 0)
                        _RewardChip(
                          label: '🪙 +${formatCoins(widget.coinReward)}',
                          color: Colors.amber.shade700,
                        ),
                      if (widget.tokenReward > 0)
                        _RewardChip(
                          label: '⚔️ +${widget.tokenReward}',
                          color: const Color(0xFF1565C0),
                        ),
                      if (widget.animalRewardName != null)
                        _RewardChip(
                          label: 'Elite: ${widget.animalRewardName!}',
                          color: Colors.deepPurple.shade400,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BossSilhouette extends StatelessWidget {
  const _BossSilhouette({
    required this.bossEmoji,
    required this.crackOpacity,
  });

  final String bossEmoji;
  final double crackOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.88),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade900.withValues(alpha: 0.45),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                bossEmoji,
                style: TextStyle(
                  fontSize: 44,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: crackOpacity,
            child: CustomPaint(
              size: const Size(108, 108),
              painter: _CrackPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(center.dx - 8, center.dy - 20)
      ..lineTo(center.dx + 4, center.dy - 2)
      ..lineTo(center.dx - 6, center.dy + 8)
      ..lineTo(center.dx + 10, center.dy + 22);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.75)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _BurstParticle {
  _BurstParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;

  static List<_BurstParticle> generate(int count) {
    final random = math.Random(7);
    const colors = [
      Color(0xFFFFEB3B),
      Color(0xFF64B5F6),
      Color(0xFFFFD54F),
      Color(0xFF90CAF9),
      Colors.white,
    ];
    return List.generate(count, (index) {
      return _BurstParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 40 + random.nextDouble() * 90,
        size: 4 + random.nextDouble() * 8,
        color: colors[index % colors.length],
      );
    });
  }
}

class _BurstParticlePainter extends CustomPainter {
  _BurstParticlePainter({
    required this.particles,
    required this.progress,
    required this.fade,
  });

  final List<_BurstParticle> particles;
  final double progress;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2 - 20);

    for (final particle in particles) {
      final dist = particle.distance * progress;
      final offset = Offset(
        center.dx + math.cos(particle.angle) * dist,
        center.dy + math.sin(particle.angle) * dist,
      );
      final paint = Paint()
        ..color = particle.color.withValues(alpha: (1 - progress) * fade)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, particle.size * (1 - progress * 0.35), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.fade != fade;
  }
}
