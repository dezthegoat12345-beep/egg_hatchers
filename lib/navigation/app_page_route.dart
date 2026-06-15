import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';

const Duration kAppRouteForwardDuration = Duration(milliseconds: 300);
const Duration kAppRouteReverseDuration = Duration(milliseconds: 250);

/// Themed full-screen route with fade + slight slide and a non-white background.
Route<T> appPageRoute<T>({
  required WidgetBuilder builder,
  required Color backgroundColor,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    opaque: true,
    barrierColor: backgroundColor,
    transitionDuration: kAppRouteForwardDuration,
    reverseTransitionDuration: kAppRouteReverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return ColoredBox(
        color: backgroundColor,
        child: builder(context),
      );
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0.008),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

/// Pushes a screen with the app's standard transition and background color.
Future<T?> pushAppRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required Color backgroundColor,
  RouteSettings? settings,
}) {
  return Navigator.of(context).push<T>(
    appPageRoute<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      settings: settings,
    ),
  );
}

/// Pushes a screen using the selected background theme's scaffold color.
Future<T?> pushThemedAppRoute<T>(
  BuildContext context, {
  required BackgroundTheme theme,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return pushAppRoute<T>(
    context,
    builder: builder,
    backgroundColor: theme.scaffoldColor,
    settings: settings,
  );
}

/// Pushes Developer Tools with the terminal black background.
Future<T?> pushDevToolsRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return pushAppRoute<T>(
    context,
    builder: builder,
    backgroundColor: DevToolsTheme.background,
    settings: settings,
  );
}
