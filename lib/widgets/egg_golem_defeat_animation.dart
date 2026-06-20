import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';
import 'egg_golem_cave_background.dart';

/// Cinematic Egg Golem defeat celebration for manual battle victories.
class EggGolemDefeatAnimation extends StatefulWidget {
  const EggGolemDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.onComplete,
  });

  static const duration = Duration(milliseconds: 10500);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final VoidCallback onComplete;

  @override
  State<EggGolemDefeatAnimation> createState() =>
      _EggGolemDefeatAnimationState();
}

class _EggGolemDefeatAnimationState extends State<EggGolemDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 10500.0;
  static const _skipAfterMs = 1000.0;
  static const _collapseStartMs = 6500.0;
  static const _burstEndMs = 8500.0;
  static const _baseSpriteSize = 158.0;
  static const _sizeBoost = 1.32;

  late final AnimationController _controller;
  late final List<_RockChunk> _chunks;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _chunks = _RockChunk.generate(30);
    _controller = AnimationController(
      vsync: this,
      duration: EggGolemDefeatAnimation.duration,
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
        final zoomScale = 0.86 + zoomPhase * 0.52;
        final darken = (0.28 + zoomPhase * 0.32).clamp(0.0, 0.65);

        final tremblePhase = _phase(1000, 3500);
        final crackSpread = Curves.easeIn.transform(_phase(1000, 6500));
        final collapsePhase = Curves.easeIn.transform(_phase(_collapseStartMs, _burstEndMs));

        final shakeAmp = 4 + tremblePhase * 10 + crackSpread * 14 + collapsePhase * 6;
        final shakeX = t >= 1000 && t < _burstEndMs
            ? math.sin(t / 45 * math.pi) * shakeAmp
            : 0.0;
        final shakeY = t >= 1000 && t < _burstEndMs
            ? math.cos(t / 52 * math.pi) * shakeAmp * 0.55
            : 0.0;

        final bossScale = zoomScale * _sizeBoost * (1 + crackSpread * 0.08);
        final showBoss = t < _collapseStartMs;
        final glowFlash = t >= 3500 && t < _collapseStartMs
            ? (0.35 + math.sin(t / 80 * math.pi) * 0.25) * crackSpread
            : 0.0;
        final collapseFlash = t >= _collapseStartMs
            ? (1 - _phase(_collapseStartMs, _collapseStartMs + 320)).clamp(0.0, 1.0)
            : 0.0;

        final chipTravel = t >= 3500
            ? Curves.easeOutCubic.transform(_phase(3500, _burstEndMs))
            : 0.0;
        final dustExpand = t >= _collapseStartMs
            ? Curves.easeOut.transform(_phase(_collapseStartMs, _burstEndMs))
            : 0.0;
        final effectFade = (1 - _phase(8800, 10200)).clamp(0.0, 1.0);

        final titleProgress = Curves.elasticOut.transform(_phase(8800, 9400));
        final titleOpacity = Curves.easeOut.transform(_phase(8800, 9200));
        final rewardsOpacity = Curves.easeOut.transform(_phase(9200, 10200));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        return Material(
          color: Colors.black.withValues(alpha: 0.82),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t >= _skipAfterMs && !_completed ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const EggGolemCaveBackground(),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (showBoss)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: Transform.scale(
                      scale: bossScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (glowFlash > 0)
                            Container(
                              width: _baseSpriteSize * 1.15,
                              height: _baseSpriteSize * 1.15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFF8E1)
                                        .withValues(alpha: glowFlash * 0.55),
                                    blurRadius: 32,
                                    spreadRadius: 8,
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
                          CustomPaint(
                            size: Size(_baseSpriteSize, _baseSpriteSize * 1.15),
                            painter: _GolemCrackOverlayPainter(
                              progress: crackSpread,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (collapseFlash > 0)
                  ColoredBox(
                    color: const Color(0xFFFFF8E1).withValues(alpha: collapseFlash * 0.55),
                  ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: CustomPaint(
                    painter: _GolemDebrisPainter(
                      chunks: _chunks,
                      travel: chipTravel,
                      dust: dustExpand,
                      fade: effectFade,
                    ),
                  ),
                ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'GOLEM CRUMBLED!',
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

class _GolemCrackOverlayPainter extends CustomPainter {
  _GolemCrackOverlayPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final glow = Paint()
      ..color = const Color(0xFFFFF59D).withValues(alpha: progress * 0.75)
      ..strokeWidth = 2.5 + progress * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final crack = Paint()
      ..color = const Color(0xFFBCAAA4).withValues(alpha: 0.85 + progress * 0.15)
      ..strokeWidth = 2 + progress * 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height * 0.52;
    final lines = [
      [Offset(cx - 20, cy - 40), Offset(cx - 4, cy - 8), Offset(cx + 8, cy + 18)],
      [Offset(cx + 18, cy - 36), Offset(cx + 6, cy + 2), Offset(cx - 12, cy + 28)],
      [Offset(cx, cy - 44), Offset(cx + 14, cy - 10), Offset(cx + 22, cy + 24)],
      [Offset(cx - 14, cy + 6), Offset(cx + 2, cy + 22), Offset(cx + 18, cy + 38)],
    ];

    for (final pts in lines) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length; i++) {
        final p = Offset.lerp(pts[0], pts[i], progress)!;
        if (i == 1) {
          path.lineTo(p.dx, p.dy);
        } else {
          final prev = Offset.lerp(pts[0], pts[i - 1], progress)!;
          path.lineTo(prev.dx, prev.dy);
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, crack);
      canvas.drawPath(path, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _GolemCrackOverlayPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _RockChunk {
  _RockChunk({
    required this.angle,
    required this.distance,
    required this.size,
    required this.rotation,
    required this.delay,
  });

  final double angle;
  final double distance;
  final double size;
  final double rotation;
  final double delay;

  static List<_RockChunk> generate(int count) {
    final random = math.Random(31);
    return List.generate(count, (i) {
      return _RockChunk(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.18 + random.nextDouble() * 0.42,
        size: 6 + random.nextDouble() * 14,
        rotation: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.25,
      );
    });
  }
}

class _GolemDebrisPainter extends CustomPainter {
  _GolemDebrisPainter({
    required this.chunks,
    required this.travel,
    required this.dust,
    required this.fade,
  });

  final List<_RockChunk> chunks;
  final double travel;
  final double dust;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final maxDim = math.max(size.width, size.height);

    if (dust > 0) {
      final dustAlpha = (dust * fade * 0.45).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.08),
          width: 80 + dust * maxDim * 0.55,
          height: 40 + dust * maxDim * 0.22,
        ),
        Paint()..color = const Color(0xFFBCAAA4).withValues(alpha: dustAlpha),
      );
    }

    for (final c in chunks) {
      final localT = ((travel - c.delay) / (1 - c.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      final dist = c.distance * maxDim * eased;
      final gravity = eased * eased * maxDim * 0.14;
      final pos = center +
          Offset(
            math.cos(c.angle) * dist,
            math.sin(c.angle) * dist * 0.55 + gravity,
          );
      final alpha = (fade * (1 - localT * 0.15)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(c.rotation + eased * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.85),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFF8D6E63).withValues(alpha: alpha * 0.92),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: c.size, height: c.size * 0.85),
          const Radius.circular(3),
        ),
        Paint()
          ..color = const Color(0xFFBCAAA4).withValues(alpha: alpha * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GolemDebrisPainter oldDelegate) =>
      oldDelegate.travel != travel ||
      oldDelegate.dust != dust ||
      oldDelegate.fade != fade;
}
