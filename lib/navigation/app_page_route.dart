import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';
import '../widgets/app_theme_background.dart';
import '../widgets/phone_width_layout.dart';

const Duration kAppRouteForwardDuration = Duration(milliseconds: 300);
const Duration kAppRouteReverseDuration = Duration(milliseconds: 250);

/// Opaque route with a stable backdrop and animated phone-width panel only.
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
      final slide = Tween<Offset>(
        begin: const Offset(0.14, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );

      final fade = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );

      final scale = Tween<double>(begin: 0.985, end: 1.0).animate(fade);

      final animatedPanel = AppRoutePhonePanel(
        maxWidth: kPhoneMaxContentWidth,
        child: SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: fade,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          ),
        ),
      );

      return Stack(
        fit: StackFit.expand,
        children: [
          StableRouteBackdrop(
            theme: backgroundTheme,
            color: backgroundTheme == null ? backgroundColor : null,
          ),
          animatedPanel,
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
