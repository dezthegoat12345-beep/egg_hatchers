import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/audio_assets.dart';
import '../models/animal_sprite_theme.dart';
import '../models/boss_battle.dart';
import '../models/custom_sprite_data.dart';
import '../services/audio_service.dart';
import '../utils/egg_shard_logic.dart';
import '../widgets/animal_sprite_theme_scope.dart';
import '../widgets/boss_sprite.dart';
import '../widgets/game_sprite.dart';

/// Full-screen VS intro before manual boss battle gameplay begins.
class BossFightIntroAnimation extends StatefulWidget {
  const BossFightIntroAnimation({
    super.key,
    required this.fighterName,
    required this.fighterAnimalId,
    required this.fighterSpritePath,
    required this.fighterEmoji,
    required this.fighterCustomSprite,
    required this.boss,
    required this.mode,
    required this.onComplete,
    this.audio,
  });

  static const introDuration = Duration(milliseconds: 3000);

  final String fighterName;
  final String fighterAnimalId;
  final String? fighterSpritePath;
  final String fighterEmoji;
  final CustomSpriteData? fighterCustomSprite;
  final BossBattleDefinition boss;
  final ManualBattleMode mode;
  final VoidCallback onComplete;
  final AudioService? audio;

  /// Mode label shown under the boss name during intro.
  static String? modeLabel(BossBattleDefinition boss, ManualBattleMode mode) {
    if (boss.id == EggShardLogic.rottenShellBossId) return 'Final Boss';
    if (boss.isEliteBoss) return 'Elite';
    return switch (mode) {
      ManualBattleMode.hard => 'Hard Phase',
      ManualBattleMode.nightmare => 'Nightmare',
      ManualBattleMode.normal => null,
    };
  }

  @override
  State<BossFightIntroAnimation> createState() =>
      _BossFightIntroAnimationState();
}

class _BossFightIntroAnimationState extends State<BossFightIntroAnimation>
    with SingleTickerProviderStateMixin {
  static const _skipAfterFraction = 0.2; // 0.6s of 3.0s

  late final AnimationController _controller;
  late final List<_LightningArc> _arcs;
  var _completed = false;
  var _slashSfxPlayed = false;
  var _vsSfxPlayed = false;

  @override
  void initState() {
    super.initState();
    _arcs = _generateArcs(Random(1337), 9);
    _controller = AnimationController(
      vsync: this,
      duration: BossFightIntroAnimation.introDuration,
    )
      ..addListener(_onTick)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _finishOnce();
        }
      })
      ..forward();
  }

  void _onTick() {
    final t = _controller.value;
    if (!_slashSfxPlayed && t >= 0.02) {
      _slashSfxPlayed = true;
      widget.audio?.playSfx(Sfx.shieldBreak, volumeScale: 0.35);
    }
    if (!_vsSfxPlayed && t >= 0.35) {
      _vsSfxPlayed = true;
      widget.audio?.playFinisherSlash();
    }
  }

  void _finishOnce() {
    if (_completed) return;
    _completed = true;
    _controller.stop();
    widget.onComplete();
  }

  void _trySkip() {
    if (_controller.value >= _skipAfterFraction) {
      _finishOnce();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final retroPixel = AnimalSpriteThemeScope.of(context).id ==
        AnimalSpriteThemes.retroPixel.id;
    final modeLabel = BossFightIntroAnimation.modeLabel(widget.boss, widget.mode);

    return Material(
      color: Colors.black.withValues(alpha: 0.92),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _trySkip,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = retroPixel ? _pixelStep(_controller.value, 24) : _controller.value;
                final lineT = _segment(t, 0, 0.133, Curves.easeOut);
                final slideT = _segment(t, 0.133, 0.4, Curves.easeOutCubic);
                final nameT = _segment(t, 0.25, 0.45, Curves.easeOut);
                final holdT = t.clamp(0.4, 0.733);
                final fadeT = _segment(t, 0.733, 1.0, Curves.easeIn);
                final vsPulseT = _segment(t, 0.35, 0.55, Curves.elasticOut);
                final flicker = 0.65 +
                    0.35 *
                        sin(t * pi * 18 + _controller.value * 40).abs();
                final overallOpacity = (1 - fadeT).clamp(0.0, 1.0);

                final playerCenter = Offset(size.width * 0.28, size.height * 0.68);
                final bossCenter = Offset(size.width * 0.72, size.height * 0.32);
                final playerSlide = Offset(
                  ui.lerpDouble(-size.width * 0.4, playerCenter.dx, slideT)!,
                  ui.lerpDouble(size.height * 0.2, playerCenter.dy, slideT)!,
                );
                final bossSlide = Offset(
                  ui.lerpDouble(size.width * 1.15, bossCenter.dx, slideT)!,
                  ui.lerpDouble(-size.height * 0.15, bossCenter.dy, slideT)!,
                );

                final bounce = holdT > 0.4 && holdT < 0.733
                    ? sin((holdT - 0.4) * pi * 6) * 4
                    : 0.0;
                final vsScale = (0.4 + vsPulseT * 0.65) *
                    (1 + (holdT > 0.35 ? sin(t * pi * 8) * 0.06 : 0));

                return Opacity(
                  opacity: overallOpacity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(
                        painter: _IntroSplitBackgroundPainter(
                          progress: lineT,
                          flicker: flicker,
                          retroPixel: retroPixel,
                        ),
                        size: size,
                      ),
                      CustomPaint(
                        painter: _ElectricDiagonalPainter(
                          progress: lineT,
                          flicker: flicker,
                          arcs: _arcs,
                          time: t,
                          retroPixel: retroPixel,
                        ),
                        size: size,
                      ),
                      _FighterSide(
                        center: playerSlide + Offset(0, bounce),
                        name: widget.fighterName,
                        nameOpacity: nameT,
                        spriteSize: min(size.width * 0.28, 96),
                        child: GameSprite(
                          customSprite: widget.fighterCustomSprite,
                          animalId: widget.fighterAnimalId,
                          spritePath: widget.fighterSpritePath,
                          fallbackEmoji: widget.fighterEmoji,
                          size: min(size.width * 0.28, 96),
                          semanticLabel: widget.fighterName,
                        ),
                      ),
                      _FighterSide(
                        center: bossSlide + Offset(0, -bounce * 0.5),
                        name: widget.boss.name,
                        subtitle: modeLabel,
                        nameOpacity: nameT,
                        alignRight: true,
                        spriteSize: min(size.width * 0.32, 112),
                        child: BossSprite(
                          bossId: widget.boss.id,
                          spritePath: widget.boss.spritePath,
                          fallbackEmoji: widget.boss.emoji,
                          size: min(size.width * 0.32, 112),
                          semanticLabel: widget.boss.name,
                        ),
                      ),
                      Center(
                        child: Transform.scale(
                          scale: vsScale,
                          child: Opacity(
                            opacity: (lineT * 0.35 + vsPulseT * 0.65).clamp(0, 1),
                            child: _VsLabel(
                              flicker: flicker,
                              retroPixel: retroPixel,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  static double _segment(
    double t,
    double start,
    double end,
    Curve curve,
  ) {
    if (t <= start) return 0;
    if (t >= end) return 1;
    return curve.transform((t - start) / (end - start));
  }

  static double _pixelStep(double t, int steps) {
    return (t * steps).round() / steps;
  }
}

class _FighterSide extends StatelessWidget {
  const _FighterSide({
    required this.center,
    required this.name,
    required this.nameOpacity,
    required this.spriteSize,
    required this.child,
    this.subtitle,
    this.alignRight = false,
  });

  final Offset center;
  final String name;
  final String? subtitle;
  final double nameOpacity;
  final double spriteSize;
  final Widget child;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: center.dx - spriteSize / 2,
      top: center.dy - spriteSize / 2,
      width: spriteSize + 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          child,
          const SizedBox(height: 8),
          Opacity(
            opacity: nameOpacity.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - nameOpacity) * 12),
              child: Column(
                crossAxisAlignment:
                    alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: alignRight ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 6),
                      ],
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.4,
                        shadows: const [
                          Shadow(color: Colors.black87, blurRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VsLabel extends StatelessWidget {
  const _VsLabel({
    required this.flicker,
    required this.retroPixel,
  });

  final double flicker;
  final bool retroPixel;

  @override
  Widget build(BuildContext context) {
    final glow = Color.lerp(
      const Color(0xFFFFEE58),
      const Color(0xFF40C4FF),
      flicker * 0.5,
    )!;

    return Text(
      'VS',
      style: TextStyle(
        fontSize: retroPixel ? 56 : 64,
        fontWeight: FontWeight.w900,
        letterSpacing: retroPixel ? 2 : 4,
        color: Colors.white,
        shadows: [
          Shadow(color: glow, blurRadius: 18 * flicker),
          Shadow(color: glow.withValues(alpha: 0.7), blurRadius: 36 * flicker),
          const Shadow(color: Colors.black87, blurRadius: 8),
        ],
      ),
    );
  }
}

class _LightningArc {
  const _LightningArc({
    required this.startT,
    required this.endT,
    required this.jitterSeed,
    required this.thickness,
  });

  final double startT;
  final double endT;
  final double jitterSeed;
  final double thickness;
}

List<_LightningArc> _generateArcs(Random random, int count) {
  return List.generate(count, (_) {
    final start = random.nextDouble() * 0.85;
    return _LightningArc(
      startT: start,
      endT: (start + 0.04 + random.nextDouble() * 0.12).clamp(0.05, 1.0),
      jitterSeed: random.nextDouble() * 100,
      thickness: 1.2 + random.nextDouble() * 2.2,
    );
  });
}

class _IntroSplitBackgroundPainter extends CustomPainter {
  _IntroSplitBackgroundPainter({
    required this.progress,
    required this.flicker,
    required this.retroPixel,
  });

  final double progress;
  final double flicker;
  final bool retroPixel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress <= 0) return;

    final playerPath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    final bossPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();

    final playerPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset(size.width * 0.5, size.height * 0.5),
        [
          Color.lerp(const Color(0xFFFF6D00), const Color(0xFFFF9100), flicker)!,
          const Color(0xFFE65100),
        ],
      );

    final bossPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width, 0),
        Offset(size.width * 0.5, size.height * 0.5),
        [
          Color.lerp(const Color(0xFF1A1028), const Color(0xFF311B92), flicker * 0.35)!,
          const Color(0xFF0D0612),
        ],
      );

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: progress),
    );
    canvas.drawPath(playerPath, playerPaint);
    canvas.drawPath(bossPath, bossPaint);
    canvas.restore();

    if (retroPixel) {
      _drawPixelStripes(canvas, size, playerPath, bossPath, progress);
    } else {
      _drawSpeedLines(canvas, size, playerPath, progress);
    }
  }

  void _drawSpeedLines(Canvas canvas, Size size, Path playerPath, double reveal) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 2;
    canvas.save();
    canvas.clipPath(playerPath);
    for (var i = 0; i < 8; i++) {
      final y = size.height * (0.35 + i * 0.08) * reveal;
      canvas.drawLine(
        Offset(-20, y),
        Offset(size.width * 0.55, y + size.height * 0.08),
        linePaint,
      );
    }
    canvas.restore();
  }

  void _drawPixelStripes(
    Canvas canvas,
    Size size,
    Path playerPath,
    Path bossPath,
    double reveal,
  ) {
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.05);
    canvas.save();
    canvas.clipPath(playerPath);
    for (var x = 0.0; x < size.width; x += 12) {
      if (x.toInt() % 24 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, size.height * (1 - reveal), 6, size.height),
          stripe,
        );
      }
    }
    canvas.restore();

    canvas.save();
    canvas.clipPath(bossPath);
    for (var y = 0.0; y < size.height; y += 10) {
      if (y.toInt() % 20 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(size.width * (1 - reveal), y, size.width, 4),
          stripe,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IntroSplitBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.flicker != flicker ||
        oldDelegate.retroPixel != retroPixel;
  }
}

class _ElectricDiagonalPainter extends CustomPainter {
  _ElectricDiagonalPainter({
    required this.progress,
    required this.flicker,
    required this.arcs,
    required this.time,
    required this.retroPixel,
  });

  final double progress;
  final double flicker;
  final List<_LightningArc> arcs;
  final double time;
  final bool retroPixel;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || progress <= 0) return;

    final start = Offset.zero;
    final end = Offset(size.width, size.height);
    final dir = end - start;
    final length = dir.distance;
    if (length <= 0) return;
    final unit = dir / length;
    final normal = Offset(-unit.dy, unit.dx);

    final visibleEnd = Offset(
      start.dx + dir.dx * progress,
      start.dy + dir.dy * progress,
    );

    final glowPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFFFFF59D),
        const Color(0xFF81D4FA),
        flicker * 0.6,
      )!
          .withValues(alpha: 0.35 * flicker)
      ..strokeWidth = retroPixel ? 14 : 18
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 + flicker * 0.15)
      ..strokeWidth = retroPixel ? 4 : 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, visibleEnd, glowPaint);
    canvas.drawLine(start, visibleEnd, corePaint);

    for (final arc in arcs) {
      if (arc.startT > progress) continue;
      final arcEndT = min(arc.endT, progress);
      _drawArc(
        canvas,
        start: start,
        unit: unit,
        normal: normal,
        length: length,
        startT: arc.startT,
        endT: arcEndT,
        jitterSeed: arc.jitterSeed + time * 12,
        thickness: arc.thickness,
        flicker: flicker,
        retroPixel: retroPixel,
      );
    }
  }

  void _drawArc(
    Canvas canvas, {
    required Offset start,
    required Offset unit,
    required Offset normal,
    required double length,
    required double startT,
    required double endT,
    required double jitterSeed,
    required double thickness,
    required double flicker,
    required bool retroPixel,
  }) {
    final segments = retroPixel ? 4 : 6;
    final path = Path();
    final startPoint = start + unit * (length * startT);
    path.moveTo(startPoint.dx, startPoint.dy);

    for (var i = 1; i <= segments; i++) {
      final t = ui.lerpDouble(startT, endT, i / segments)!;
      final base = start + unit * (length * t);
      final wave = sin(jitterSeed + i * 1.7 + time * 24) *
          (8 + thickness * 3) *
          (0.5 + flicker * 0.5);
      final point = base + normal * wave;
      path.lineTo(point.dx, point.dy);
    }

    final arcGlow = Paint()
      ..color = Color.lerp(
        const Color(0xFFFFEB3B),
        const Color(0xFF4FC3F7),
        (sin(jitterSeed) + 1) * 0.25,
      )!
          .withValues(alpha: 0.55 * flicker)
      ..strokeWidth = thickness + 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final arcCore = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, arcGlow);
    canvas.drawPath(path, arcCore);
  }

  @override
  bool shouldRepaint(covariant _ElectricDiagonalPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.flicker != flicker ||
        oldDelegate.time != time ||
        oldDelegate.retroPixel != retroPixel;
  }
}
