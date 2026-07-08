import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/audio_assets.dart';
import '../models/background_theme.dart';
import '../utils/cinematic_sound_guard.dart';
import 'audio_scope.dart';
import '../models/boss_battle.dart';
import 'bird_roost_background.dart';
import 'boss_cinematic_ui.dart';
import 'boss_sprite.dart';

/// Cinematic base bird boss defeat celebration for manual battle victories.
class BirdBossDefeatAnimation extends StatefulWidget {
  const BirdBossDefeatAnimation({
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
  State<BirdBossDefeatAnimation> createState() => _BirdBossDefeatAnimationState();
}

class _BirdBossDefeatAnimationState extends State<BirdBossDefeatAnimation>
    with SingleTickerProviderStateMixin {
  static const _totalMs = 10500.0;
  static const _skipAfterMs = 1000.0;
  static const _burstStartMs = 6000.0;
  static const _burstEndMs = 8000.0;
  static const _baseSpriteSize = 158.0;
  static const _sizeBoost = 1.34;

  late final AnimationController _controller;
  late final List<_FeatherParticle> _feathers;
  late final List<_ShadowWisp> _wisps;
  late final CinematicSoundGuard _soundGuard;
  var _completed = false;

  @override
  void initState() {
    super.initState();
    _feathers = _FeatherParticle.generate(36);
    _wisps = _ShadowWisp.generate(14);
    _soundGuard = CinematicSoundGuard();
    _controller = AnimationController(
      vsync: this,
      duration: BirdBossDefeatAnimation.duration,
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
    _soundGuard.maybeAt(t, 'burst', _burstStartMs, () => audio.playSfx(Sfx.featherBurst));
    _soundGuard.maybeAt(t, 'dissolve', _burstEndMs, () => audio.playSfx(Sfx.featherBurst));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _timeMs();
        _playPhaseSounds(t);
        final zoomPhase = Curves.easeOutCubic.transform(_phase(0, 1000));
        final zoomScale = 0.86 + zoomPhase * 0.52;
        final darken = (0.28 + zoomPhase * 0.32).clamp(0.0, 0.65);

        final wobblePhase = _phase(1000, 3000);
        final unstablePhase = _phase(3000, 6000);
        final burstPhase = Curves.easeIn.transform(_phase(_burstStartMs, _burstEndMs));

        final wobbleAmp = 6 + wobblePhase * 8 + unstablePhase * 12;
        final wobbleX = t >= 1000 && t < _burstStartMs
            ? math.sin(t / 38 * math.pi) * wobbleAmp
            : 0.0;
        final wobbleY = t >= 1000 && t < _burstStartMs
            ? math.cos(t / 44 * math.pi) * wobbleAmp * 0.65
            : 0.0;
        final flapTilt = t >= 1000 && t < _burstStartMs
            ? math.sin(t / 120 * math.pi) * (0.08 + unstablePhase * 0.14)
            : 0.0;

        final bossScale = zoomScale * _sizeBoost;
        final showBoss = t < _burstStartMs + 200;
        final bossOpacity = t < _burstStartMs
            ? 1.0
            : (1 - _phase(_burstStartMs, _burstStartMs + 400)).clamp(0.0, 1.0);

        final eyeFlicker = t >= 1000 && t < _burstStartMs
            ? (0.55 + math.sin(t / 65 * math.pi) * 0.45).clamp(0.0, 1.0)
            : 0.0;

        final featherTravel = t >= 1000
            ? Curves.easeOutCubic.transform(_phase(1000, _burstEndMs + 800))
            : 0.0;
        final smokeExpand = t >= 3000
            ? Curves.easeOut.transform(_phase(3000, _burstEndMs + 1200))
            : 0.0;
        final burstFlash = t >= _burstStartMs
            ? (1 - _phase(_burstStartMs, _burstStartMs + 350)).clamp(0.0, 1.0)
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
                const BirdRoostBackground(),
                ColoredBox(color: Colors.black.withValues(alpha: darken)),
                if (showBoss && bossOpacity > 0)
                  Transform.translate(
                    offset: Offset(wobbleX, wobbleY),
                    child: Transform.rotate(
                      angle: flapTilt,
                      child: Transform.scale(
                        scale: bossScale,
                        child: Opacity(
                          opacity: bossOpacity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (eyeFlicker > 0)
                                Positioned(
                                  top: _baseSpriteSize * 0.28,
                                  right: _baseSpriteSize * 0.32,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFCE93D8)
                                          .withValues(alpha: eyeFlicker),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFCE93D8)
                                              .withValues(alpha: eyeFlicker * 0.8),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              BossSprite(
                                spritePath: widget.boss.spritePath,
                                fallbackEmoji: widget.boss.emoji,
                                bossId: widget.boss.id,
                                size: _baseSpriteSize,
                                semanticLabel: widget.boss.name,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (burstFlash > 0)
                  ColoredBox(
                    color: const Color(0xFF7E57C2).withValues(alpha: burstFlash * 0.45),
                  ),
                CustomPaint(
                  painter: _BirdBurstPainter(
                    feathers: _feathers,
                    wisps: _wisps,
                    featherTravel: featherTravel,
                    smokeExpand: smokeExpand,
                    burst: burstPhase,
                    fade: effectFade,
                  ),
                ),
                BossCinematicVictoryOverlay(
                  theme: widget.theme,
                  bossName: widget.boss.name,
                  defeatTitle: 'SHADOW SCATTERED!',
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

class _FeatherParticle {
  _FeatherParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.rotation,
    required this.delay,
    required this.drift,
  });

  final double angle;
  final double distance;
  final double size;
  final double rotation;
  final double delay;
  final double drift;

  static List<_FeatherParticle> generate(int count) {
    final random = math.Random(17);
    return List.generate(count, (i) {
      return _FeatherParticle(
        angle: random.nextDouble() * math.pi * 2,
        distance: 0.12 + random.nextDouble() * 0.48,
        size: 8 + random.nextDouble() * 14,
        rotation: random.nextDouble() * math.pi,
        delay: random.nextDouble() * 0.35,
        drift: random.nextDouble() * math.pi * 2,
      );
    });
  }
}

class _ShadowWisp {
  _ShadowWisp({
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
  });

  final double x;
  final double y;
  final double size;
  final double delay;

  static List<_ShadowWisp> generate(int count) {
    final random = math.Random(23);
    return List.generate(count, (i) {
      return _ShadowWisp(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 18 + random.nextDouble() * 28,
        delay: random.nextDouble() * 0.3,
      );
    });
  }
}

class _BirdBurstPainter extends CustomPainter {
  _BirdBurstPainter({
    required this.feathers,
    required this.wisps,
    required this.featherTravel,
    required this.smokeExpand,
    required this.burst,
    required this.fade,
  });

  final List<_FeatherParticle> feathers;
  final List<_ShadowWisp> wisps;
  final double featherTravel;
  final double smokeExpand;
  final double burst;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.5);
    final maxDim = math.max(size.width, size.height);

    for (final w in wisps) {
      final localT = ((smokeExpand - w.delay) / (1 - w.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final alpha = (fade * localT * 0.35 * (1 - localT * 0.4)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;
      final pos = Offset(
        size.width * (0.35 + w.x * 0.3),
        size.height * (0.42 + w.y * 0.2 - localT * 0.12),
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: pos,
          width: w.size * (0.6 + localT),
          height: w.size * (0.35 + localT * 0.5),
        ),
        Paint()..color = const Color(0xFF4527A0).withValues(alpha: alpha),
      );
    }

    if (burst > 0) {
      canvas.drawCircle(
        center,
        24 + burst * maxDim * 0.22,
        Paint()
          ..color = const Color(0xFF311B92).withValues(alpha: fade * burst * 0.25),
      );
    }

    for (final f in feathers) {
      final localT = ((featherTravel - f.delay) / (1 - f.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;
      final eased = Curves.easeOutCubic.transform(localT);
      final burstBoost = burst * 0.55;
      final dist = f.distance * maxDim * (eased + burstBoost);
      final driftX = math.sin(f.drift + eased * math.pi * 2) * 18;
      final driftY = eased * maxDim * 0.08 + math.cos(f.drift) * 12;
      final pos = center +
          Offset(
            math.cos(f.angle) * dist + driftX,
            math.sin(f.angle) * dist * 0.45 + driftY,
          );
      final alpha = (fade * (1 - localT * 0.2)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(f.rotation + eased * math.pi * 1.5);
      final path = Path()
        ..moveTo(0, -f.size * 0.5)
        ..quadraticBezierTo(f.size * 0.35, 0, 0, f.size * 0.5)
        ..quadraticBezierTo(-f.size * 0.35, 0, 0, -f.size * 0.5);
      canvas.drawPath(
        path,
        Paint()..color = const Color(0xFFCE93D8).withValues(alpha: alpha * 0.85),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF4527A0).withValues(alpha: alpha * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BirdBurstPainter oldDelegate) =>
      oldDelegate.featherTravel != featherTravel ||
      oldDelegate.smokeExpand != smokeExpand ||
      oldDelegate.burst != burst ||
      oldDelegate.fade != fade;
}
