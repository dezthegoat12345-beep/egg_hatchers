import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../utils/boss_defeat_animation_config.dart';
import '../utils/format_utils.dart';

/// Boss-specific defeat celebration overlay for manual battle victories.
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
  late final BossDefeatAnimationType _animationType;
  late final Duration _duration;
  late final double _totalMs;
  late final AnimationController _controller;
  late final List<_AnimParticle> _particles;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _animationType = BossDefeatAnimationConfig.typeForBossId(widget.boss.id);
    _duration = BossDefeatAnimationConfig.durationFor(_animationType);
    _totalMs = _duration.inMilliseconds.toDouble();
    _particles = _AnimParticle.generate(_animationType);
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onStatusChanged)
      ..forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) _finish();
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

  double _phase(int startMs, int endMs) =>
      _interval(startMs / _totalMs, endMs / _totalMs);

  Color _flashColor(double flash) {
    final base = switch (_animationType) {
      BossDefeatAnimationType.slimeBurst ||
      BossDefeatAnimationType.royalSlimeBurst =>
        const Color(0xFF66BB6A),
      BossDefeatAnimationType.golemCollapse => const Color(0xFFD7CCC8),
      BossDefeatAnimationType.shadowFeathers => const Color(0xFF7E57C2),
      BossDefeatAnimationType.guardianShatter => const Color(0xFF42A5F5),
      BossDefeatAnimationType.shadowPhoenixFlame => const Color(0xFF1565C0),
      BossDefeatAnimationType.generic => Colors.white,
    };
    return base.withValues(alpha: flash * 0.55);
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;
    final flash = (1 - (_phase(0, 250) * 2).clamp(0.0, 1.0)).abs();
    final shakeAmount = (1 - _phase(0, 350)) * 6;
    final shakeX = math.sin(t * math.pi * 14) * shakeAmount;
    final shakeY = math.cos(t * math.pi * 11) * shakeAmount * 0.6;

    final bodyOpacity =
        (1 - Curves.easeIn.transform(_phase(350, 850))).clamp(0.0, 1.0);
    final crackOpacity = Curves.easeOut.transform(_phase(400, 750));
    final burstProgress = Curves.easeOut.transform(_phase(180, 950));
    final particleFade = (1 - _phase(700, 1100)).clamp(0.0, 1.0);

    final titleProgress = Curves.elasticOut.transform(_phase(850, 1200));
    final titleOpacity = Curves.easeOut.transform(_phase(850, 1000));

    final rewardsOpacity = Curves.easeOut.transform(_phase(1350, 1600));
    final rewardsSlide = (1 - rewardsOpacity) * 28;

    final defeatTitle = BossDefeatAnimationConfig.defeatTitle(
      type: _animationType,
      isEliteBoss: widget.boss.isEliteBoss,
    );

    final squash = 1 + math.sin(_phase(120, 420) * math.pi * 3) * 0.08;
    final scaleX = _animationType == BossDefeatAnimationType.slimeBurst ||
            _animationType == BossDefeatAnimationType.royalSlimeBurst
        ? 1 + (1 - squash) * 0.15
        : 1 + _phase(250, 500) * 0.06;
    final scaleY = _animationType == BossDefeatAnimationType.slimeBurst ||
            _animationType == BossDefeatAnimationType.royalSlimeBurst
        ? squash
        : 1 + _phase(250, 500) * 0.06;

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
                ColoredBox(color: _flashColor(flash)),
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
            painter: _AnimParticlePainter(
              particles: _particles,
              type: _animationType,
              progress: burstProgress,
              fade: particleFade,
            ),
          ),
          if (_animationType == BossDefeatAnimationType.golemCollapse)
            Opacity(
              opacity: Curves.easeOut.transform(_phase(550, 900)) * 0.35,
              child: Align(
                alignment: const Alignment(0, 0.35),
                child: Container(
                  width: 140,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          Opacity(
            opacity: bodyOpacity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
              child: _BossDefeatBody(
                type: _animationType,
                bossEmoji: widget.boss.emoji,
                crackOpacity: crackOpacity,
                phase: _controller.value,
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
                    defeatTitle,
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

class _BossDefeatBody extends StatelessWidget {
  const _BossDefeatBody({
    required this.type,
    required this.bossEmoji,
    required this.crackOpacity,
    required this.phase,
  });

  final BossDefeatAnimationType type;
  final String bossEmoji;
  final double crackOpacity;
  final double phase;

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      BossDefeatAnimationType.slimeBurst => _SlimeBody(
          bossEmoji: bossEmoji,
          crackOpacity: crackOpacity,
          royal: false,
        ),
      BossDefeatAnimationType.royalSlimeBurst => Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            _SlimeBody(
              bossEmoji: bossEmoji,
              crackOpacity: crackOpacity,
              royal: true,
            ),
            Transform.translate(
              offset: Offset(0, -60 - math.sin(phase * math.pi * 4) * 8),
              child: Transform.rotate(
                angle: phase * math.pi * 2,
                child: const Text('👑', style: TextStyle(fontSize: 36)),
              ),
            ),
          ],
        ),
      BossDefeatAnimationType.golemCollapse => _GolemBody(
          bossEmoji: bossEmoji,
          crackOpacity: crackOpacity,
        ),
      BossDefeatAnimationType.shadowFeathers => _ShadowBirdBody(
          bossEmoji: bossEmoji,
          crackOpacity: crackOpacity,
          eyeOpacity: (1 - phase * 2.5).clamp(0.0, 1.0),
        ),
      BossDefeatAnimationType.guardianShatter => _GuardianBody(
          bossEmoji: bossEmoji,
          crackOpacity: crackOpacity,
          glowOpacity: crackOpacity * 0.9,
        ),
      BossDefeatAnimationType.shadowPhoenixFlame => _PhoenixBody(
          bossEmoji: bossEmoji,
          pulse: 0.85 + math.sin(phase * math.pi * 6) * 0.15,
          crackOpacity: crackOpacity,
        ),
      BossDefeatAnimationType.generic => _GenericBody(
          bossEmoji: bossEmoji,
          crackOpacity: crackOpacity,
        ),
    };
  }
}

class _SlimeBody extends StatelessWidget {
  const _SlimeBody({
    required this.bossEmoji,
    required this.crackOpacity,
    required this.royal,
  });

  final String bossEmoji;
  final double crackOpacity;
  final bool royal;

  @override
  Widget build(BuildContext context) {
    final green = royal ? const Color(0xFF2E7D32) : const Color(0xFF43A047);
    return SizedBox(
      width: royal ? 130 : 118,
      height: royal ? 118 : 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: royal ? 118 : 104,
            height: royal ? 96 : 88,
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: green.withValues(alpha: 0.55),
                  blurRadius: royal ? 28 : 18,
                  spreadRadius: royal ? 6 : 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                bossEmoji,
                style: TextStyle(
                  fontSize: royal ? 40 : 36,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
          if (royal && crackOpacity > 0)
            ...List.generate(4, (i) {
              return Positioned(
                top: 20 + i * 8.0,
                left: 24 + (i % 2) * 40.0,
                child: Icon(
                  Icons.star,
                  size: 12,
                  color: Colors.amber.withValues(alpha: crackOpacity),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _GolemBody extends StatelessWidget {
  const _GolemBody({
    required this.bossEmoji,
    required this.crackOpacity,
  });

  final String bossEmoji;
  final double crackOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 96,
            height: 112,
            decoration: BoxDecoration(
              color: const Color(0xFF8D6E63).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFBCAAA4), width: 3),
            ),
            child: Center(
              child: Text(
                bossEmoji,
                style: TextStyle(
                  fontSize: 38,
                  color: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: crackOpacity,
            child: CustomPaint(
              size: const Size(96, 112),
              painter: _GolemCrackPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadowBirdBody extends StatelessWidget {
  const _ShadowBirdBody({
    required this.bossEmoji,
    required this.crackOpacity,
    required this.eyeOpacity,
  });

  final String bossEmoji;
  final double crackOpacity;
  final double eyeOpacity;

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
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.94),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade900.withValues(alpha: 0.5),
                  blurRadius: 22,
                ),
              ],
            ),
            child: Center(
              child: Text(
                bossEmoji,
                style: TextStyle(
                  fontSize: 42,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          Positioned(
            top: 38,
            child: Opacity(
              opacity: eyeOpacity,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE040FB),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFE040FB),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Opacity(
            opacity: crackOpacity * 0.6,
            child: CustomPaint(
              size: const Size(108, 108),
              painter: _SmokeWispPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuardianBody extends StatelessWidget {
  const _GuardianBody({
    required this.bossEmoji,
    required this.crackOpacity,
    required this.glowOpacity,
  });

  final String bossEmoji;
  final double crackOpacity;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF37474F).withValues(alpha: 0.9),
              border: Border.all(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.85),
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF42A5F5).withValues(alpha: glowOpacity),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                bossEmoji,
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
            ),
          ),
          Opacity(
            opacity: crackOpacity,
            child: CustomPaint(
              size: const Size(112, 112),
              painter: _GuardianCrackPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoenixBody extends StatelessWidget {
  const _PhoenixBody({
    required this.bossEmoji,
    required this.pulse,
    required this.crackOpacity,
  });

  final String bossEmoji;
  final double pulse;
  final double crackOpacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: pulse,
      child: SizedBox(
        width: 130,
        height: 130,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D47A1).withValues(alpha: 0.95),
                    const Color(0xFF1A237E).withValues(alpha: 0.98),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.65),
                    blurRadius: 30,
                    spreadRadius: 6,
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
              opacity: crackOpacity * 0.75,
              child: CustomPaint(
                size: const Size(118, 118),
                painter: _FlameArcPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenericBody extends StatelessWidget {
  const _GenericBody({
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
              painter: _SimpleCrackPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.85)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - 8, c.dy - 20)
        ..lineTo(c.dx + 4, c.dy - 2)
        ..lineTo(c.dx - 6, c.dy + 8)
        ..lineTo(c.dx + 10, c.dy + 22),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GolemCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF8E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(c + const Offset(-20, -30), c + const Offset(8, 10), paint);
    canvas.drawLine(c + const Offset(18, -24), c + const Offset(-6, 18), paint);
    canvas.drawLine(c + const Offset(-4, 8), c + const Offset(22, 34), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GuardianCrackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81D4FA)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final c = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      canvas.drawLine(
        c,
        c + Offset(math.cos(angle) * 34, math.sin(angle) * 34),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SmokeWispPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple.shade200.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.25),
        width: 40,
        height: 18,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FlameArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 36),
      -math.pi * 0.85,
      math.pi * 1.2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: 28),
      math.pi * 0.15,
      math.pi * 0.9,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label, required this.color});

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

enum _ParticleShape { circle, oval, rect, splat }

class _AnimParticle {
  _AnimParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.verticalBias,
    required this.shape,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final double verticalBias;
  final _ParticleShape shape;

  static List<_AnimParticle> generate(BossDefeatAnimationType type) {
    final random = math.Random(type.index + 11);
    final count = switch (type) {
      BossDefeatAnimationType.royalSlimeBurst ||
      BossDefeatAnimationType.shadowPhoenixFlame =>
        24,
      _ => 18,
    };

    List<Color> colors(BossDefeatAnimationType t) => switch (t) {
          BossDefeatAnimationType.slimeBurst ||
          BossDefeatAnimationType.royalSlimeBurst =>
            [
              const Color(0xFF66BB6A),
              const Color(0xFF43A047),
              const Color(0xFFA5D6A7),
              const Color(0xFF2E7D32),
              if (t == BossDefeatAnimationType.royalSlimeBurst)
                const Color(0xFFFFD54F),
            ],
          BossDefeatAnimationType.golemCollapse => [
              const Color(0xFFBCAAA4),
              const Color(0xFF8D6E63),
              const Color(0xFFD7CCC8),
              const Color(0xFFEFEBE9),
            ],
          BossDefeatAnimationType.shadowFeathers => [
              const Color(0xFF4A148C),
              const Color(0xFF1A1A2E),
              const Color(0xFF7E57C2),
              const Color(0xFF311B92),
            ],
          BossDefeatAnimationType.guardianShatter => [
              const Color(0xFF42A5F5),
              const Color(0xFFFFD54F),
              const Color(0xFFECEFF1),
              const Color(0xFF90CAF9),
            ],
          BossDefeatAnimationType.shadowPhoenixFlame => [
              const Color(0xFF1565C0),
              const Color(0xFF0D47A1),
              const Color(0xFF5C6BC0),
              const Color(0xFF283593),
              const Color(0xFF82B1FF),
            ],
          BossDefeatAnimationType.generic => [
              const Color(0xFFFFEB3B),
              const Color(0xFF64B5F6),
              Colors.white,
            ],
        };

    final palette = colors(type);
    final verticalBias = switch (type) {
      BossDefeatAnimationType.golemCollapse => 0.85,
      BossDefeatAnimationType.shadowFeathers => -0.45,
      BossDefeatAnimationType.shadowPhoenixFlame => -0.65,
      BossDefeatAnimationType.slimeBurst ||
      BossDefeatAnimationType.royalSlimeBurst =>
        0.35,
      _ => 0.0,
    };

    _ParticleShape shapeFor(int i) {
      switch (type) {
        case BossDefeatAnimationType.shadowFeathers:
          return _ParticleShape.oval;
        case BossDefeatAnimationType.golemCollapse:
        case BossDefeatAnimationType.guardianShatter:
          return i.isEven ? _ParticleShape.rect : _ParticleShape.circle;
        case BossDefeatAnimationType.slimeBurst:
        case BossDefeatAnimationType.royalSlimeBurst:
          return i % 3 == 0 ? _ParticleShape.splat : _ParticleShape.circle;
        case BossDefeatAnimationType.shadowPhoenixFlame:
          return _ParticleShape.oval;
        default:
          return _ParticleShape.circle;
      }
    }

    final maxDist = switch (type) {
      BossDefeatAnimationType.royalSlimeBurst => 130.0,
      BossDefeatAnimationType.shadowPhoenixFlame => 110.0,
      _ => 95.0,
    };

    return List.generate(count, (index) {
      return _AnimParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 35 + random.nextDouble() * maxDist,
        size: 4 + random.nextDouble() * 9,
        color: palette[index % palette.length],
        verticalBias: verticalBias + (random.nextDouble() - 0.5) * 0.35,
        shape: shapeFor(index),
      );
    });
  }
}

class _AnimParticlePainter extends CustomPainter {
  _AnimParticlePainter({
    required this.particles,
    required this.type,
    required this.progress,
    required this.fade,
  });

  final List<_AnimParticle> particles;
  final BossDefeatAnimationType type;
  final double progress;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height / 2 - 20);

    for (final particle in particles) {
      final radial = particle.distance * progress;
      final vx = math.cos(particle.angle) * radial;
      final vy = math.sin(particle.angle) * radial + particle.verticalBias * 40 * progress;
      final offset = Offset(center.dx + vx, center.dy + vy);
      final alpha = ((1 - progress * 0.65) * fade).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      switch (particle.shape) {
        case _ParticleShape.circle:
          canvas.drawCircle(
            offset,
            particle.size * (1 - progress * 0.25),
            paint,
          );
        case _ParticleShape.splat:
          canvas.drawOval(
            Rect.fromCenter(
              center: offset,
              width: particle.size * 2.2,
              height: particle.size * 1.2,
            ),
            paint,
          );
        case _ParticleShape.oval:
          canvas.save();
          canvas.translate(offset.dx, offset.dy);
          canvas.rotate(particle.angle);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 2.4,
              height: particle.size * 0.9,
            ),
            paint,
          );
          canvas.restore();
        case _ParticleShape.rect:
          canvas.save();
          canvas.translate(offset.dx, offset.dy);
          canvas.rotate(particle.angle);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size * 1.6,
              height: particle.size,
            ),
            paint,
          );
          canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fade != fade ||
        oldDelegate.type != type;
  }
}
