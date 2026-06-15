import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';

/// Full-screen gradient backdrop that stays painted behind routes.
class AppThemeBackground extends StatelessWidget {
  const AppThemeBackground({
    super.key,
    required this.theme,
    this.child = const SizedBox.shrink(),
  });

  final BackgroundTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(gradient: theme.gradient),
          child: const SizedBox.expand(),
        ),
        child,
      ],
    );
  }
}

/// Opaque full-screen backdrop for route transitions. Never animated.
class StableRouteBackdrop extends StatelessWidget {
  const StableRouteBackdrop({
    super.key,
    this.theme,
    this.color,
  }) : assert(theme != null || color != null);

  final BackgroundTheme? theme;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (theme != null) {
      return AppThemeBackground(theme: theme!);
    }
    return ColoredBox(color: color!);
  }
}

/// Centers route content in the phone-width column for panel transitions.
class AppRoutePhonePanel extends StatelessWidget {
  const AppRoutePhonePanel({
    super.key,
    required this.child,
    this.maxWidth = 430,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width, maxWidth);
    final height = MediaQuery.sizeOf(context).height;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }
}
