import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../theme/game_theme.dart';
import '../widgets/app_theme_background.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/route_transition_cue.dart';

const Duration kAppRouteForwardDuration = Duration(milliseconds: 300);
const Duration kAppRouteReverseDuration = Duration(milliseconds: 250);

/// Optional themed transition cues for specific navigation paths.
enum AppRouteTransitionKind {
  standard,
  shop,
}

/// Opaque route with a stable backdrop and animated phone-width panel only.
Route<T> appPageRoute<T>({
  required WidgetBuilder builder,
  required Color backgroundColor,
  BackgroundTheme? backgroundTheme,
  AppRouteTransitionKind transitionKind = AppRouteTransitionKind.standard,
  RouteSettings? settings,
}) {
  final isShop = transitionKind == AppRouteTransitionKind.shop;

  return PageRouteBuilder<T>(
    settings: settings,
    opaque: true,
    transitionDuration:
        isShop ? kShopRouteForwardDuration : kAppRouteForwardDuration,
    reverseTransitionDuration:
        isShop ? kShopRouteReverseDuration : kAppRouteReverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (isShop && animation.value < 0.02) {
        debugPrint('Shop themed transition active');
      }

      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slideBegin = isShop
          ? const Offset(0.20, 0.01)
          : const Offset(0.14, 0);
      final slide = Tween<Offset>(
        begin: slideBegin,
        end: Offset.zero,
      ).animate(curved);

      final fade = Tween<double>(
        begin: isShop ? 0.75 : 0.85,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      );

      final scale = Tween<double>(
        begin: isShop ? 0.97 : 0.985,
        end: 1.0,
      ).animate(fade);

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

      final backdropTheme = backgroundTheme;
      final isPopping = animation.status == AnimationStatus.reverse;
      final showShopCue = isShop && backdropTheme != null && !isPopping;

      Widget? transitionCue;
      if (showShopCue) {
        final panelWidth = math.min(
          MediaQuery.sizeOf(context).width,
          kPhoneMaxContentWidth,
        );
        transitionCue = IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: panelWidth,
              height: MediaQuery.sizeOf(context).height,
              child: ShopRouteTransitionCue(
                theme: backdropTheme,
                animation: animation,
              ),
            ),
          ),
        );
      }

      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          StableRouteBackdrop(
            theme: backgroundTheme,
            color: backgroundTheme == null ? backgroundColor : null,
          ),
          animatedPanel,
          ?transitionCue,
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
  AppRouteTransitionKind transitionKind = AppRouteTransitionKind.standard,
  RouteSettings? settings,
}) {
  return Navigator.of(context).push<T>(
    appPageRoute<T>(
      builder: builder,
      backgroundColor: backgroundColor,
      backgroundTheme: backgroundTheme,
      transitionKind: transitionKind,
      settings: settings,
    ),
  );
}

/// Pushes a screen using the selected background theme's gradient backdrop.
Future<T?> pushThemedAppRoute<T>(
  BuildContext context, {
  required BackgroundTheme theme,
  required WidgetBuilder builder,
  AppRouteTransitionKind transitionKind = AppRouteTransitionKind.standard,
  RouteSettings? settings,
}) {
  return pushAppRoute<T>(
    context,
    builder: builder,
    backgroundColor: theme.scaffoldColor,
    backgroundTheme: theme,
    transitionKind: transitionKind,
    settings: settings,
  );
}

/// Hatchery -> Shop prototype with a shop-themed transition cue.
Future<T?> pushShopAppRoute<T>(
  BuildContext context, {
  required BackgroundTheme theme,
  required WidgetBuilder builder,
  RouteSettings? settings,
}) {
  return pushThemedAppRoute<T>(
    context,
    theme: theme,
    transitionKind: AppRouteTransitionKind.shop,
    builder: builder,
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
