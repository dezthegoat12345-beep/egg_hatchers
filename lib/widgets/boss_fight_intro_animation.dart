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

  static const entranceDuration = Duration(milliseconds: 3000);

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

class _IntroPanelLayout {
  const _IntroPanelLayout._();

  static Offset playerCenter(Size size, double spriteSize) {
    final pad = spriteSize * 0.55 + 12;
    return Offset(
      (size.width * 0.33).clamp(pad, size.width * 0.42),
      (size.height * 0.70).clamp(size.height * 0.58, size.height - pad - 48),
    );
  }

  static Offset bossCenter(Size size, double spriteSize) {
    final pad = spriteSize * 0.55 + 12;
    return Offset(
      (size.width * 0.67).clamp(size.width * 0.58, size.width - pad),
      (size.height * 0.30).clamp(pad + 8, size.height * 0.42),
    );
  }
}

class _BossFightIntroAnimationState extends State<BossFightIntroAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _idleController;
  late final AnimationController _promptFadeController;
  late final List<_LightningArc> _arcs;
  var _didComplete = false;
  var _readyToStart = false;
  var _slashSfxPlayed = false;
  var _vsSfxPlayed = false;

  @override
  void initState() {
    super.initState();
    _arcs = _generateArcs(Random(1337), 9);
    _entranceController = AnimationController(
      vsync: this,
      duration: BossFightIntroAnimation.entranceDuration,
    )..addListener(_onEntranceTick);

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _promptFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _entranceController.addStatusListener((status) {
      if (status != AnimationStatus.completed || !mounted) return;
      setState(() => _readyToStart = true);
      _idleController.repeat(reverse: true);
      _promptFadeController.forward();
    });

    _entranceController.forward();
  }

  void _onEntranceTick() {
    final t = _entranceController.value;
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
    if (_didComplete) return;
    _didComplete = true;
    _entranceController.stop();
    _idleController.stop();
    _promptFadeController.stop();
    widget.onComplete();
  }

  void _onTap() {
    if (!_readyToStart) return;
    widget.audio?.playSfx(Sfx.buttonTap);
    _finishOnce();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _idleController.dispose();
    _promptFadeController.dispose();
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
        onTap: _onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final playerSpriteSize = min(size.width * 0.26, 92.0);
            final bossSpriteSize = min(size.width * 0.28, 100.0);

            return AnimatedBuilder(
              animation: Listenable.merge([
                _entranceController,
                _idleController,
                _promptFadeController,
              ]),
              builder: (context, _) {
                final entranceT = retroPixel
                    ? _pixelStep(_entranceController.value, 24)
                    : _entranceController.value;
                final idleT = _idleController.value;
                final entranceDone = _entranceController.isCompleted;

                final lineT = _segment(entranceT, 0, 0.133, Curves.easeOut);
                final slideT = _segment(entranceT, 0.133, 0.4, Curves.easeOutCubic);
                final nameT = _segment(entranceT, 0.25, 0.45, Curves.easeOut);
                final vsPulseT = _segment(entranceT, 0.35, 0.55, Curves.elasticOut);

                final animTime = entranceDone
                    ? 0.733 + idleT * 0.5
                    : entranceT.clamp(0.0, 0.733);
                final flicker = 0.65 +
                    0.35 * sin(animTime * pi * 18 + idleT * 40).abs();
                final lightingPulse = 0.82 + 0.18 * sin(idleT * pi * 2);

                final playerTarget =
                    _IntroPanelLayout.playerCenter(size, playerSpriteSize);
                final bossTarget =
                    _IntroPanelLayout.bossCenter(size, bossSpriteSize);

                final playerSlide = Offset(
                  ui.lerpDouble(-size.width * 0.35, playerTarget.dx, slideT)!,
                  ui.lerpDouble(size.height * 0.18, playerTarget.dy, slideT)!,
                );
                final bossSlide = Offset(
                  ui.lerpDouble(size.width * 1.1, bossTarget.dx, slideT)!,
                  ui.lerpDouble(-size.height * 0.12, bossTarget.dy, slideT)!,
                );

                final bounce = entranceDone
                    ? sin(idleT * pi * 2) * 3.5
                    : (entranceT > 0.4 && entranceT < 0.733
                        ? sin((entranceT - 0.4) * pi * 6) * 4
                        : 0.0);

                final vsScale = (0.4 + vsPulseT * 0.65) *
                    (1 +
                        (animTime > 0.35
                            ? sin(animTime * pi * 8 + idleT * pi) * 0.06
                            : 0));

                final promptOpacity = _promptFadeController.value;

                return Stack(
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
                      painter: _PanelLightingPainter(
                        playerCenter: playerSlide + Offset(0, bounce),
                        bossCenter: bossSlide + Offset(0, -bounce * 0.5),
                        playerRadius: playerSpriteSize * 1.35,
                        bossRadius: bossSpriteSize * 1.4,
                        pulse: lightingPulse,
                        reveal: max(lineT, slideT),
                      ),
                      size: size,
                    ),
                    _CenteredFighterSide(
                      center: playerSlide + Offset(0, bounce),
                      spriteSize: playerSpriteSize,
                      name: widget.fighterName,
                      nameOpacity: nameT,
                      promptOpacity: promptOpacity,
                      showPrompt: _readyToStart,
                      child: GameSprite(
                        customSprite: widget.fighterCustomSprite,
                        animalId: widget.fighterAnimalId,
                        spritePath: widget.fighterSpritePath,
                        fallbackEmoji: widget.fighterEmoji,
                        size: playerSpriteSize,
                        semanticLabel: widget.fighterName,
                      ),
                    ),
                    _CenteredFighterSide(
                      center: bossSlide + Offset(0, -bounce * 0.5),
                      spriteSize: bossSpriteSize,
                      name: widget.boss.name,
                      subtitle: modeLabel,
                      nameOpacity: nameT,
                      child: BossSprite(
                        bossId: widget.boss.id,
                        spritePath: widget.boss.spritePath,
                        fallbackEmoji: widget.boss.emoji,
                        size: bossSpriteSize,
                        semanticLabel: widget.boss.name,
                      ),
                    ),
                    CustomPaint(
                      painter: _ElectricDiagonalPainter(
                        progress: lineT,
                        flicker: flicker,
                        arcs: _arcs,
                        time: animTime,
                        retroPixel: retroPixel,
                      ),
                      size: size,
                    ),
                    Center(
                      child: Transform.scale(
                        scale: vsScale,
                        child: Opacity(
                          opacity:
                              (lineT * 0.35 + vsPulseT * 0.65).clamp(0, 1),
                          child: _VsLabel(
                            flicker: flicker,
                            retroPixel: retroPixel,
                          ),
                        ),
                      ),
                    ),
                  ],
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

class _CenteredFighterSide extends StatelessWidget {
  const _CenteredFighterSide({
    required this.center,
    required this.spriteSize,
    required this.name,
    required this.nameOpacity,
    required this.child,
    this.subtitle,
    this.promptOpacity = 0,
    this.showPrompt = false,
  });

  final Offset center;
  final double spriteSize;
  final String name;
  final String? subtitle;
  final double nameOpacity;
  final double promptOpacity;
  final bool showPrompt;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final labelWidth = spriteSize * 2.6;
    return Positioned(
      left: center.dx - labelWidth / 2,
      top: center.dy - spriteSize / 2,
      width: labelWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: spriteSize,
            height: spriteSize,
            child: Center(child: child),
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: nameOpacity.clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, (1 - nameOpacity) * 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
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
                      textAlign: TextAlign.center,
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
                  if (showPrompt) ...[
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: promptOpacity.clamp(0, 1),
                      child: Transform.translate(
                        offset: Offset(0, (1 - promptOpacity) * 8),
                        child: Text(
                          'Click to start',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.6,
                            shadows: const [
                              Shadow(color: Colors.black87, blurRadius: 5),
                            ],
                          ),
                        ),
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

class _PanelLightingPainter extends CustomPainter {
  _PanelLightingPainter({
    required this.playerCenter,
    required this.bossCenter,
    required this.playerRadius,
    required this.bossRadius,
    required this.pulse,
    required this.reveal,
  });

  final Offset playerCenter;
  final Offset bossCenter;
  final double playerRadius;
  final double bossRadius;
  final double pulse;
  final double reveal;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || reveal <= 0) return;

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

    canvas.save();
    canvas.clipPath(playerPath);
    _drawSpotlight(
      canvas,
      center: playerCenter,
      radius: playerRadius * pulse,
      inner: const Color(0xFFFF6D00).withValues(alpha: 0.55 * reveal),
      outer: const Color(0xFFBF360C).withValues(alpha: 0.08 * reveal),
    );
    canvas.restore();

    canvas.save();
    canvas.clipPath(bossPath);
    _drawSpotlight(
      canvas,
      center: bossCenter,
      radius: bossRadius * pulse,
      inner: const Color(0xFF1565C0).withValues(alpha: 0.62 * reveal),
      outer: const Color(0xFF0D47A1).withValues(alpha: 0.06 * reveal),
    );
    canvas.restore();
  }

  void _drawSpotlight(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color inner,
    required Color outer,
  }) {
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [inner, outer, Colors.transparent],
        [0, 0.55, 1],
      );
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _PanelLightingPainter oldDelegate) {
    return oldDelegate.playerCenter != playerCenter ||
        oldDelegate.bossCenter != bossCenter ||
        oldDelegate.pulse != pulse ||
        oldDelegate.reveal != reveal;
  }
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
