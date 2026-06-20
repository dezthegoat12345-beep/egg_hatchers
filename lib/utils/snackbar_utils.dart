import 'package:flutter/material.dart';

import '../services/tutorial_service.dart';

/// Quick/common transient notifications.
const Duration kGameSnackBarDurationShort = Duration(milliseconds: 1500);

/// Default duration for normal compact game notifications.
const Duration kGameSnackBarDuration = Duration(seconds: 2);

/// Important notifications, including those with action buttons.
const Duration kGameSnackBarDurationImportant = Duration(seconds: 3);

/// Quest completion notifications with a View Quests action.
const Duration kQuestCompletionSnackBarDuration =
    kGameSnackBarDurationImportant;

Duration _resolveSnackBarDuration({
  required Duration? duration,
  required bool hasAction,
}) {
  final resolved = duration ??
      (hasAction ? kGameSnackBarDurationImportant : kGameSnackBarDuration);
  if (resolved > kGameSnackBarDurationImportant) {
    return kGameSnackBarDurationImportant;
  }
  return resolved;
}

/// Removes any visible game snackbars from the nearest [ScaffoldMessenger].
void clearGameSnackBars(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
}

/// Shows a compact floating SnackBar sized to fit the message.
void showGameSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  Duration? duration,
  String? actionLabel,
  VoidCallback? onAction,
  double? minWidth,
}) {
  if (TutorialService.instance.shouldSuppressSnackBars) return;

  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  final hasAction = actionLabel != null && onAction != null;
  final effectiveDuration = _resolveSnackBarDuration(
    duration: duration,
    hasAction: hasAction,
  );

  final screenWidth = MediaQuery.sizeOf(context).width;
  const horizontalMargin = 24.0;
  final resolvedMinWidth = minWidth ?? 160.0;
  final maxWidth =
      (screenWidth - horizontalMargin * 2).clamp(resolvedMinWidth, 400.0);

  const textStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  final textPainter = TextPainter(
    text: TextSpan(text: message, style: textStyle),
    textDirection: Directionality.of(context),
    maxLines: 4,
  )..layout(maxWidth: maxWidth - 32);

  final snackWidth = hasAction
      ? maxWidth
      : (textPainter.size.width + 32).clamp(resolvedMinWidth, maxWidth);

  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: textStyle),
      behavior: SnackBarBehavior.floating,
      duration: effectiveDuration,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      width: snackWidth,
      action: hasAction
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    ),
  );
}

/// Quest completion SnackBar with optional View Quests action.
void showQuestCompletionSnackBar(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  VoidCallback? onViewQuests,
}) {
  showGameSnackBar(
    context,
    message: message,
    backgroundColor: backgroundColor,
    duration: onViewQuests != null
        ? kGameSnackBarDurationImportant
        : kGameSnackBarDuration,
    minWidth: 280,
    actionLabel: onViewQuests != null ? 'View Quests' : null,
    onAction: onViewQuests,
  );
}
