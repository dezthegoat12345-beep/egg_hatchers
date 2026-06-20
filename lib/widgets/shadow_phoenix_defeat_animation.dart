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
  static const _descentStartMs = 4500.0;
  static const _falterStartMs = 6500.0;
  static const _topViewStartMs = 6500.0;
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
    _feathers = _DarkFeather.generate(44);
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

  _WingFlapSnapshot _wingFlap(
    double t,
    double unevenFlap,
    double falterPhase,
    double topViewPhase,
    double fallProgress,
  ) {
    if (t >= _impactMs) {
      return const _WingFlapSnapshot();
    }

    const minRad = -18 * math.pi / 180;
    const maxRad = 22 * math.pi / 180;
    final shoulderX = _baseSpriteSize * 0.30;
    const shoulderY = -_baseSpriteSize * 0.06;
    final wingW = _baseSpriteSize * 0.44;
    final wingH = _baseSpriteSize * 0.52;

    // Establish shot: wings spread, no flapping yet.
    if (t < _flapStartMs) {
      const spread = 0.22;
      return _WingFlapSnapshot(
        leftAngle: spread,
        rightAngle: -spread,
        leftTip: _wingTip(-shoulderX, shoulderY, spread, wingW, wingH, isLeft: true),
        rightTip: _wingTip(shoulderX, shoulderY, -spread, wingW, wingH, isLeft: false),
        isFlapping: false,
      );
    }

    // Fall phase: wings trail/fold — no strong flapping.
    if (t >= _fallStartMs) {
      final trail = _phase(_fallStartMs, _impactMs);
      const spread = 0.62;
      final leftAngle = spread + trail * 0.15;
      final rightAngle = -spread - trail * 0.15;
      return _WingFlapSnapshot(
        leftAngle: leftAngle,
        rightAngle: rightAngle,
        leftTip: _wingTip(-shoulderX, shoulderY, leftAngle, wingW, wingH, isLeft: true),
        rightTip: _wingTip(shoulderX, shoulderY, rightAngle, wingW, wingH, isLeft: false),
        featherIntensity: (0.15 * (1 - trail)).clamp(0.0, 0.2),
        isFlapping: false,
      );
    }

    final flapSpeed = 130.0 + unevenFlap * 40;
    final cycle = t / flapSpeed * math.pi;
    final sinVal = math.sin(cycle);
    final normalized = (sinVal + 1) / 2;
    final downstroke = sinVal < 0;

    var amplitude =
        (1.0 - unevenFlap * 0.22 - falterPhase * 0.55).clamp(0.15, 1.0);
    final irregular =
        unevenFlap > 0 ? math.sin(t / 62 * math.pi) * unevenFlap * 0.12 : 0.0;

    double leftAngle;
    double rightAngle;

    if (falterPhase > 0.15) {
      final falter = falterPhase.clamp(0.0, 1.0);
      final spread = 0.28 + falter * 0.48;
      final twitch = sinVal * 0.05 * (1 - falter);
      leftAngle = spread + twitch;
      rightAngle = -spread - twitch;
      amplitude *= 1 - falter * 0.75;
    } else {
      final base = minRad + normalized * (maxRad - minRad);
      leftAngle = (base + irregular) * amplitude;
      rightAngle = (-base + irregular * 0.65) * amplitude;
    }

    final bodyBobY =
        math.sin(cycle + math.pi / 2) * (5 + unevenFlap * 5) * amplitude;
    final bodyTilt =
        math.sin(cycle) * (3 + unevenFlap * 2) * math.pi / 180 * amplitude;

    final leftTip = _wingTip(-shoulderX, shoulderY, leftAngle, wingW, wingH, isLeft: true);
    final rightTip = _wingTip(shoulderX, shoulderY, rightAngle, wingW, wingH, isLeft: false);

    final featherIntensity =
        (0.4 + unevenFlap * 0.45 + (downstroke ? 0.28 : 0.06)).clamp(0.0, 1.0);

    return _WingFlapSnapshot(
      leftAngle: leftAngle,
      rightAngle: rightAngle,
      bodyBobY: bodyBobY,
      bodyTilt: bodyTilt,
      leftTip: leftTip,
      rightTip: rightTip,
      featherIntensity: featherIntensity,
      downstroke: downstroke,
      isFlapping: true,
    );
  }

  Offset _wingTip(
    double shoulderX,
    double shoulderY,
    double angle,
    double wingW,
    double wingH, {
    required bool isLeft,
  }) {
    final frac = _PhoenixWingShapePainter.tipFraction(isLeft: isLeft);
    final tipLocal = Offset(frac.dx * wingW, frac.dy * wingH);
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return Offset(
      shoulderX + tipLocal.dx * cos - tipLocal.dy * sin,
      shoulderY + tipLocal.dx * sin + tipLocal.dy * cos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 1000));
        final zoomScale = 0.88 + zoomPhase * 0.48;
        final darken = (0.26 + zoomPhase * 0.28).clamp(0.0, 0.58);

        final unevenFlap = _phase(_descentStartMs, _falterStartMs);
        final falterPhase = _phase(_falterStartMs, _fallStartMs);
        final descentAmount =
            Curves.easeIn.transform(_phase(_descentStartMs, _fallStartMs));
        final topViewPhase =
            Curves.easeInOut.transform(_phase(_topViewStartMs, _fallStartMs));
        final fallProgress = Curves.easeIn.transform(_phase(_fallStartMs, _impactMs));
        final smokeExpand = t >= _impactMs
            ? Curves.easeOut.transform(_phase(_impactMs, _smokeEndMs))
            : 0.0;
        final shockwave = t >= _impactMs
            ? Curves.easeOut.transform(_phase(_impactMs, _impactMs + 900))
            : 0.0;

        final flap = _wingFlap(t, unevenFlap, falterPhase, topViewPhase, fallProgress);

        final wobbleX = t >= _flapStartMs && t < _fallStartMs
            ? math.sin(t / 55 * math.pi) * (4 + unevenFlap * 8)
            : 0.0;

        final bossScale = zoomScale * _sizeBoost;
        final perspectiveRotate =
            -topViewPhase * math.pi * 0.48 - fallProgress * 0.15;
        final flattenY = 1.0 - topViewPhase * 0.42;
        final flattenX = 1.0 + topViewPhase * 0.18;
        final fallShrink = 1 - fallProgress * 0.35;
        final bodyScaleX = bossScale * flattenX * fallShrink;
        final bodyScaleY = bossScale * flattenY * fallShrink;
        final showBoss = t < _impactMs + 80;
        final bossOpacity = t < _impactMs
            ? 1.0
            : (1 - _phase(_impactMs, _impactMs + 200)).clamp(0.0, 1.0);

        final flyY = -descentAmount * 28 - topViewPhase * 18;
        final fallY = fallProgress * 120;
        final bossOffsetY = flyY + fallY + topViewPhase * 30 +
            (t < _fallStartMs ? flap.bodyBobY : 0);
        final bossOffsetX = wobbleX * (1 - topViewPhase * 0.5);

        final featherTravel = t >= _flapStartMs && t < _impactMs
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
                if (featherTravel > 0)
                  CustomPaint(
                    painter: _FallingFeathersPainter(
                      feathers: _feathers,
                      travel: featherTravel,
                      bossOffset: Offset(bossOffsetX, bossOffsetY),
                      leftTip: flap.leftTip,
                      rightTip: flap.rightTip,
                      tipScaleX: bodyScaleX,
                      tipScaleY: bodyScaleY,
                      featherIntensity: flap.featherIntensity,
                      isFlapping: flap.isFlapping,
                      fallProgress: fallProgress,
                      fade: effectFade,
                    ),
                  ),
                if (showBoss && bossOpacity > 0)
                  Transform.translate(
                    offset: Offset(bossOffsetX, bossOffsetY),
                    child: Transform.rotate(
                      angle: perspectiveRotate,
                      child: Transform.scale(
                        scaleX: bodyScaleX,
                        scaleY: bodyScaleY,
                        child: Transform.rotate(
                          angle: flap.bodyTilt,
                          child: Opacity(
                            opacity: bossOpacity,
                            child: _PhoenixFlappingBody(
                              boss: widget.boss,
                              spriteSize: _baseSpriteSize,
                              flap: flap,
                              falterPhase: falterPhase,
                              showGlow: t >= _flapStartMs && t < _impactMs,
                            ),
                          ),
                        ),
                      ),
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

class _WingFlapSnapshot {
  const _WingFlapSnapshot({
    this.leftAngle = 0,
    this.rightAngle = 0,
    this.bodyBobY = 0,
    this.bodyTilt = 0,
    this.leftTip = Offset.zero,
    this.rightTip = Offset.zero,
    this.featherIntensity = 0,
    this.downstroke = false,
    this.isFlapping = false,
  });

  final double leftAngle;
  final double rightAngle;
  final double bodyBobY;
  final double bodyTilt;
  final Offset leftTip;
  final Offset rightTip;
  final double featherIntensity;
  final bool downstroke;
  final bool isFlapping;
}

class _PhoenixFlappingBody extends StatelessWidget {
  const _PhoenixFlappingBody({
    required this.boss,
    required this.spriteSize,
    required this.flap,
    required this.falterPhase,
    required this.showGlow,
  });

  final BossBattleDefinition boss;
  final double spriteSize;
  final _WingFlapSnapshot flap;
  final double falterPhase;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final wingW = spriteSize * 0.44;
    final wingH = spriteSize * 0.52;
    final shoulderX = spriteSize * 0.30;
    final shoulderY = -spriteSize * 0.06;

    return SizedBox(
      width: spriteSize,
      height: spriteSize * 1.08,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: spriteSize * 0.72,
              height: spriteSize * 0.72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7E57C2).withValues(alpha: 0.32),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          // Left wing — pivot at shoulder, attached to body side.
          Transform.translate(
            offset: Offset(-shoulderX, shoulderY),
            child: Transform.rotate(
              angle: flap.leftAngle,
              alignment: Alignment.topRight,
              child: CustomPaint(
                size: Size(wingW, wingH),
                painter: _PhoenixWingShapePainter(
                  isLeft: true,
                  falter: falterPhase > 0.2,
                ),
              ),
            ),
          ),
          // Right wing — mirrored shoulder pivot.
          Transform.translate(
            offset: Offset(shoulderX, shoulderY),
            child: Transform.rotate(
              angle: flap.rightAngle,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: Size(wingW, wingH),
                painter: _PhoenixWingShapePainter(
                  isLeft: false,
                  falter: falterPhase > 0.2,
                ),
              ),
            ),
          ),
          // Body sprite clipped to head/torso/tail — static wing pixels excluded.
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              ClipPath(
                clipper: _PhoenixCinematicBodyClipper(),
                child: BossSprite(
                  spritePath: boss.spritePath,
                  fallbackEmoji: boss.emoji,
                  size: spriteSize,
                  semanticLabel: boss.name,
                ),
              ),
              CustomPaint(
                size: Size(spriteSize, spriteSize),
                painter: _ShoulderSeamCoverPainter(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Clips the boss PNG to head, torso, and tail — excludes baked-in side wings.
class _PhoenixCinematicBodyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    return Path()
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.365),
        width: w * 0.40,
        height: h * 0.28,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.60),
        width: w * 0.46,
        height: h * 0.52,
      ))
      ..addOval(Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.805),
        width: w * 0.36,
        height: h * 0.30,
      ))
      ..addRect(Rect.fromLTWH(w * 0.40, h * 0.40, w * 0.20, h * 0.14));
  }

  @override
  bool shouldReclip(covariant _PhoenixCinematicBodyClipper oldClipper) => false;
}

/// Tiny shoulder patches — covers wing-root seams only, not the body center.
class _ShoulderSeamCoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final cx in [w * 0.36, w * 0.64]) {
      final rect = Rect.fromCenter(
        center: Offset(cx, h * 0.38),
        width: w * 0.14,
        height: h * 0.10,
      );
      canvas.drawOval(
        rect,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0xFF2A2A3C), Color(0xFF1E1E30)],
          ).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShoulderSeamCoverPainter oldDelegate) => false;
}

class _PhoenixWingShapePainter extends CustomPainter {
  _PhoenixWingShapePainter({required this.isLeft, required this.falter});

  final bool isLeft;
  final bool falter;

  /// Primary wing-tip fraction from shoulder pivot (wing-local space).
  static Offset tipFraction({required bool isLeft}) =>
      Offset(isLeft ? -0.93 : 0.93, 0.30);

  Path _wingPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();

    if (isLeft) {
      // Shoulder pivot at top-right.
      final sx = w;
      final sy = h * 0.10;
      path.moveTo(sx, sy);
      // Leading edge — curves up and outward to primary tip.
      path.quadraticBezierTo(w * 0.70, h * 0.01, w * 0.34, h * 0.05);
      path.quadraticBezierTo(w * 0.06, h * 0.14, w * 0.01, h * 0.30);
      path.quadraticBezierTo(w * 0.02, h * 0.44, w * 0.04, h * 0.56);
      // Trailing feather notches back toward shoulder.
      path.lineTo(w * 0.14, h * 0.68);
      path.lineTo(w * 0.28, h * 0.80);
      path.lineTo(w * 0.46, h * 0.90);
      path.lineTo(w * 0.64, h * 0.84);
      path.lineTo(w * 0.80, h * 0.68);
      path.lineTo(w * 0.92, h * 0.48);
      path.quadraticBezierTo(w * 0.98, h * 0.28, sx, sy);
      path.close();
    } else {
      // Shoulder pivot at top-left — mirrored.
      final sx = 0.0;
      final sy = h * 0.10;
      path.moveTo(sx, sy);
      path.quadraticBezierTo(w * 0.30, h * 0.01, w * 0.66, h * 0.05);
      path.quadraticBezierTo(w * 0.94, h * 0.14, w * 0.99, h * 0.30);
      path.quadraticBezierTo(w * 0.98, h * 0.44, w * 0.96, h * 0.56);
      path.lineTo(w * 0.86, h * 0.68);
      path.lineTo(w * 0.72, h * 0.80);
      path.lineTo(w * 0.54, h * 0.90);
      path.lineTo(w * 0.36, h * 0.84);
      path.lineTo(w * 0.20, h * 0.68);
      path.lineTo(w * 0.08, h * 0.48);
      path.quadraticBezierTo(w * 0.02, h * 0.28, sx, sy);
      path.close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _wingPath(size);
    final bounds = path.getBounds().inflate(6);
    final w = size.width;
    final h = size.height;

    // Soft blue glow behind wing silhouette.
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1565C0).withValues(alpha: falter ? 0.08 : 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          colors: falter
              ? [
                  const Color(0xFF1A237E),
                  const Color(0xFF311B92),
                  const Color(0xFF0D0D1A),
                ]
              : [
                  const Color(0xFF0D0D1A),
                  const Color(0xFF311B92),
                  const Color(0xFF1565C0),
                  const Color(0xFF4527A0),
                ],
          stops: falter ? const [0.0, 0.5, 1.0] : const [0.0, 0.25, 0.65, 1.0],
        ).createShader(bounds),
    );

    // Blue edge highlight along leading edge.
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF64B5F6).withValues(alpha: falter ? 0.22 : 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Individual feather filaments on trailing edge.
    final feather = Paint()
      ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final primaries = isLeft
        ? [
            (Offset(w * 0.04, h * 0.56), Offset(w * 0.28, h * 0.80)),
            (Offset(w * 0.14, h * 0.68), Offset(w * 0.46, h * 0.90)),
            (Offset(w * 0.28, h * 0.80), Offset(w * 0.64, h * 0.84)),
            (Offset(w * 0.46, h * 0.90), Offset(w * 0.80, h * 0.68)),
            (Offset(w * 0.64, h * 0.84), Offset(w * 0.92, h * 0.48)),
          ]
        : [
            (Offset(w * 0.96, h * 0.56), Offset(w * 0.72, h * 0.80)),
            (Offset(w * 0.86, h * 0.68), Offset(w * 0.54, h * 0.90)),
            (Offset(w * 0.72, h * 0.80), Offset(w * 0.36, h * 0.84)),
            (Offset(w * 0.54, h * 0.90), Offset(w * 0.20, h * 0.68)),
            (Offset(w * 0.36, h * 0.84), Offset(w * 0.08, h * 0.48)),
          ];
    for (final (from, to) in primaries) {
      canvas.drawLine(from, to, feather);
      canvas.drawCircle(
        to,
        1.2,
        Paint()..color = const Color(0xFF90CAF9).withValues(alpha: 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PhoenixWingShapePainter oldDelegate) =>
      oldDelegate.falter != falter;
}

class _DarkFeather {
  _DarkFeather({
    required this.wingSide,
    required this.tipOffset,
    required this.drift,
    required this.size,
    required this.rotation,
    required this.delay,
  });

  final int wingSide;
  final double tipOffset;
  final double drift;
  final double size;
  final double rotation;
  final double delay;

  static List<_DarkFeather> generate(int count) {
    final random = math.Random(77);
    return List.generate(count, (i) {
      return _DarkFeather(
        wingSide: i.isEven ? -1 : 1,
        tipOffset: random.nextDouble() * 14,
        drift: random.nextDouble() * math.pi * 2,
        size: 7 + random.nextDouble() * 12,
        rotation: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.38,
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
    required this.leftTip,
    required this.rightTip,
    required this.tipScaleX,
    required this.tipScaleY,
    required this.featherIntensity,
    required this.isFlapping,
    required this.fallProgress,
    required this.fade,
  });

  final List<_DarkFeather> feathers;
  final double travel;
  final Offset bossOffset;
  final Offset leftTip;
  final Offset rightTip;
  final double tipScaleX;
  final double tipScaleY;
  final double featherIntensity;
  final bool isFlapping;
  final double fallProgress;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (travel <= 0 || featherIntensity <= 0.02) return;
    final bodyCenter = Offset(size.width / 2, size.height * 0.46) + bossOffset;
    final maxDim = math.max(size.width, size.height);
    final intensity = isFlapping ? featherIntensity : featherIntensity * 0.5;

    for (final f in feathers) {
      final localT = ((travel - f.delay) / (1 - f.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      if (!isFlapping && f.delay < 0.15) continue;

      final tip = f.wingSide < 0 ? leftTip : rightTip;
      final spawn = bodyCenter +
          Offset(tip.dx * tipScaleX, tip.dy * tipScaleY) +
          Offset(f.wingSide * f.tipOffset * 0.25, f.tipOffset * 0.15);

      final eased = Curves.easeOut.transform(localT);
      final driftX = math.sin(f.drift + eased * math.pi * 3) * 22;
      final fallDist = eased * maxDim * (0.06 + fallProgress * 0.12);
      final pos = spawn +
          Offset(
            driftX + f.wingSide * eased * 28,
            fallDist + eased * eased * maxDim * 0.18,
          );

      final alpha = (fade * intensity * (1 - localT * 0.35)).clamp(0.0, 1.0);
      if (alpha <= 0.05) continue;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.rotation + eased * math.pi * 2.2);
      final path = Path()
        ..moveTo(0, -f.size * 0.5)
        ..quadraticBezierTo(f.size * 0.32, 0, 0, f.size * 0.5)
        ..quadraticBezierTo(-f.size * 0.32, 0, 0, -f.size * 0.5);
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFF311B92).withValues(alpha: alpha * 0.92),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFCE93D8).withValues(alpha: alpha * 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FallingFeathersPainter oldDelegate) =>
      oldDelegate.travel != travel ||
      oldDelegate.bossOffset != bossOffset ||
      oldDelegate.leftTip != leftTip ||
      oldDelegate.rightTip != rightTip ||
      oldDelegate.tipScaleX != tipScaleX ||
      oldDelegate.tipScaleY != tipScaleY ||
      oldDelegate.featherIntensity != featherIntensity ||
      oldDelegate.isFlapping != isFlapping ||
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

    // Dark impact shadow on sand
    canvas.drawOval(
      Rect.fromCenter(
        center: impact,
        width: 36 + expand * 48,
        height: 14 + expand * 16,
      ),
      Paint()..color = Colors.black.withValues(alpha: fade * expand * 0.35),
    );

    if (shockwave > 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: impact,
          width: 40 + shockwave * maxDim * 0.45,
          height: 16 + shockwave * maxDim * 0.12,
        ),
        Paint()
          ..color = const Color(0xFF4A148C).withValues(alpha: fade * shockwave * 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: impact,
          width: 34 + shockwave * maxDim * 0.38,
          height: 12 + shockwave * maxDim * 0.1,
        ),
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: fade * shockwave * 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5,
      );
    }

    final core = Paint()..color = const Color(0xFF7E57C2).withValues(alpha: fade * expand * 0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: impact - Offset(0, expand * 42),
        width: 52 + expand * maxDim * 0.38,
        height: 32 + expand * maxDim * 0.22,
      ),
      core,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: impact - Offset(0, expand * 42),
        width: 52 + expand * maxDim * 0.38,
        height: 32 + expand * maxDim * 0.22,
      ),
      Paint()
        ..color = const Color(0xFF311B92).withValues(alpha: fade * expand * 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    for (final p in puffs) {
      final localT = ((expand - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final dist = p.distance * maxDim * localT;
      final pos = impact +
          Offset(
            math.cos(p.angle) * dist * 0.6,
            math.sin(p.angle) * dist - localT * 58,
          );
      final alpha = (fade * localT * (1 - localT * 0.45) * 0.65).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: p.size * (0.75 + localT),
          height: p.size * (0.5 + localT * 0.55),
        ),
        Paint()..color = const Color(0xFF6A1B9A).withValues(alpha: alpha),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: p.size * (0.75 + localT),
          height: p.size * (0.5 + localT * 0.55),
        ),
        Paint()
          ..color = const Color(0xFFCE93D8).withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ShadowSmokePainter oldDelegate) =>
      oldDelegate.expand != expand ||
      oldDelegate.shockwave != shockwave ||
      oldDelegate.fade != fade;
}
