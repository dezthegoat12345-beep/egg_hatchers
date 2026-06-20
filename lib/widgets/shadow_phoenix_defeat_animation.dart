import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';
import 'shadow_phoenix_cinematic_background.dart';

/// Cinematic Shadow Phoenix defeat celebration for manual battle victories.
class ShadowPhoenixDefeatAnimation extends StatefulWidget {
  const ShadowPhoenixDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.onComplete,
  });

  static const duration = Duration(milliseconds: 12000);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final VoidCallback onComplete;

  @override
  State<ShadowPhoenixDefeatAnimation> createState() =>
      _ShadowPhoenixDefeatAnimationState();
}

class _ShadowPhoenixDefeatAnimationState extends State<ShadowPhoenixDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 12000.0;
  static const _skipAfterMs = 1000.0;
  static const _flapStartMs = 1000.0;
  static const _descentStartMs = 3500.0;
  static const _topViewStartMs = 6000.0;
  static const _fallStartMs = 7500.0;
  static const _impactMs = 8800.0;
  static const _smokeEndMs = 10200.0;
  static const _baseSpriteSize = 168.0;
  static const _sizeBoost = 1.38;

  late final AnimationController _controller;
  late final List<_DarkFeather> _feathers;
  late final List<_ShadowEmber> _embers;
  late final List<_SmokePuff> _smokePuffs;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _feathers = _DarkFeather.generate(40);
    _embers = _ShadowEmber.generate(18);
    _smokePuffs = _SmokePuff.generate(16);
    _controller = AnimationController(
      vsync: this,
      duration: ShadowPhoenixDefeatAnimation.duration,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _finishOnce();
      })
      ..forward();
  }

  void _finishOnce() {
    if (_completed || !mounted) return;
    _completed = true;
    _controller.stop();
    widget.onComplete();
  }

  void _trySkip() {
    if (_controller.value * _totalMs < _skipAfterMs || _completed) return;
    _finishOnce();
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 1000));
        final zoomScale = 0.88 + zoomPhase * 0.48;
        final darken = (0.26 + zoomPhase * 0.28).clamp(0.0, 0.58);

        final flapPhase = t >= _flapStartMs ? 1.0 : 0.0;
        final unevenFlap = _phase(_descentStartMs, _topViewStartMs);
        final descentAmount = Curves.easeIn.transform(_phase(_descentStartMs, _topViewStartMs));
        final topViewPhase = Curves.easeInOut.transform(_phase(_topViewStartMs, _fallStartMs));
        final fallProgress = Curves.easeIn.transform(_phase(_fallStartMs, _impactMs));
        final smokeExpand = t >= _impactMs
            ? Curves.easeOut.transform(_phase(_impactMs, _smokeEndMs))
            : 0.0;
        final shockwave = t >= _impactMs
            ? Curves.easeOut.transform(_phase(_impactMs, _impactMs + 900))
            : 0.0;

        final flapSpeed = 130 + unevenFlap * 40;
        final flapTilt = t >= _flapStartMs && t < _impactMs
            ? math.sin(t / flapSpeed * math.pi) *
                (0.1 + unevenFlap * 0.08) *
                (1 - topViewPhase * 0.7)
            : 0.0;
        final flapScaleY = t >= _flapStartMs && t < _impactMs
            ? 1 + math.sin(t / (flapSpeed * 0.85) * math.pi) * 0.07 * (1 - topViewPhase)
            : 1.0;
        final flapScaleX = t >= _flapStartMs && t < _impactMs
            ? 1 + math.sin(t / (flapSpeed * 0.85) * math.pi + math.pi / 2) * 0.04
            : 1.0;

        final wobbleX = t >= _flapStartMs && t < _fallStartMs
            ? math.sin(t / 55 * math.pi) * (4 + unevenFlap * 8)
            : 0.0;

        final bossScale = zoomScale * _sizeBoost;
        final showBoss = t < _impactMs + 80;
        final bossOpacity = t < _impactMs
            ? 1.0
            : (1 - _phase(_impactMs, _impactMs + 200)).clamp(0.0, 1.0);

        // Flying position → top-view fall position
        final flyY = -descentAmount * 38 - topViewPhase * 20;
        final fallY = fallProgress * 120;
        final bossOffsetY = flyY + fallY + topViewPhase * 30;
        final bossOffsetX = wobbleX * (1 - topViewPhase * 0.5);

        // Top-view perspective transforms
        final perspectiveRotate = -topViewPhase * math.pi * 0.48 - fallProgress * 0.15;
        final flattenY = 1.0 - topViewPhase * 0.42;
        final flattenX = 1.0 + topViewPhase * 0.18;
        final fallShrink = 1 - fallProgress * 0.35;

        final featherTravel = t >= _flapStartMs
            ? Curves.easeOut.transform(_phase(_flapStartMs, _smokeEndMs))
            : 0.0;
        final emberTrail = t >= _descentStartMs && t < _impactMs
            ? _phase(_descentStartMs, _impactMs)
            : 0.0;
        final effectFade = (1 - _phase(10200, 11800)).clamp(0.0, 1.0);

        final titleProgress = Curves.elasticOut.transform(_phase(10200, 10800));
        final titleOpacity = Curves.easeOut.transform(_phase(10200, 10600));
        final rewardsOpacity = Curves.easeOut.transform(_phase(10600, 11600));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        return Material(
          color: Colors.black.withValues(alpha: 0.82),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t >= _skipAfterMs && !_completed ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ShadowPhoenixCinematicBackground(topViewPhase: topViewPhase),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (emberTrail > 0 && showBoss)
                  CustomPaint(
                    painter: _EmberTrailPainter(
                      embers: _embers,
                      progress: emberTrail,
                      bossOffset: Offset(bossOffsetX, bossOffsetY),
                      topView: topViewPhase,
                      fade: effectFade,
                    ),
                  ),
                if (showBoss && bossOpacity > 0)
                  Transform.translate(
                    offset: Offset(bossOffsetX, bossOffsetY),
                    child: Transform.rotate(
                      angle: flapTilt + perspectiveRotate,
                      child: Transform.scale(
                        scaleX: bossScale * flapScaleX * flattenX * fallShrink,
                        scaleY: bossScale * flapScaleY * flattenY * fallShrink,
                        child: Opacity(
                        opacity: bossOpacity,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            if (flapPhase > 0 && t < _impactMs)
                              Container(
                                width: _baseSpriteSize * 1.15,
                                height: _baseSpriteSize * 1.15,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7E57C2)
                                          .withValues(alpha: 0.35 * (1 - topViewPhase * 0.5)),
                                      blurRadius: 32,
                                      spreadRadius: 6,
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF1565C0)
                                          .withValues(alpha: 0.25 * (1 - topViewPhase * 0.5)),
                                      blurRadius: 20,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            BossSprite(
                              spritePath: widget.boss.spritePath,
                              fallbackEmoji: widget.boss.emoji,
                              size: _baseSpriteSize,
                              semanticLabel: widget.boss.name,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                CustomPaint(
                  painter: _FallingFeathersPainter(
                    feathers: _feathers,
                    travel: featherTravel,
                    bossOffset: Offset(bossOffsetX, bossOffsetY),
                    topView: topViewPhase,
                    fallProgress: fallProgress,
                    fade: effectFade,
                  ),
                ),
                if (smokeExpand > 0)
                  CustomPaint(
                    painter: _ShadowSmokePainter(
                      puffs: _smokePuffs,
                      expand: smokeExpand,
                      shockwave: shockwave,
                      fade: effectFade,
                    ),
                  ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'SHADOW EXTINGUISHED!',
                  coinReward: widget.coinReward,
                  tokenReward: widget.tokenReward,
                  animalRewardName: widget.animalRewardName,
                  titleProgress: titleProgress,
                  titleOpacity: titleOpacity,
                  rewardsOpacity: rewardsOpacity,
                  rewardsSlide: rewardsSlide,
                  canSkip: t >= _skipAfterMs && !_completed,
                  onSkip: _trySkip,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DarkFeather {
  _DarkFeather({
    required this.wingSide,
    required this.offsetX,
    required this.offsetY,
    required this.drift,
    required this.size,
    required this.rotation,
    required this.delay,
  });

  final int wingSide;
  final double offsetX;
  final double offsetY;
  final double drift;
  final double size;
  final double rotation;
  final double delay;

  static List<_DarkFeather> generate(int count) {
    final random = math.Random(77);
    return List.generate(count, (i) {
      return _DarkFeather(
        wingSide: i.isEven ? -1 : 1,
        offsetX: random.nextDouble() * 28,
        offsetY: random.nextDouble() * 18,
        drift: random.nextDouble() * math.pi * 2,
        size: 7 + random.nextDouble() * 12,
        rotation: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.35,
      );
    });
  }
}

class _ShadowEmber {
  _ShadowEmber({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;

  static List<_ShadowEmber> generate(int count) {
    final random = math.Random(91);
    return List.generate(count, (i) {
      return _ShadowEmber(
        angle: math.pi + random.nextDouble() * math.pi,
        distance: 0.05 + random.nextDouble() * 0.2,
        size: 3 + random.nextDouble() * 5,
        delay: random.nextDouble() * 0.3,
      );
    });
  }
}

class _SmokePuff {
  _SmokePuff({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;

  static List<_SmokePuff> generate(int count) {
    final random = math.Random(99);
    return List.generate(count, (i) {
      return _SmokePuff(
        angle: -math.pi / 2 + (random.nextDouble() - 0.5) * math.pi * 0.8,
        distance: random.nextDouble() * 0.35,
        size: 16 + random.nextDouble() * 32,
        delay: random.nextDouble() * 0.25,
      );
    });
  }
}

class _FallingFeathersPainter extends CustomPainter {
  _FallingFeathersPainter({
    required this.feathers,
    required this.travel,
    required this.bossOffset,
    required this.topView,
    required this.fallProgress,
    required this.fade,
  });

  final List<_DarkFeather> feathers;
  final double travel;
  final Offset bossOffset;
  final double topView;
  final double fallProgress;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (travel <= 0) return;
    final center = Offset(size.width / 2, size.height * 0.46) + bossOffset;
    final maxDim = math.max(size.width, size.height);

    for (final f in feathers) {
      final localT = ((travel - f.delay) / (1 - f.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOut.transform(localT);

      final spawn = center +
          Offset(
            f.wingSide * (48 + f.offsetX) * (1 - topView * 0.3),
            f.offsetY - 10,
          );
      final driftX = math.sin(f.drift + eased * math.pi * 3) * 22;
      final fallDist = eased * maxDim * (0.08 + fallProgress * 0.12);
      final pos = spawn +
          Offset(
            driftX + f.wingSide * eased * 30,
            fallDist + eased * eased * maxDim * 0.18,
          );

      final alpha = (fade * (1 - localT * 0.35)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.rotation + eased * math.pi * 2);
      final path = Path()
        ..moveTo(0, -f.size * 0.5)
        ..quadraticBezierTo(f.size * 0.3, 0, 0, f.size * 0.5)
        ..quadraticBezierTo(-f.size * 0.3, 0, 0, -f.size * 0.5);
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFF311B92).withValues(alpha: alpha * 0.85),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF1565C0).withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FallingFeathersPainter oldDelegate) =>
      oldDelegate.travel != travel ||
      oldDelegate.bossOffset != bossOffset ||
      oldDelegate.topView != topView ||
      oldDelegate.fallProgress != fallProgress ||
      oldDelegate.fade != fade;
}

class _EmberTrailPainter extends CustomPainter {
  _EmberTrailPainter({
    required this.embers,
    required this.progress,
    required this.bossOffset,
    required this.topView,
    required this.fade,
  });

  final List<_ShadowEmber> embers;
  final double progress;
  final Offset bossOffset;
  final double topView;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final center = Offset(size.width / 2, size.height * 0.46) + bossOffset;
    final maxDim = math.max(size.width, size.height);

    for (final e in embers) {
      final localT = ((progress - e.delay) / (1 - e.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final dist = e.distance * maxDim * localT;
      final pos = center +
          Offset(
            math.cos(e.angle) * dist * (1 + topView * 0.3),
            math.sin(e.angle) * dist * 0.6 + localT * 20,
          );
      final alpha = (fade * (1 - localT) * 0.8).clamp(0.0, 1.0);
      canvas.drawCircle(
        pos,
        e.size * (1 - localT * 0.3),
        Paint()..color = const Color(0xFF7E57C2).withValues(alpha: alpha),
      );
      canvas.drawCircle(
        pos,
        e.size * 0.5,
        Paint()..color = const Color(0xFF1565C0).withValues(alpha: alpha * 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EmberTrailPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.bossOffset != bossOffset ||
      oldDelegate.fade != fade;
}

class _ShadowSmokePainter extends CustomPainter {
  _ShadowSmokePainter({
    required this.puffs,
    required this.expand,
    required this.shockwave,
    required this.fade,
  });

  final List<_SmokePuff> puffs;
  final double expand;
  final double shockwave;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (expand <= 0) return;
    final impact = Offset(size.width * 0.5, size.height * 0.74);
    final maxDim = math.max(size.width, size.height);

    if (shockwave > 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: impact,
          width: 40 + shockwave * maxDim * 0.45,
          height: 16 + shockwave * maxDim * 0.12,
        ),
        Paint()
          ..color = const Color(0xFF4A148C).withValues(alpha: fade * shockwave * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: impact - Offset(0, expand * 40),
        width: 50 + expand * maxDim * 0.35,
        height: 30 + expand * maxDim * 0.2,
      ),
      Paint()..color = const Color(0xFF311B92).withValues(alpha: fade * expand * 0.45),
    );

    for (final p in puffs) {
      final localT = ((expand - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final dist = p.distance * maxDim * localT;
      final pos = impact +
          Offset(
            math.cos(p.angle) * dist * 0.6,
            math.sin(p.angle) * dist - localT * 55,
          );
      final alpha = (fade * localT * (1 - localT * 0.5) * 0.55).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: p.size * (0.7 + localT),
          height: p.size * (0.45 + localT * 0.6),
        ),
        Paint()..color = const Color(0xFF4A148C).withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowSmokePainter oldDelegate) =>
      oldDelegate.expand != expand ||
      oldDelegate.shockwave != shockwave ||
      oldDelegate.fade != fade;
}
