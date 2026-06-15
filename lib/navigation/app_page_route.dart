import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';
import '../widgets/app_theme_background.dart';

const Duration kAppRouteForwardDuration = Duration(milliseconds: 300);
const Duration kAppRouteReverseDuration = Duration(milliseconds: 250);

/// Opaque route with a stable full-screen backdrop and animated screen content.
Route<T> appPageRoute<T>({
  required WidgetBuilder builder,
  required Color backgroundColor,
  BackgroundTheme? backgroundTheme,
  RouteSettings? settings,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    opaque: true,
    transitionDuration: kAppRouteForwardDuration,
    reverseTransitionDuration: kAppRouteReverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.10, 0.012),
        end: Offset.zero,
      ).animate(curved);

      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      );

      final scale = Tween<double>(begin: 0.98, end: 1.0).animate(fade);

      final animatedContent = SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            child: child,
          ),
        ),
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          if (backgroundTheme != null)
            AppThemeBackground(theme: backgroundTheme)
          else
            ColoredBox(color: backgroundColor),
          animatedContent,
        ],
      );
    },
  );
}

/// Pushes a screen with the app's standard transition and background color.
Future<T?> pushAppRoute<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  required Color backgroundColor,
  BackgroundTheme? backgroundTheme,
  RouteSettings? settings,
}) {
  return Navigator.of(context).push<T>(
    appPageRoute<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      backgroundTheme: backgroundTheme,
      settings: settings,
    ),
  );
}

/// Pushes a screen using the selected background theme's gradient backdrop.
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
    backgroundTheme: theme,
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
