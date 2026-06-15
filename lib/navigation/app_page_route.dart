import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';
import '../widgets/app_theme_background.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/themed_route_transition_screen.dart';

const Duration kAppRouteForwardDuration = Duration(milliseconds: 300);
const Duration kAppRouteReverseDuration = Duration(milliseconds: 250);

/// Opaque route with a stable backdrop and animated phone-width panel only.
Route<T> appPageRoute<T>({
  required WidgetBuilder builder,
  required Color backgroundColor,
  BackgroundTheme? backgroundTheme,
  RouteSettings? settings,
  bool instantTransition = false,
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    opaque: true,
    transitionDuration:
        instantTransition ? Duration.zero : kAppRouteForwardDuration,
    reverseTransitionDuration:
        instantTransition ? Duration.zero : kAppRouteReverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final panel = AppRoutePhonePanel(
        maxWidth: kPhoneMaxContentWidth,
        child: child,
      );

      if (instantTransition) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            StableRouteBackdrop(
              theme: backgroundTheme,
              color: backgroundTheme == null ? backgroundColor : null,
            ),
            panel,
          ],
        );
      }

      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.14, 0),
        end: Offset.zero,
      ).animate(curved);

      final fade = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );

      final scale = Tween<double>(begin: 0.985, end: 1.0).animate(fade);

      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          StableRouteBackdrop(
            theme: backgroundTheme,
            color: backgroundTheme == null ? backgroundColor : null,
          ),
          AppRoutePhonePanel(
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
          ),
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
  bool instantTransition = false,
}) {
  return Navigator.of(context).push<T>(
    appPageRoute<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      backgroundTheme: backgroundTheme,
      settings: settings,
      instantTransition: instantTransition,
    ),
  );
}

/// Pushes a screen using the selected background theme's gradient backdrop.
Future<T?> pushThemedAppRoute<T>(
  BuildContext context, {
  required BackgroundTheme theme,
  required WidgetBuilder builder,
  RouteSettings? settings,
  bool instantTransition = false,
}) {
  return pushAppRoute<T>(
    context,
    builder: builder,
    backgroundColor: theme.scaffoldColor,
    backgroundTheme: theme,
    settings: settings,
    instantTransition: instantTransition,
  );
}

/// Hatchery -> Shop: pre-navigation transition screen, then Shop.
Future<T?> openShopWithTransition<T>(
  BuildContext context, {
  required BackgroundTheme theme,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return Navigator.of(context).push<T>(
    appPageRoute<T>(
      settings: settings,
      backgroundColor: theme.scaffoldColor,
      backgroundTheme: theme,
      instantTransition: true,
      builder: (transitionContext) {
        return ThemedRouteTransitionScreen(
          theme: theme,
          icon: '🛒',
          label: 'Opening Shop',
          duration: kShopPreNavTransitionDuration,
          onComplete: () {
            if (!transitionContext.mounted) return;
            Navigator.of(transitionContext).pushReplacement<T, void>(
              appPageRoute<T>(
                builder: builder,
                backgroundColor: theme.scaffoldColor,
                backgroundTheme: theme,
                settings: settings,
              ),
            );
          },
        );
      },
    ),
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
