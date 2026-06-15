import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';

/// Quick opacity curve for route transition cues: in, hold, out within one push.
double routeCueOpacity(double progress) {
  if (progress < 0.12) return progress / 0.12;
  if (progress > 0.82) return (1.0 - progress) / 0.18;
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
  });

  final BackgroundTheme theme;
  final Animation<double> animation;
  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = routeCueOpacity(animation.value);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: 0.94 + (0.06 * opacity),
            child: child,
          ),
        );
      },
      child: _CueCard(
        theme: theme,
        icon: icon,
        label: label,
        progress: animation,
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
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 220),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: GameTheme.cardDecoration(
          theme,
          borderColor: theme.secondaryColor,
          backgroundColor: theme.cardColor.withValues(alpha: 0.96),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.cardTextPrimaryColor,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 4,
                    width: 160,
                    child: LinearProgressIndicator(
                      value: progress.value.clamp(0.0, 1.0),
                      backgroundColor:
                          theme.cardBorderColor.withValues(alpha: 0.25),
                      color: theme.secondaryColor,
                      minHeight: 4,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Shop-themed route transition cue.
class ShopRouteTransitionCue extends StatelessWidget {
  const ShopRouteTransitionCue({
    super.key,
    required this.theme,
    required this.animation,
  });

  final BackgroundTheme theme;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RouteTransitionCue(
      theme: theme,
      animation: animation,
      icon: '🛒',
      label: 'Opening Shop',
    );
  }
}
