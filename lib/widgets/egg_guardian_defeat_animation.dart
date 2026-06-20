import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../models/boss_battle.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';
import 'egg_guardian_nest_background.dart';

/// Cinematic Egg Guardian defeat celebration for manual battle victories.
class EggGuardianDefeatAnimation extends StatefulWidget {
  const EggGuardianDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.onComplete,
  });

  static const duration = Duration(milliseconds: 11500);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final VoidCallback onComplete;

  @override
  State<EggGuardianDefeatAnimation> createState() =>
      _EggGuardianDefeatAnimationState();
}

class _EggGuardianDefeatAnimationState extends State<EggGuardianDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 11500.0;
  static const _skipAfterMs = 1000.0;
  static const _armorBreakMs = 6000.0;
  static const _explosionStartMs = 8500.0;
  static const _burstEndMs = 9500.0;
  static const _baseSpriteSize = 168.0;
  static const _sizeBoost = 1.4;

  late final AnimationController _controller;
  late final List<_ShellFragment> _fragments;
  late final List<_ArmorPlate> _plates;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _fragments = _ShellFragment.generate(32);
    _plates = _ArmorPlate.generate(6);
    _controller = AnimationController(
      vsync: this,
      duration: EggGuardianDefeatAnimation.duration,
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
        final darken = (0.28 + zoomPhase * 0.32).clamp(0.0, 0.62);

        final ominousPhase = _phase(1000, 3000);
        final crackSpread = Curves.easeIn.transform(_phase(1000, _armorBreakMs));
        final shatterBuild = _phase(_armorBreakMs, _explosionStartMs);
        final burstPhase = Curves.easeIn.transform(_phase(_explosionStartMs, _burstEndMs));

        final shakeAmp = 3 + ominousPhase * 6 + crackSpread * 12 + shatterBuild * 16;
        final shakeX = t >= 1000 && t < _burstEndMs
            ? math.sin(t / 50 * math.pi) * shakeAmp
            : 0.0;
        final shakeY = t >= 1000 && t < _burstEndMs
            ? math.cos(t / 58 * math.pi) * shakeAmp * 0.5
            : 0.0;

        final bossScale = zoomScale * _sizeBoost;
        final showBoss = t < _explosionStartMs;
        final glowPulse = t >= 1000 && t < _explosionStartMs
            ? (0.35 + math.sin(t / 75 * math.pi) * 0.3) * crackSpread
            : 0.0;

        final runeRing = t >= 1000
            ? (0.3 + math.sin(t / 90 * math.pi) * 0.25) * crackSpread
            : 0.0;
        final energyLeak = _phase(3000, _explosionStartMs);

        final plateBreakLeft = Curves.easeIn.transform(_phase(_armorBreakMs, _armorBreakMs + 900));
        final plateBreakRight = Curves.easeIn.transform(_phase(_armorBreakMs + 150, _armorBreakMs + 1050));

        final fragmentTravel = t >= 3000
            ? Curves.easeOutCubic.transform(_phase(3000, _burstEndMs + 800))
            : 0.0;
        final shockwave = t >= _explosionStartMs
            ? Curves.easeOut.transform(_phase(_explosionStartMs, _burstEndMs + 400))
            : 0.0;

        final burstFlash = t >= _explosionStartMs
            ? (1 - _phase(_explosionStartMs, _explosionStartMs + 400)).clamp(0.0, 1.0)
            : 0.0;
        final effectFade = (1 - _phase(9800, 11200)).clamp(0.0, 1.0);

        final titleProgress = Curves.elasticOut.transform(_phase(9800, 10400));
        final titleOpacity = Curves.easeOut.transform(_phase(9800, 10200));
        final rewardsOpacity = Curves.easeOut.transform(_phase(10200, 11200));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        return Material(
          color: Colors.black.withValues(alpha: 0.82),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t >= _skipAfterMs && !_completed ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const EggGuardianNestBackground(),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (runeRing > 0)
                  CustomPaint(
                    painter: _GuardianRuneRingPainter(
                      intensity: runeRing,
                      shockwave: shockwave,
                      fade: effectFade,
                    ),
                  ),
                if (showBoss)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: Transform.scale(
                      scale: bossScale,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          if (glowPulse > 0)
                            Container(
                              width: _baseSpriteSize * 1.2,
                              height: _baseSpriteSize * 1.2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF42A5F5)
                                        .withValues(alpha: glowPulse * 0.5),
                                    blurRadius: 36,
                                    spreadRadius: 8,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F)
                                        .withValues(alpha: glowPulse * 0.25),
                                    blurRadius: 24,
                                    spreadRadius: 4,
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
                            size: Size(_baseSpriteSize, _baseSpriteSize * 1.12),
                            painter: _GuardianCrackOverlayPainter(
                              progress: crackSpread,
                              energy: energyLeak,
                            ),
                          ),
                          if (plateBreakLeft > 0.05)
                            Positioned(
                              left: 2,
                              top: _baseSpriteSize * 0.32,
                              child: _ArmorCoverPatch(opacity: plateBreakLeft),
                            ),
                          if (plateBreakRight > 0.05)
                            Positioned(
                              right: 2,
                              top: _baseSpriteSize * 0.32,
                              child: _ArmorCoverPatch(opacity: plateBreakRight),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (burstFlash > 0)
                  ColoredBox(
                    color: const Color(0xFF81D4FA).withValues(alpha: burstFlash * 0.45),
                  ),
                if (burstFlash > 0)
                  ColoredBox(
                    color: const Color(0xFFFFF8E1).withValues(alpha: burstFlash * 0.2),
                  ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: CustomPaint(
                    painter: _GuardianShatterPainter(
                      fragments: _fragments,
                      plates: _plates,
                      fragmentTravel: fragmentTravel,
                      plateBreakLeft: plateBreakLeft,
                      plateBreakRight: plateBreakRight,
                      burst: burstPhase,
                      bossScale: bossScale,
                      fade: effectFade,
                    ),
                  ),
                ),
                if (energyLeak > 0 || burstPhase > 0)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: CustomPaint(
                      painter: _GuardianEnergyBurstPainter(
                        intensity: math.max(energyLeak * 0.6, burstPhase),
                        shockwave: shockwave,
                        fade: effectFade,
                        timeMs: t,
                      ),
                    ),
                  ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'GUARDIAN SHATTERED!',
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

class _ArmorCoverPatch extends StatelessWidget {
  const _ArmorCoverPatch({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Container(
        width: 32,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF455A64).withValues(alpha: 0.9),
              const Color(0xFF263238).withValues(alpha: 0.95),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuardianCrackOverlayPainter extends CustomPainter {
  _GuardianCrackOverlayPainter({required this.progress, required this.energy});

  final double progress;
  final double energy;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height * 0.52;

    final glow = Paint()
      ..color = Color.lerp(
        const Color(0xFF42A5F5),
        const Color(0xFFFFD54F),
        energy * 0.5,
      )!.withValues(alpha: progress * 0.8)
      ..strokeWidth = 2.5 + progress * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final crack = Paint()
      ..color = const Color(0xFFECEFF1).withValues(alpha: 0.9)
      ..strokeWidth = 2 + progress * 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final len = 20 + progress * 38;
      final end = Offset(cx + math.cos(angle) * len, cy + math.sin(angle) * len);
      final mid = Offset.lerp(Offset(cx, cy), end, progress * 0.6)!;
      canvas.drawLine(Offset(cx, cy), mid, crack);
      canvas.drawLine(mid, end, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _GuardianCrackOverlayPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.energy != energy;
}

class _GuardianRuneRingPainter extends CustomPainter {
  _GuardianRuneRingPainter({
    required this.intensity,
    required this.shockwave,
    required this.fade,
  });

  final double intensity;
  final double shockwave;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.72);
    final maxDim = math.max(size.width, size.height);

    final ringPaint = Paint()
      ..color = const Color(0xFF64B5F6).withValues(alpha: intensity * fade * 0.5)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: maxDim * 0.34 * (1 + shockwave * 0.35),
        height: maxDim * 0.06 * (1 + shockwave * 0.35),
      ),
      ringPaint,
    );

    if (shockwave > 0) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: maxDim * (0.2 + shockwave * 0.45),
          height: maxDim * (0.04 + shockwave * 0.08),
        ),
        Paint()
          ..color = const Color(0xFFFFD54F).withValues(alpha: fade * shockwave * 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GuardianRuneRingPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.shockwave != shockwave ||
      oldDelegate.fade != fade;
}

class _ShellFragment {
  _ShellFragment({
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

  static List<_ShellFragment> generate(int count) {
    final random = math.Random(66);
    return List.generate(count, (i) {
      return _ShellFragment(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.14 + random.nextDouble() * 0.48,
        size: 6 + random.nextDouble() * 14,
        rotation: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.28,
      );
    });
  }
}

class _ArmorPlate {
  _ArmorPlate({
    required this.side,
    required this.offsetY,
    required this.width,
    required this.height,
  });

  final int side;
  final double offsetY;
  final double width;
  final double height;

  static List<_ArmorPlate> generate(int count) {
    return [
      _ArmorPlate(side: -1, offsetY: 0.08, width: 30, height: 48),
      _ArmorPlate(side: 1, offsetY: 0.08, width: 30, height: 48),
      _ArmorPlate(side: -1, offsetY: 0.22, width: 22, height: 28),
      _ArmorPlate(side: 1, offsetY: 0.22, width: 22, height: 28),
    ];
  }
}

class _GuardianShatterPainter extends CustomPainter {
  _GuardianShatterPainter({
    required this.fragments,
    required this.plates,
    required this.fragmentTravel,
    required this.plateBreakLeft,
    required this.plateBreakRight,
    required this.burst,
    required this.bossScale,
    required this.fade,
  });

  final List<_ShellFragment> fragments;
  final List<_ArmorPlate> plates;
  final double fragmentTravel;
  final double plateBreakLeft;
  final double plateBreakRight;
  final double burst;
  final double bossScale;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final maxDim = math.max(size.width, size.height);

    for (final plate in plates) {
      final progress = plate.side < 0 ? plateBreakLeft : plateBreakRight;
      if (progress <= 0) continue;
      final eased = Curves.easeIn.transform(progress);
      final fallX = plate.side * eased * 75;
      final fallY = eased * eased * 100 + plate.offsetY * _baseSpriteSize;
      final pos = center + Offset(fallX, fallY - 20);
      final alpha = (fade * (1 - eased * 0.1)).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(plate.side * eased * 1.2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: plate.width,
            height: plate.height,
          ),
          const Radius.circular(5),
        ),
        Paint()..color = const Color(0xFF607D8B).withValues(alpha: alpha * 0.92),
      );
      canvas.restore();
    }

    for (final f in fragments) {
      final localT = ((fragmentTravel - f.delay) / (1 - f.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      final burstBoost = burst * 0.6;
      final dist = f.distance * maxDim * (eased + burstBoost);
      final gravity = eased * eased * maxDim * 0.12;
      final pos = center +
          Offset(
            math.cos(f.angle) * dist,
            math.sin(f.angle) * dist * 0.48 + gravity,
          );
      final alpha = (fade * (1 - localT * 0.15)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.rotation + eased * math.pi);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: f.size, height: f.size * 0.75),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFECEFF1).withValues(alpha: alpha * 0.9),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: f.size, height: f.size * 0.75),
          const Radius.circular(3),
        ),
        Paint()
          ..color = const Color(0xFF42A5F5).withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
      canvas.restore();
    }

    if (burst > 0) {
      final dustAlpha = (fade * burst * 0.35).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + size.height * 0.1),
          width: 90 + burst * maxDim * 0.4,
          height: 36 + burst * maxDim * 0.12,
        ),
        Paint()..color = const Color(0xFF90CAF9).withValues(alpha: dustAlpha),
      );
    }
  }

  static const _baseSpriteSize = 168.0;

  @override
  bool shouldRepaint(covariant _GuardianShatterPainter oldDelegate) =>
      oldDelegate.fragmentTravel != fragmentTravel ||
      oldDelegate.plateBreakLeft != plateBreakLeft ||
      oldDelegate.plateBreakRight != plateBreakRight ||
      oldDelegate.burst != burst ||
      oldDelegate.fade != fade;
}

class _GuardianEnergyBurstPainter extends CustomPainter {
  _GuardianEnergyBurstPainter({
    required this.intensity,
    required this.shockwave,
    required this.fade,
    required this.timeMs,
  });

  final double intensity;
  final double shockwave;
  final double fade;
  final double timeMs;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0 && shockwave <= 0) return;
    final center = Offset(size.width / 2, size.height * 0.5);
    final alpha = (intensity * fade).clamp(0.0, 0.75);

    final glow = Paint()
      ..color = const Color(0xFF42A5F5).withValues(alpha: alpha * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, 40 + intensity * 50, glow);

    final bolts = [
      _energyBolt(center, const Offset(-70, -50), const Offset(-20, 10), 4),
      _energyBolt(center, const Offset(65, -45), const Offset(18, 15), 5),
      _energyBolt(center, const Offset(-30, 70), const Offset(5, 0), 4),
      _energyBolt(center, const Offset(40, 65), const Offset(-8, 5), 4),
    ];

    final outer = Paint()
      ..color = const Color(0xFF0288D1).withValues(alpha: alpha * 0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final core = Paint()
      ..color = const Color(0xFFFFF8E1).withValues(alpha: alpha)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pulse = math.sin(timeMs / 160 * math.pi);
    for (var i = 0; i < bolts.length; i++) {
      if (pulse < 0 && i.isEven) continue;
      canvas.drawPath(bolts[i], outer);
      canvas.drawPath(bolts[i], core);
    }

    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3 + timeMs * 0.015;
      final dist = 35 + intensity * 45;
      canvas.drawCircle(
        center + Offset(math.cos(angle) * dist, math.sin(angle) * dist),
        2 + intensity * 2,
        Paint()..color = const Color(0xFFFFD54F).withValues(alpha: alpha * 0.8),
      );
    }
  }

  Path _energyBolt(Offset start, Offset mid, Offset end, int segments) {
    final path = Path()..moveTo(start.dx, start.dy);
    var current = start;
    for (final target in [mid, end]) {
      for (var i = 1; i <= segments; i++) {
        final t = i / segments;
        final base = Offset.lerp(current, target, t)!;
        final jag = (i.isOdd ? 1 : -1) * (5 + i * 2);
        path.lineTo(base.dx + jag, base.dy + jag * 0.5);
      }
      current = target;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _GuardianEnergyBurstPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.shockwave != shockwave ||
      oldDelegate.fade != fade ||
      oldDelegate.timeMs != timeMs;
}
