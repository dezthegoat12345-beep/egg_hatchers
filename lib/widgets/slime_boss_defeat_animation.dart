import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import '../utils/format_utils.dart';
import 'boss_battle_background.dart';
import 'boss_sprite.dart';

enum _SlimeExpression { none, dizzy, surprised }

enum _GooKind { blob, splat, smear, screenSplat }

/// Cinematic Slime Boss defeat celebration for manual battle victories.
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

  static const duration = Duration(milliseconds: 11000);

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
  static const _totalMs = 11000.0;
  static const _skipAfterMs = 1000.0;
  static const _baseSpriteSize = 158.0;
  static const _sizeBoost = 1.38;

  late final AnimationController _controller;
  late final List<_GooParticle> _particles;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _particles = _GooParticle.generate();
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
    if (t < 6800) return _SlimeExpression.dizzy;
    if (t < 7200) return _SlimeExpression.surprised;
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
        final zoomScale = 0.88 + zoomPhase * 0.58;
        final darken = (0.32 + zoomPhase * 0.38).clamp(0.0, 0.72);

        final wobblePhase = _phase(1000, 5500);
        final pressurePhase = _phase(5500, 7200);
        final wobbleAmp =
            6 + wobblePhase * 14 + pressurePhase * 28;
        final wobbleSpeed = 190 - pressurePhase * 110;
        final wobbleX = t >= 1000 && t < 7200
            ? math.sin(t / wobbleSpeed * math.pi) * wobbleAmp
            : 0.0;
        final squashStrength = 0.05 + wobblePhase * 0.07 + pressurePhase * 0.14;
        final squash = 1 + math.sin(t / (220 - pressurePhase * 80) * math.pi) * squashStrength;

        final earlyInflate = Curves.easeInOut.transform(_phase(3000, 5500));
        final finalInflate = Curves.easeIn.transform(_phase(5500, 7200));
        final inflateScale = 1.0 + earlyInflate * 0.42 + finalInflate * 1.0;

        final bossScale = zoomScale * inflateScale * _sizeBoost;
        final scaleX = bossScale * (1 + (1 - squash) * (0.14 + pressurePhase * 0.12));
        final scaleY = bossScale * squash;

        final surpriseShake = t >= 6800 && t < 7200
            ? math.sin(t / 28 * math.pi) * 6 * (1 - _phase(6800, 7100))
            : 0.0;

        final popPhase = Curves.easeIn.transform(_phase(7200, 7600));
        final bossOpacity = t < 7200 ? 1.0 : (1 - popPhase).clamp(0.0, 1.0);

        final flash = t >= 7200 && t < 7800
            ? (1 - _phase(7200, 7800)).clamp(0.0, 1.0)
            : 0.0;

        final explodeOut = Curves.easeOutCubic.transform(_phase(7200, 7600));
        final shakeAmp = explodeOut * 16 * (1 - _phase(7200, 7900));
        final shakeX = math.sin(t / 28 * math.pi) * shakeAmp;
        final shakeY = math.cos(t / 34 * math.pi) * shakeAmp * 0.65;

        final splatStick = Curves.easeOut.transform(_phase(7200, 7800));
        final particleFade = (1 - _phase(9200, 10600)).clamp(0.0, 1.0);

        final pressureGlow = pressurePhase * (1 - popPhase);

        final titleProgress = Curves.elasticOut.transform(_phase(9200, 9800));
        final titleOpacity = Curves.easeOut.transform(_phase(9200, 9600));
        final rewardsOpacity = Curves.easeOut.transform(_phase(9800, 10600));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        final canSkip = t >= _skipAfterMs && !_completed;

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
                    color: const Color(0xFF66BB6A).withValues(alpha: flash * 0.72),
                  ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: CustomPaint(
                    painter: _GooParticlePainter(
                      particles: _particles,
                      explodeProgress: explodeOut,
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
                          spriteSize: _baseSpriteSize,
                          expression: expression,
                          timeMs: t,
                          wobblePhase: wobblePhase,
                          pressurePhase: pressurePhase,
                          pressureGlow: pressureGlow,
                        ),
                      ),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 88),
                    Opacity(
                      opacity: titleOpacity,
                      child: Transform.scale(
                        scale: 0.75 + titleProgress * 0.25,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: titleOpacity * 0.9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                    ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: rewardsOpacity,
                      child: Transform.translate(
                        offset: Offset(0, rewardsSlide),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
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
    required this.pressurePhase,
    required this.pressureGlow,
  });

  final BossBattleDefinition boss;
  final double spriteSize;
  final _SlimeExpression expression;
  final double timeMs;
  final double wobblePhase;
  final double pressurePhase;
  final double pressureGlow;

  @override
  Widget build(BuildContext context) {
    final starAngle = timeMs / 600 * math.pi * 2;

    return SizedBox(
      width: spriteSize + 100,
      height: spriteSize + 100,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (pressureGlow > 0)
            Container(
              width: spriteSize * (1.1 + pressurePhase * 0.5),
              height: spriteSize * (1.1 + pressurePhase * 0.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withValues(
                      alpha: 0.25 + pressureGlow * 0.45,
                    ),
                    blurRadius: 28 + pressurePhase * 24,
                    spreadRadius: 6 + pressurePhase * 10,
                  ),
                ],
              ),
            ),
          if (pressurePhase > 0.15)
            ...List.generate(3, (i) {
              final pulse = (pressurePhase - i * 0.12).clamp(0.0, 1.0);
              if (pulse <= 0) return const SizedBox.shrink();
              return Opacity(
                opacity: pulse * 0.35,
                child: Container(
                  width: spriteSize * (0.9 + i * 0.18 + pressurePhase * 0.35),
                  height: spriteSize * (0.9 + i * 0.18 + pressurePhase * 0.35),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFA5D6A7).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                ),
              );
            }),
          if (expression == _SlimeExpression.dizzy)
            ...List.generate(3, (i) {
              final a = starAngle + i * math.pi * 2 / 3;
              return Transform.translate(
                offset: Offset(
                  math.cos(a) * (spriteSize * 0.44),
                  math.sin(a) * (spriteSize * 0.3) - spriteSize * 0.12,
                ),
                child: Text(
                  '⭐',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.yellow.withValues(
                      alpha: 0.55 + wobblePhase * 0.35,
                    ),
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
              top: spriteSize * 0.2,
              child: CustomPaint(
                size: Size(spriteSize * 0.58, spriteSize * 0.3),
                painter: _SlimeFacePainter(
                  expression: expression,
                  spin: timeMs / 400 * math.pi * 2,
                  surprisedScale:
                      expression == _SlimeExpression.surprised ? 1.25 : 1.0,
                ),
              ),
            ),
          if ((expression == _SlimeExpression.dizzy && wobblePhase > 0.2) ||
              pressurePhase > 0.2)
            Positioned(
              top: spriteSize * 0.55,
              child: Opacity(
                opacity: (wobblePhase * 0.45 + pressurePhase * 0.55).clamp(0.0, 1.0),
                child: CustomPaint(
                  size: Size(spriteSize * 0.75, spriteSize * 0.38),
                  painter: _SlimeBubblePainter(
                    seed: 3,
                    count: 6 + (pressurePhase * 8).round(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlimeFacePainter extends CustomPainter {
  _SlimeFacePainter({
    required this.expression,
    required this.spin,
    required this.surprisedScale,
  });

  final _SlimeExpression expression;
  final double spin;
  final double surprisedScale;

  @override
  void paint(Canvas canvas, Size size) {
    final leftEye = Offset(size.width * 0.28, size.height * 0.42);
    final rightEye = Offset(size.width * 0.72, size.height * 0.42);
    final eyeR = 11.0 * surprisedScale;

    if (expression == _SlimeExpression.dizzy) {
      _drawSpiralEye(canvas, leftEye, eyeR, spin);
      _drawSpiralEye(canvas, rightEye, eyeR, -spin);
      return;
    }

    if (expression == _SlimeExpression.surprised) {
      final white = Paint()..color = Colors.white;
      final pupil = Paint()..color = const Color(0xFF1B5E20);
      canvas.drawCircle(leftEye, eyeR + 4, white);
      canvas.drawCircle(rightEye, eyeR + 4, white);
      canvas.drawCircle(leftEye, 5.5, pupil);
      canvas.drawCircle(rightEye, 5.5, pupil);

      final mouth = Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, size.height * 0.9),
          width: 22 * surprisedScale,
          height: 18 * surprisedScale,
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
      oldDelegate.expression != expression ||
      oldDelegate.spin != spin ||
      oldDelegate.surprisedScale != surprisedScale;
}

class _SlimeBubblePainter extends CustomPainter {
  _SlimeBubblePainter({required this.seed, this.count = 6});

  final int seed;
  final int count;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final bubble = Paint()..color = const Color(0xFFA5D6A7).withValues(alpha: 0.5);
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (0.12 + random.nextDouble() * 0.76),
          size.height * (0.15 + random.nextDouble() * 0.7),
        ),
        3 + random.nextDouble() * 5,
        bubble,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SlimeBubblePainter oldDelegate) =>
      oldDelegate.count != count;
}

class _GooParticle {
  _GooParticle({
    required this.kind,
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.outlineColor,
    required this.verticalBias,
    required this.stickNx,
    required this.stickNy,
    required this.aspectRatio,
    required this.rotation,
    required this.lumpiness,
  });

  final _GooKind kind;
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final Color outlineColor;
  final double verticalBias;
  final double stickNx;
  final double stickNy;
  final double aspectRatio;
  final double rotation;
  final double lumpiness;

  static List<_GooParticle> generate() {
    final random = math.Random(42);
    const palette = [
      Color(0xFF66BB6A),
      Color(0xFF43A047),
      Color(0xFF2E7D32),
      Color(0xFFA5D6A7),
      Color(0xFF1B5E20),
      Color(0xFF81C784),
    ];
    const outlines = [
      Color(0xFF1B5E20),
      Color(0xFF33691E),
      Color(0xFF2E7D32),
    ];

    final particles = <_GooParticle>[];

    for (var i = 0; i < 38; i++) {
      particles.add(
        _GooParticle(
          kind: _GooKind.blob,
          angle: random.nextDouble() * math.pi * 2,
          distance: 0.22 + random.nextDouble() * 0.48,
          size: 5 + random.nextDouble() * 10,
          color: palette[i % palette.length],
          outlineColor: outlines[i % outlines.length],
          verticalBias: 0.2 + random.nextDouble() * 0.6,
          stickNx: 0,
          stickNy: 0,
          aspectRatio: 1,
          rotation: 0,
          lumpiness: 0,
        ),
      );
    }

    for (var i = 0; i < 14; i++) {
      particles.add(
        _GooParticle(
          kind: _GooKind.splat,
          angle: random.nextDouble() * math.pi * 2,
          distance: 0.35 + random.nextDouble() * 0.55,
          size: 14 + random.nextDouble() * 22,
          color: palette[(i + 2) % palette.length],
          outlineColor: outlines[i % outlines.length],
          verticalBias: 0.15 + random.nextDouble() * 0.5,
          stickNx: -0.92 + random.nextDouble() * 1.84,
          stickNy: -0.88 + random.nextDouble() * 1.76,
          aspectRatio: 0.65 + random.nextDouble() * 0.7,
          rotation: random.nextDouble() * math.pi,
          lumpiness: 0.3 + random.nextDouble() * 0.5,
        ),
      );
    }

    for (var i = 0; i < 8; i++) {
      particles.add(
        _GooParticle(
          kind: _GooKind.smear,
          angle: random.nextDouble() * math.pi * 2,
          distance: 0.4 + random.nextDouble() * 0.45,
          size: 18 + random.nextDouble() * 28,
          color: palette[(i + 4) % palette.length],
          outlineColor: outlines[i % outlines.length],
          verticalBias: 0.5 + random.nextDouble() * 0.4,
          stickNx: -0.85 + random.nextDouble() * 1.7,
          stickNy: -0.75 + random.nextDouble() * 1.5,
          aspectRatio: 1.6 + random.nextDouble() * 1.2,
          rotation: random.nextDouble() * math.pi,
          lumpiness: 0.4,
        ),
      );
    }

    const screenAnchors = [
      (-0.85, -0.82),
      (0.0, -0.88),
      (0.85, -0.82),
      (-0.92, -0.2),
      (0.92, -0.15),
      (-0.88, 0.55),
      (0.88, 0.58),
      (0.0, 0.72),
      (-0.55, 0.35),
      (0.55, 0.38),
      (-0.35, -0.45),
      (0.4, -0.42),
    ];

    for (var i = 0; i < screenAnchors.length; i++) {
      final (nx, ny) = screenAnchors[i];
      particles.add(
        _GooParticle(
          kind: _GooKind.screenSplat,
          angle: random.nextDouble() * math.pi * 2,
          distance: 0.5 + random.nextDouble() * 0.35,
          size: 28 + random.nextDouble() * 38,
          color: palette[i % palette.length],
          outlineColor: outlines[i % outlines.length],
          verticalBias: 0,
          stickNx: nx + (random.nextDouble() - 0.5) * 0.08,
          stickNy: ny + (random.nextDouble() - 0.5) * 0.08,
          aspectRatio: 0.7 + random.nextDouble() * 0.55,
          rotation: random.nextDouble() * math.pi,
          lumpiness: 0.45 + random.nextDouble() * 0.35,
        ),
      );
    }

    return particles;
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
    final maxDim = math.max(size.width, size.height);

    if (explodeProgress > 0.02) {
      final centralAlpha = (explodeProgress * fade * 0.85).clamp(0.0, 1.0);
      _drawIrregularSplat(
        canvas,
        center,
        60 + explodeProgress * maxDim * 0.38,
        44 + explodeProgress * maxDim * 0.28,
        0,
        const Color(0xFF43A047),
        const Color(0xFF1B5E20),
        centralAlpha,
        0.35,
      );
    }

    for (final p in particles) {
      final travel = Curves.easeOutCubic.transform(explodeProgress);
      final dist = p.distance * maxDim * travel;
      final gravity = travel * travel * p.verticalBias * maxDim * 0.12;
      final flying = center +
          Offset(
            math.cos(p.angle) * dist,
            math.sin(p.angle) * dist * 0.72 + gravity,
          );

      final isSticky = p.kind == _GooKind.splat ||
          p.kind == _GooKind.smear ||
          p.kind == _GooKind.screenSplat;

      if (isSticky && travel > 0.2) {
        final stickCenter = center +
            Offset(
              p.stickNx * size.width * 0.48,
              p.stickNy * size.height * 0.46,
            );
        final alpha = (splatStick * fade).clamp(0.0, 1.0);
        if (alpha <= 0) continue;

        if (p.kind == _GooKind.smear) {
          _drawSmear(
            canvas,
            stickCenter,
            p.size * (0.8 + splatStick * 0.4),
            p.rotation,
            p.color,
            p.outlineColor,
            alpha * 0.88,
          );
        } else {
          _drawIrregularSplat(
            canvas,
            stickCenter,
            p.size * (1.6 + splatStick * 0.5),
            p.size * p.aspectRatio * (1.4 + splatStick * 0.4),
            p.rotation,
            p.color,
            p.outlineColor,
            alpha * 0.92,
            p.lumpiness,
          );
        }
      } else if (travel > 0 && p.kind == _GooKind.blob) {
        final alpha = (fade * (1 - travel * 0.08)).clamp(0.0, 1.0);
        if (alpha <= 0) continue;

        final blobPaint = Paint()..color = p.color.withValues(alpha: alpha * 0.9);
        canvas.drawCircle(flying, p.size, blobPaint);
        canvas.drawCircle(
          flying + Offset(-p.size * 0.28, -p.size * 0.28),
          p.size * 0.32,
          Paint()..color = Colors.white.withValues(alpha: alpha * 0.38),
        );
        canvas.drawCircle(
          flying,
          p.size + 1.2,
          Paint()
            ..color = p.outlineColor.withValues(alpha: alpha * 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }
  }

  void _drawIrregularSplat(
    Canvas canvas,
    Offset center,
    double width,
    double height,
    double rotation,
    Color fill,
    Color outline,
    double alpha,
    double lumpiness,
  ) {
    if (alpha <= 0) return;

    final path = Path();
    const points = 10;
    for (var i = 0; i <= points; i++) {
      final t = i / points;
      final angle = rotation + t * math.pi * 2;
      final wobble = 1 + math.sin(t * math.pi * 5) * lumpiness * 0.22;
      final rX = width * 0.5 * wobble;
      final rY = height * 0.5 * (1 + math.cos(t * math.pi * 4) * lumpiness * 0.15);
      final p = center + Offset(math.cos(angle) * rX, math.sin(angle) * rY);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()..color = fill.withValues(alpha: alpha * 0.88),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = outline.withValues(alpha: alpha * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.drawCircle(
      center + Offset(-width * 0.12, -height * 0.1),
      width * 0.08,
      Paint()..color = Colors.white.withValues(alpha: alpha * 0.25),
    );
  }

  void _drawSmear(
    Canvas canvas,
    Offset center,
    double length,
    double rotation,
    Color fill,
    Color outline,
    double alpha,
  ) {
    if (alpha <= 0) return;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final smear = Path()
      ..moveTo(-length * 0.15, -length * 0.08)
      ..quadraticBezierTo(length * 0.35, 0, length * 0.55, length * 0.12)
      ..quadraticBezierTo(length * 0.2, length * 0.18, -length * 0.1, length * 0.06)
      ..close();

    canvas.drawPath(
      smear,
      Paint()..color = fill.withValues(alpha: alpha * 0.82),
    );
    canvas.drawPath(
      smear,
      Paint()
        ..color = outline.withValues(alpha: alpha * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.restore();
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
