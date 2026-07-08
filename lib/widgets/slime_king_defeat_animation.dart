import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/audio_assets.dart';
import '../models/background_theme.dart';
import '../utils/cinematic_sound_guard.dart';
import 'audio_scope.dart';
import '../models/boss_battle.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';
import 'slime_king_cinematic_background.dart';

/// Cinematic Slime King defeat celebration for manual battle victories.
class SlimeKingDefeatAnimation extends StatefulWidget {
  const SlimeKingDefeatAnimation({
    super.key,
    required this.theme,
    required this.boss,
    required this.coinReward,
    required this.tokenReward,
    this.animalRewardName,
    required this.onComplete,
  });

  static const duration = Duration(milliseconds: 11200);

  final BackgroundTheme theme;
  final BossBattleDefinition boss;
  final int coinReward;
  final int tokenReward;
  final String? animalRewardName;
  final VoidCallback onComplete;

  @override
  State<SlimeKingDefeatAnimation> createState() =>
      _SlimeKingDefeatAnimationState();
}

class _SlimeKingDefeatAnimationState extends State<SlimeKingDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 11200.0;
  static const _skipAfterMs = 1000.0;
  static const _crownPopMs = 3000.0;
  static const _explosionStartMs = 8000.0;
  static const _burstEndMs = 9200.0;
  static const _baseSpriteSize = 168.0;
  static const _sizeBoost = 1.42;

  late final AnimationController _controller;
  late final List<_RoyalGooParticle> _gooParticles;
  late final List<_GoldSparkle> _sparkles;
  late final CinematicSoundGuard _soundGuard;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _gooParticles = _RoyalGooParticle.generate(64);
    _sparkles = _GoldSparkle.generate(28);
    _soundGuard = CinematicSoundGuard();
    _controller = AnimationController(
      vsync: this,
      duration: SlimeKingDefeatAnimation.duration,
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

  void _playPhaseSounds(double t) {
    final audio = AudioScope.maybeOf(context);
    if (audio == null) return;
    _soundGuard.maybeAt(t, 'crown', _crownPopMs, () => audio.playSfx(Sfx.royalPop));
    _soundGuard.maybeAt(t, 'explosion', _explosionStartMs, () => audio.playSfx(Sfx.royalPop));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        _playPhaseSounds(t);
        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 1000));
        final zoomScale = 0.86 + zoomPhase * 0.54;
        final darken = (0.28 + zoomPhase * 0.3).clamp(0.0, 0.62);

        final wobblePhase = _phase(1000, 3000);
        final swellPhase = _phase(3000, _explosionStartMs);
        final panicPhase = _phase(5500, _explosionStartMs);

        final wobbleAmp = 5 + wobblePhase * 10 + swellPhase * 18 + panicPhase * 22;
        final shakeX = t >= 1000 && t < _burstEndMs
            ? math.sin(t / 42 * math.pi) * wobbleAmp
            : 0.0;
        final shakeY = t >= 1000 && t < _burstEndMs
            ? math.cos(t / 48 * math.pi) * wobbleAmp * 0.55
            : 0.0;

        final inflation = swellPhase * (1 + panicPhase * 0.35);
        final bossScale = zoomScale * _sizeBoost * (1 + inflation * 0.22);
        final jiggleX = 1 + math.sin(t / 90 * math.pi) * swellPhase * 0.06;
        final jiggleY = 1 + math.cos(t / 75 * math.pi) * swellPhase * 0.08;

        final showBoss = t < _explosionStartMs;
        final crownAttached = t < _crownPopMs;
        final crownPopProgress = t >= _crownPopMs
            ? Curves.easeOutBack.transform(_phase(_crownPopMs, _crownPopMs + 700))
            : 0.0;
        final crownFallProgress = t >= _crownPopMs + 700
            ? Curves.easeIn.transform(_phase(_crownPopMs + 700, _burstEndMs))
            : 0.0;

        final burstTravel = t >= _explosionStartMs
            ? Curves.easeOutCubic.transform(_phase(_explosionStartMs, _burstEndMs + 600))
            : 0.0;
        final sparkleBurst = t >= _explosionStartMs
            ? Curves.easeOut.transform(_phase(_explosionStartMs, _burstEndMs))
            : 0.0;
        final bubblePhase = swellPhase * (0.4 + math.sin(t / 120 * math.pi) * 0.2);

        final popFlash = t >= _explosionStartMs
            ? (1 - _phase(_explosionStartMs, _explosionStartMs + 350)).clamp(0.0, 1.0)
            : 0.0;
        final effectFade = (1 - _phase(9600, 11000)).clamp(0.0, 1.0);

        final surprised = t >= 5500 && t < _explosionStartMs;

        final titleProgress = Curves.elasticOut.transform(_phase(9600, 10200));
        final titleOpacity = Curves.easeOut.transform(_phase(9600, 10000));
        final rewardsOpacity = Curves.easeOut.transform(_phase(10000, 11000));
        final rewardsSlide = (1 - rewardsOpacity) * 28;

        return Material(
          color: Colors.black.withValues(alpha: 0.82),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: t >= _skipAfterMs && !_completed ? _trySkip : null,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const SlimeKingCinematicBackground(),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (showBoss)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.diagonal3Values(
                        bossScale * jiggleX,
                        bossScale * jiggleY,
                        1,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          if (bubblePhase > 0)
                            ...List.generate(4, (i) {
                              final angle = i * math.pi / 2 + t * 0.01;
                              return Positioned(
                                left: _baseSpriteSize * 0.5 +
                                    math.cos(angle) * 40 * bubblePhase -
                                    8,
                                top: _baseSpriteSize * 0.5 +
                                    math.sin(angle) * 30 * bubblePhase -
                                    8,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF81C784)
                                        .withValues(alpha: bubblePhase * 0.5),
                                    border: Border.all(
                                      color: const Color(0xFF43A047)
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          if (swellPhase > 0.2)
                            Container(
                              width: _baseSpriteSize * (1.1 + inflation * 0.3),
                              height: _baseSpriteSize * (1.1 + inflation * 0.3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F)
                                        .withValues(alpha: swellPhase * 0.25),
                                    blurRadius: 28,
                                    spreadRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          BossSprite(
                            spritePath: widget.boss.spritePath,
                            fallbackEmoji: widget.boss.emoji,
                            bossId: widget.boss.id,
                            size: _baseSpriteSize,
                            semanticLabel: widget.boss.name,
                          ),
                          if (surprised)
                            Positioned(
                              top: _baseSpriteSize * 0.22,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoyalEye(size: 14, panicked: true),
                                  SizedBox(width: _baseSpriteSize * 0.38),
                                  _RoyalEye(size: 14, panicked: true),
                                ],
                              ),
                            ),
                          if (crownAttached)
                            Transform.translate(
                              offset: Offset(
                                math.sin(t / 55 * math.pi) * wobblePhase * 8,
                                -_baseSpriteSize * 0.52 +
                                    math.cos(t / 60 * math.pi) * wobblePhase * 5,
                              ),
                              child: Transform.rotate(
                                angle: math.sin(t / 70 * math.pi) * 0.12 * wobblePhase,
                                child: const Text('👑', style: TextStyle(fontSize: 42)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (t >= _crownPopMs)
                  Transform.translate(
                    offset: Offset(shakeX, shakeY),
                    child: CustomPaint(
                      painter: _CrownFallPainter(
                        popProgress: crownPopProgress,
                        fallProgress: crownFallProgress,
                        bossScale: bossScale,
                        burstTravel: burstTravel,
                        fade: effectFade,
                      ),
                    ),
                  ),
                if (popFlash > 0)
                  ColoredBox(
                    color: const Color(0xFF66BB6A).withValues(alpha: popFlash * 0.5),
                  ),
                if (popFlash > 0)
                  ColoredBox(
                    color: const Color(0xFFFFD54F).withValues(alpha: popFlash * 0.25),
                  ),
                Transform.translate(
                  offset: Offset(shakeX, shakeY),
                  child: CustomPaint(
                    painter: _RoyalGooBurstPainter(
                      particles: _gooParticles,
                      sparkles: _sparkles,
                      travel: burstTravel,
                      sparkleBurst: sparkleBurst,
                      fade: effectFade,
                    ),
                  ),
                ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'ROYAL SPLAT!',
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

class _RoyalEye extends StatelessWidget {
  const _RoyalEye({required this.size, this.panicked = false});

  final double size;
  final bool panicked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: panicked ? size * 1.35 : size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black87, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: size * 0.45,
          height: size * 0.45,
          decoration: const BoxDecoration(
            color: Colors.black87,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _CrownFallPainter extends CustomPainter {
  _CrownFallPainter({
    required this.popProgress,
    required this.fallProgress,
    required this.bossScale,
    required this.burstTravel,
    required this.fade,
  });

  final double popProgress;
  final double fallProgress;
  final double bossScale;
  final double burstTravel;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (popProgress <= 0 && fallProgress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height * 0.5;

    final popY = -90 * popProgress * bossScale * 0.5;
    final fallY = popY + fallProgress * fallProgress * size.height * 0.22;
    final fallX = math.sin(fallProgress * math.pi * 2.5) * 40 * fallProgress;
    final rotation = popProgress * -0.4 + fallProgress * math.pi * 1.8;

    final crownCenter = Offset(cx + fallX, cy + fallY - 80 * bossScale * 0.4);

    canvas.save();
    canvas.translate(crownCenter.dx, crownCenter.dy);
    canvas.rotate(rotation);

    final tp = TextPainter(
      text: const TextSpan(text: '👑', style: TextStyle(fontSize: 40)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();

    if (burstTravel > 0.3 && fallProgress > 0.5) {
      canvas.drawCircle(
        crownCenter + Offset(0, 12),
        18 + burstTravel * 12,
        Paint()
          ..color = const Color(0xFF43A047).withValues(alpha: fade * burstTravel * 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CrownFallPainter oldDelegate) =>
      oldDelegate.popProgress != popProgress ||
      oldDelegate.fallProgress != fallProgress ||
      oldDelegate.burstTravel != burstTravel ||
      oldDelegate.fade != fade;
}

class _RoyalGooParticle {
  _RoyalGooParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.isGold,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;
  final bool isGold;

  static List<_RoyalGooParticle> generate(int count) {
    final random = math.Random(44);
    return List.generate(count, (i) {
      return _RoyalGooParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.15 + random.nextDouble() * 0.55,
        size: 8 + random.nextDouble() * 18,
        delay: random.nextDouble() * 0.2,
        isGold: i % 5 == 0,
      );
    });
  }
}

class _GoldSparkle {
  _GoldSparkle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
  });

  final double angle;
  final double distance;
  final double size;
  final double delay;

  static List<_GoldSparkle> generate(int count) {
    final random = math.Random(55);
    return List.generate(count, (i) {
      return _GoldSparkle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.1 + random.nextDouble() * 0.5,
        size: 4 + random.nextDouble() * 8,
        delay: random.nextDouble() * 0.15,
      );
    });
  }
}

class _RoyalGooBurstPainter extends CustomPainter {
  _RoyalGooBurstPainter({
    required this.particles,
    required this.sparkles,
    required this.travel,
    required this.sparkleBurst,
    required this.fade,
  });

  final List<_RoyalGooParticle> particles;
  final List<_GoldSparkle> sparkles;
  final double travel;
  final double sparkleBurst;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final maxDim = math.max(size.width, size.height);

    for (final p in particles) {
      final localT = ((travel - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      final dist = p.distance * maxDim * eased;
      final gravity = eased * eased * maxDim * 0.1;
      final pos = center +
          Offset(
            math.cos(p.angle) * dist,
            math.sin(p.angle) * dist * 0.5 + gravity,
          );
      final alpha = (fade * (1 - localT * 0.12)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      final color = p.isGold
          ? const Color(0xFFFFD54F)
          : const Color(0xFF66BB6A);
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: p.size * 1.8,
          height: p.size,
        ),
        Paint()..color = color.withValues(alpha: alpha * 0.85),
      );
    }

    for (final s in sparkles) {
      final localT = ((sparkleBurst - s.delay) / (1 - s.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOut.transform(localT);
      final dist = s.distance * maxDim * eased;
      final pos = center + Offset(math.cos(s.angle) * dist, math.sin(s.angle) * dist * 0.45);
      final alpha = (fade * (1 - localT * 0.4)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.drawCircle(
        pos,
        s.size * (1 - localT * 0.3),
        Paint()..color = const Color(0xFFFFEB3B).withValues(alpha: alpha * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoyalGooBurstPainter oldDelegate) =>
      oldDelegate.travel != travel ||
      oldDelegate.sparkleBurst != sparkleBurst ||
      oldDelegate.fade != fade;
}
