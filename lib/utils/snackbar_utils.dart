import 'package:flutter/material.dart';

/// Shows a compact floating SnackBar sized to fit the message.
void showGameSnackBar(
  BuildContext context, {
  required String message,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  final screenWidth = MediaQuery.sizeOf(context).width;
  const horizontalMargin = 24.0;
  const minWidth = 160.0;
  final maxWidth = (screenWidth - horizontalMargin * 2).clamp(minWidth, 400.0);

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

  final snackWidth = (textPainter.size.width + 32).clamp(minWidth, maxWidth);

  messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: textStyle),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      width: snackWidth,
    ),
  );
}
