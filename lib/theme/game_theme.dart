import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/background_theme.dart';

/// Shared styling helpers for the Egg Hatchers UI.
class GameTheme {
  GameTheme._();

  static const cardRadius = 24.0;
  static const buttonRadius = 16.0;
  static const panelRadius = 22.0;

  /// Richer display colors for rarity badges and card borders.
  static Color rarityAccent(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return const Color(0xFF9E9E9E);
      case Rarity.uncommon:
        return const Color(0xFF43A047);
      case Rarity.rare:
        return const Color(0xFF1E88E5);
      case Rarity.epic:
        return const Color(0xFF8E24AA);
      case Rarity.legendary:
        return const Color(0xFFFB8C00);
      case Rarity.mythic:
        return const Color(0xFF00ACC1);
    }
  }

  static Color mutationAccent(String mutationId) {
    switch (mutationId) {
      case 'golden':
        return const Color(0xFFFFB300);
      case 'rainbow':
        return const Color(0xFFE040FB);
      case 'shadow':
        return const Color(0xFF5E35B1);
      default:
        return Colors.transparent;
    }
  }

  static Color mutationTint(String mutationId) {
    switch (mutationId) {
      case 'golden':
        return const Color(0xFFFFF8E1);
      case 'rainbow':
        return const Color(0xFFF3E5F5);
      case 'shadow':
        return const Color(0xFFEDE7F6);
      default:
        return Colors.white;
    }
  }

  static BoxDecoration panelDecoration(BackgroundTheme theme) {
    return BoxDecoration(
      color: theme.panelColor.withValues(alpha: theme.isDark ? 0.95 : 0.92),
      borderRadius: BorderRadius.circular(panelRadius),
      border: Border.all(
        color: theme.panelAccentColor.withValues(alpha: 0.45),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.primaryColor.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration(
    BackgroundTheme theme, {
    Color? borderColor,
    bool locked = false,
    Color? backgroundColor,
  }) {
    final baseColor = backgroundColor ?? theme.cardColor;
    final cardFill = locked
        ? baseColor.withValues(alpha: theme.isDark ? 0.75 : 0.82)
        : baseColor.withValues(alpha: theme.isDark ? 0.92 : 0.96);

    return BoxDecoration(
      color: cardFill,
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: locked
            ? theme.disabledColor
            : (borderColor ?? theme.cardBorderColor)
                .withValues(alpha: borderColor != null ? 0.9 : 0.55),
        width: locked ? 2 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.primaryColor.withValues(alpha: locked ? 0.06 : 0.14),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle filledButton(
    BackgroundTheme theme, {
    Color? color,
    double height = 52,
  }) {
    final buttonColor = color ?? theme.primaryColor;
    return FilledButton.styleFrom(
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      disabledBackgroundColor: theme.disabledColor,
      minimumSize: Size(double.infinity, height),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  static TextStyle sectionTitle(BackgroundTheme theme, {double size = 20}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: theme.textPrimaryColor,
      letterSpacing: 0.2,
    );
  }

  static TextStyle emptyStateTitle(BackgroundTheme theme) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: theme.cardTextSecondaryColor,
      height: 1.5,
    );
  }
}

/// Fixed terminal-style colors for Developer Tools (never follows player theme).
class DevToolsTheme {
  DevToolsTheme._();

  static const background = Color(0xFF050505);
  static const surface = Color(0xFF101010);
  static const border = Color(0xFF00AA44);
  static const primary = Color(0xFF00FF66);
  static const primaryDim = Color(0xFF00CC55);
  static const text = Color(0xFF00FF66);
  static const textMuted = Color(0xFF66FF99);
  static const warning = Color(0xFFFFAA00);
  static const danger = Color(0xFFFF4444);

  static BoxDecoration panelDecoration({bool active = false}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(GameTheme.panelRadius),
      border: Border.all(
        color: active ? primary : border.withValues(alpha: 0.6),
        width: 1.5,
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(GameTheme.cardRadius),
      border: Border.all(color: border.withValues(alpha: 0.5)),
    );
  }

  static ButtonStyle filledButton({Color? color, double height = 52}) {
    final buttonColor = color ?? primaryDim;
    return FilledButton.styleFrom(
      backgroundColor: buttonColor.withValues(alpha: 0.2),
      foregroundColor: text,
      minimumSize: Size(double.infinity, height),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      side: BorderSide(color: buttonColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameTheme.buttonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }

  /// Compact buttons for Wrap layouts — avoids full-width minimum size overflow.
  static ButtonStyle compactButton({Color? color, double height = 44}) {
    final buttonColor = color ?? primaryDim;
    return FilledButton.styleFrom(
      backgroundColor: buttonColor.withValues(alpha: 0.2),
      foregroundColor: text,
      minimumSize: Size(0, height),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      side: BorderSide(color: buttonColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameTheme.buttonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
  }

  static TextStyle sectionTitle({double size = 20}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: text,
      fontFamily: 'monospace',
    );
  }

  static TextStyle bodyText({bool muted = false}) {
    return TextStyle(
      fontSize: 14,
      color: muted ? textMuted : text,
      fontFamily: 'monospace',
    );
  }

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textMuted, fontFamily: 'monospace'),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: border.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: border.withValues(alpha: 0.6)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: primary),
      ),
      filled: true,
      fillColor: surface,
    );
  }
}
