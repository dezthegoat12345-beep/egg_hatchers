import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../utils/format_utils.dart';
import 'boss_battle_background.dart';
import 'boss_sprite.dart';

enum _SlimeExpression { none, dizzy, surprised }

/// Cinematic ~10s Slime Boss defeat celebration for manual battle victories.
class SlimeBossDefeatAnimation extends StatefulWidget {
  const SlimeBossDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.showBattleBackgrounds,
    required this.onComplete,
  });

  static const duration = Duration(seconds: 10);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final bool showBattleBackgrounds;
  final VoidCallback onComplete;

  @override
  State<SlimeBossDefeatAnimation> createState() =>
      _SlimeBossDefeatAnimationState();
}

class _SlimeBossDefeatAnimationState extends State<SlimeBossDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 10000.0;
  static const _skipAfterMs = 1000.0;

  late final AnimationController _controller;
  late final List<_GooParticle> _particles;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _particles = _GooParticle.generate(34);
    _controller = AnimationController(
      vsync: this,
      duration: SlimeBossDefeatAnimation.duration,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finish();
      })
      ..forward();
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    _controller.stop();
    widget.onComplete();
  }

  void _trySkip() {
    if (_controller.value * _totalMs < _skipAfterMs) return;
    _finish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double startMs, double endMs) {
    final t = _controller.value * _totalMs;
    if (t <= startMs) return 0;
    if (t >= endMs) return 1;
    return (t - startMs) / (endMs - startMs);
  }

  double _timeMs() => _controller.value * _totalMs;

  _SlimeExpression _expression(double t) {
    if (t < 1000) return _SlimeExpression.none;
    if (t < 6500) return _SlimeExpression.dizzy;
    if (t < 7500) return _SlimeExpression.surprised;
    return _SlimeExpression.none;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        final expression = _expression(t);

        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 1000));
        final sceneZoom = 0.62 + zoomPhase * 0.38;
        final darken = (0.35 + zoomPhase * 0.35).clamp(0.0, 0.72);

        final wobblePhase = _phase(1000, 6500);
        final wobbleAmp = 5 + wobblePhase * 16;
        final wobbleX = t >= 1000 && t < 7500
            ? math.sin(t / 180 * math.pi) * wobbleAmp
            : 0.0;
        final squash = 1 + math.sin(t / 220 * math.pi) * (0.04 + wobblePhase * 0.06);

        final inflate = Curves.easeInOut.transform(_phase(3000, 6500));
        final bossScale = sceneZoom * (1 + inflate * 0.45);
        final scaleX = bossScale * (1 + (1 - squash) * 0.12);
        final scaleY = bossScale * squash;

        final surpriseShake = t >= 6500 && t < 7500
            ? math.sin(t / 40 * math.pi) * 3 * (1 - _phase(6500, 7200))
            : 0.0;

        final explodePhase = Curves.easeOut.transform(_phase(7500, 8500));
        final bossOpacity =
            t < 7500 ? 1.0 : (1 - explodePhase).clamp(0.0, 1.0);

        final flash = t >= 7500 && t < 8200
            ? (1 - _phase(7500, 8200)).clamp(0.0, 1.0)
            : 0.0;

        final shakeAmp = explodePhase * 10 * (1 - _phase(7500, 8500));
        final shakeX = math.sin(t / 35 * math.pi) * shakeAmp;
        final shakeY = math.cos(t / 42 * math.pi) * shakeAmp * 0.6;

        final particleFade = (1 - _phase(8500, 9800)).clamp(0.0, 1.0);
        final splatStick = Curves.easeOut.transform(_phase(7800, 8600));

        final titleProgress =
            Curves.elasticOut.transform(_phase(8500, 9200));
        final titleOpacity = Curves.easeOut.transform(_phase(8500, 9000));
        final rewardsOpacity = Curves.easeOut.transform(_phase(9000, 9800));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        final canSkip = t >= _skipAfterMs && !_completed;
        const spriteSize = 120.0;

        return Material(
          color: Colors.black.withValues(alpha: 0.82),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: canSkip ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (widget.showBattleBackgrounds)
                  BossBattleBackground(bossId: widget.boss.id)
                else
                  ColoredBox(
                    color: widget.theme.panelColor.withValues(alpha: 0.65),
                  ),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (flash > 0)
                  ColoredBox(
                    color: const Color(0xFF66BB6A).withValues(alpha: flash * 0.65),
                  ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: CustomPaint(
                    painter: _GooParticlePainter(
                      particles: _particles,
                      explodeProgress: explodePhase,
                      fade: particleFade,
                      splatStick: splatStick,
                    ),
                  ),
                ),
                if (bossOpacity > 0)
                  Transform.translate(
                    offset: Offset(wobbleX + surpriseShake, 0),
                    child: Opacity(
                      opacity: bossOpacity,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(scaleX, scaleY, 1),
                        child: _SlimeBossStage(
                          boss: widget.boss,
                          spriteSize: spriteSize,
                          expression: expression,
                          timeMs: t,
                          wobblePhase: wobblePhase,
                        ),
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 100),
                    Opacity(
                      opacity: titleOpacity,
                      child: Transform.scale(
                        scale: 0.75 + titleProgress * 0.25,
                        child: const Text(
                          'SLIME SPLAT!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
                if (canSkip)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: TextButton(
                      onPressed: _trySkip,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.black45,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SlimeBossStage extends StatelessWidget {
  const _SlimeBossStage({
    required this.boss,
    required this.spriteSize,
    required this.expression,
    required this.timeMs,
    required this.wobblePhase,
  });

  final BossBattleDefinition boss;
  final double spriteSize;
  final _SlimeExpression expression;
  final double timeMs;
  final double wobblePhase;

  @override
  Widget build(BuildContext context) {
    final starAngle = timeMs / 600 * math.pi * 2;

    return SizedBox(
      width: spriteSize + 80,
      height: spriteSize + 80,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (expression == _SlimeExpression.dizzy)
            ...List.generate(3, (i) {
              final a = starAngle + i * math.pi * 2 / 3;
              return Transform.translate(
                offset: Offset(
                  math.cos(a) * (spriteSize * 0.42),
                  math.sin(a) * (spriteSize * 0.28) - spriteSize * 0.12,
                ),
                child: Text(
                  '⭐',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.yellow.withValues(alpha: 0.55 + wobblePhase * 0.35),
                  ),
                ),
              );
            }),
          BossSprite(
            spritePath: boss.spritePath,
            fallbackEmoji: boss.emoji,
            size: spriteSize,
            semanticLabel: boss.name,
          ),
          if (expression == _SlimeExpression.dizzy ||
              expression == _SlimeExpression.surprised)
            Positioned(
              top: spriteSize * 0.22,
              child: CustomPaint(
                size: Size(spriteSize * 0.55, spriteSize * 0.28),
                painter: _SlimeFacePainter(
                  expression: expression,
                  spin: timeMs / 400 * math.pi * 2,
                ),
              ),
            ),
          if (expression == _SlimeExpression.dizzy && wobblePhase > 0.2)
            Positioned(
              top: spriteSize * 0.58,
              child: Opacity(
                opacity: wobblePhase * 0.5,
                child: CustomPaint(
                  size: Size(spriteSize * 0.7, spriteSize * 0.35),
                  painter: _SlimeBubblePainter(seed: 3),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlimeFacePainter extends CustomPainter {
  _SlimeFacePainter({required this.expression, required this.spin});

  final _SlimeExpression expression;
  final double spin;

  @override
  void paint(Canvas canvas, Size size) {
    final leftEye = Offset(size.width * 0.28, size.height * 0.42);
    final rightEye = Offset(size.width * 0.72, size.height * 0.42);
    const eyeR = 11.0;

    if (expression == _SlimeExpression.dizzy) {
      _drawSpiralEye(canvas, leftEye, eyeR, spin);
      _drawSpiralEye(canvas, rightEye, eyeR, -spin);
      return;
    }

    if (expression == _SlimeExpression.surprised) {
      final white = Paint()..color = Colors.white;
      final pupil = Paint()..color = const Color(0xFF1B5E20);
      canvas.drawCircle(leftEye, eyeR + 3, white);
      canvas.drawCircle(rightEye, eyeR + 3, white);
      canvas.drawCircle(leftEye, 4.5, pupil);
      canvas.drawCircle(rightEye, 4.5, pupil);

      final mouth = Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.88),
          width: 18,
          height: 14,
        ),
        mouth,
      );
    }
  }

  void _drawSpiralEye(Canvas canvas, Offset center, double radius, double angle) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    final spiral = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    for (var i = 0; i <= 24; i++) {
      final t = i / 24;
      final r = radius * 0.15 + radius * 0.75 * t;
      final a = angle + t * math.pi * 3;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, spiral);
  }

  @override
  bool shouldRepaint(covariant _SlimeFacePainter oldDelegate) =>
      oldDelegate.expression != expression || oldDelegate.spin != spin;
}

class _SlimeBubblePainter extends CustomPainter {
  _SlimeBubblePainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final bubble = Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.45);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.15 + random.nextDouble() * 0.7),
          size.height * (0.2 + random.nextDouble() * 0.65),
        ),
        3 + random.nextDouble() * 4,
        bubble,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GooParticle {
  _GooParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.isSplat,
    required this.verticalBias,
    required this.stickX,
    required this.stickY,
  });

  final double angle;
  final double distance;
  final double size;
  final Color color;
  final bool isSplat;
  final double verticalBias;
  final double stickX;
  final double stickY;

  static List<_GooParticle> generate(int count) {
    final random = math.Random(42);
    const palette = [
      Color(0xFF66BB6A),
      Color(0xFF43A047),
      Color(0xFF2E7D32),
      Color(0xFFA5D6A7),
      Color(0xFF1B5E20),
    ];

    return List.generate(count, (index) {
      final isSplat = index % 4 == 0;
      return _GooParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 60 + random.nextDouble() * 140,
        size: 5 + random.nextDouble() * (isSplat ? 14 : 9),
        color: palette[index % palette.length],
        isSplat: isSplat,
        verticalBias: 0.25 + random.nextDouble() * 0.55,
        stickX: -0.75 + random.nextDouble() * 1.5,
        stickY: -0.55 + random.nextDouble() * 1.1,
      );
    });
  }
}

class _GooParticlePainter extends CustomPainter {
  _GooParticlePainter({
    required this.particles,
    required this.explodeProgress,
    required this.fade,
    required this.splatStick,
  });

  final List<_GooParticle> particles;
  final double explodeProgress;
  final double fade;
  final double splatStick;

  @override
  void paint(Canvas canvas, Size size) {
    if (explodeProgress <= 0 && fade >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final travel = explodeProgress;
      final dist = p.distance * Curves.easeOut.transform(travel);
      final gravity = travel * travel * p.verticalBias * 40;
      final offset = Offset(
        math.cos(p.angle) * dist,
        math.sin(p.angle) * dist * 0.65 + gravity,
      );

      final alpha = p.isSplat
          ? (splatStick * fade).clamp(0.0, 1.0)
          : (fade * (1 - travel * 0.15)).clamp(0.0, 1.0);

      if (alpha <= 0) continue;

      final paint = Paint()..color = p.color.withValues(alpha: alpha * 0.9);

      if (p.isSplat && travel > 0.35) {
        final stickCenter = center +
            Offset(
              p.stickX * size.width * 0.42,
              p.stickY * size.height * 0.38,
            );
        canvas.drawOval(
          Rect.fromCenter(
            center: stickCenter,
            width: p.size * 2.2,
            height: p.size * 1.4,
          ),
          paint,
        );
      } else if (travel > 0) {
        canvas.drawCircle(center + offset, p.size, paint);
        if (!p.isSplat) {
          canvas.drawCircle(
            center + offset + Offset(-p.size * 0.25, -p.size * 0.25),
            p.size * 0.35,
            Paint()..color = Colors.white.withValues(alpha: alpha * 0.35),
          );
        }
      }
    }

    if (explodeProgress > 0.05) {
      final splatAlpha = (explodeProgress * fade * 0.75).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 40 + explodeProgress * 120,
          height: 28 + explodeProgress * 80,
        ),
        Paint()..color = const Color(0xFF43A047).withValues(alpha: splatAlpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GooParticlePainter oldDelegate) =>
      oldDelegate.explodeProgress != explodeProgress ||
      oldDelegate.fade != fade ||
      oldDelegate.splatStick != splatStick;
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
