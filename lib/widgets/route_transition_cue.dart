import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';

const Duration kShopPreNavTransitionDuration = Duration(milliseconds: 680);

/// Fade-in for the first ~150ms of the shop pre-navigation transition.
const double kShopCueFadeInPortion = 150 / 680;

/// Quick opacity curve for standard route transition cues.
double routeCueOpacity(double progress) {
  if (progress < 0.12) return progress / 0.12;
  if (progress > 0.82) return (1.0 - progress) / 0.18;
  return 1.0;
}

/// Shop cue: fade in over ~150ms, hold, then fade out near the end.
double shopRouteCueOpacity(double progress) {
  if (progress < kShopCueFadeInPortion) {
    return progress / kShopCueFadeInPortion;
  }
  if (progress > 0.88) {
    return (1.0 - progress) / 0.12;
  }
  return 1.0;
}

/// Small themed cue shown during a route push (not on pop).
class RouteTransitionCue extends StatelessWidget {
  const RouteTransitionCue({
    super.key,
    required this.theme,
    required this.animation,
    required this.icon,
    required this.label,
    this.opacityForProgress = routeCueOpacity,
  });

  final BackgroundTheme theme;
  final Animation<double> animation;
  final String icon;
  final String label;
  final double Function(double progress) opacityForProgress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = opacityForProgress(animation.value);
        if (opacity <= 0.01) {
          return const SizedBox.shrink();
        }
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.94 + (0.06 * opacity),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        elevation: 12,
        shadowColor: theme.primaryColor.withValues(alpha: 0.35),
        child: _CueCard(
          theme: theme,
          icon: icon,
          label: label,
          progress: animation,
        ),
      ),
    );
  }
}

class _CueCard extends StatelessWidget {
  const _CueCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.progress,
  });

  final BackgroundTheme theme;
  final String icon;
  final String label;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: GameTheme.cardDecoration(
        theme,
        borderColor: theme.secondaryColor,
        backgroundColor: theme.cardColor,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: theme.cardTextPrimaryColor,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: progress,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 5,
                  width: 168,
                  child: LinearProgressIndicator(
                    value: progress.value.clamp(0.0, 1.0),
                    backgroundColor:
                        theme.cardBorderColor.withValues(alpha: 0.3),
                    color: theme.secondaryColor,
                    minHeight: 5,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
