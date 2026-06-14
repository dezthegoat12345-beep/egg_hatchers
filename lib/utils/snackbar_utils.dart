import 'package:flutter/material.dart';

/// Default duration for normal compact game notifications.
const Duration kGameSnackBarDuration = Duration(seconds: 3);

/// Longer duration for quest completion notifications.
const Duration kQuestCompletionSnackBarDuration = Duration(seconds: 7);

/// Shows a compact floating SnackBar sized to fit the message.
void showGameSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  Duration duration = kGameSnackBarDuration,
  String? actionLabel,
  VoidCallback? onAction,
  double? minWidth,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

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

  final snackWidth = actionLabel != null
      ? maxWidth
      : (textPainter.size.width + 32).clamp(resolvedMinWidth, maxWidth);

  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: textStyle),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      width: snackWidth,
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onAction,
            )
          : null,
    ),
  );
}

/// Quest completion SnackBar with longer duration and optional View Quests action.
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
    duration: kQuestCompletionSnackBarDuration,
    minWidth: 280,
    actionLabel: onViewQuests != null ? 'View Quests' : null,
    onAction: onViewQuests,
  );
}
