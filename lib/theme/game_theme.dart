import 'package:flutter/material.dart';

import '../models/animal.dart';

/// Shared colors, gradients, and styling for the Egg Hatchers UI.
class GameTheme {
  GameTheme._();

  // Pastel palette
  static const cream = Color(0xFFFFF8F0);
  static const softYellow = Color(0xFFFFF3C4);
  static const paleBlue = Color(0xFFE3F2FD);
  static const softPink = Color(0xFFFCE4EC);
  static const lightGreen = Color(0xFFE8F5E9);
  static const softPeach = Color(0xFFFFE8D6);

  static const textDark = Color(0xFF5D4037);
  static const textMuted = Color(0xFF795548);

  static const cardRadius = 24.0;
  static const buttonRadius = 16.0;
  static const panelRadius = 22.0;

  static LinearGradient gradientFor(GameBackgroundStyle style) {
    switch (style) {
      case GameBackgroundStyle.hatchery:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [softYellow, cream, softPeach],
        );
      case GameBackgroundStyle.shop:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightGreen, cream, paleBlue],
        );
      case GameBackgroundStyle.collection:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [softPink, cream, paleBlue],
        );
      case GameBackgroundStyle.developer:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [paleBlue, cream, Color(0xFFEEEEEE)],
        );
    }
  }

  static Color appBarColorFor(GameBackgroundStyle style) {
    switch (style) {
      case GameBackgroundStyle.hatchery:
        return const Color(0xFF4DB6AC);
      case GameBackgroundStyle.shop:
        return const Color(0xFFFFB74D);
      case GameBackgroundStyle.collection:
        return const Color(0xFFBA68C8);
      case GameBackgroundStyle.developer:
        return const Color(0xFF78909C);
    }
  }

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

  static BoxDecoration panelDecoration({Color? accent}) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(panelRadius),
      border: Border.all(
        color: (accent ?? const Color(0xFFFFB74D)).withValues(alpha: 0.35),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.brown.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration cardDecoration({
    Color? borderColor,
    bool locked = false,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ??
          (locked
              ? Colors.white.withValues(alpha: 0.65)
              : Colors.white.withValues(alpha: 0.95)),
      borderRadius: BorderRadius.circular(cardRadius),
      border: Border.all(
        color: locked
            ? Colors.grey.shade400
            : (borderColor ?? Colors.white)
                .withValues(alpha: borderColor != null ? 0.9 : 0.0),
        width: locked ? 2 : (borderColor != null ? 2.5 : 0),
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? Colors.brown).withValues(alpha: locked ? 0.06 : 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ButtonStyle filledButton(Color color, {double height = 52}) {
    return FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      minimumSize: Size(double.infinity, height),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonRadius),
      ),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
    );
  }

  static TextStyle sectionTitle({double size = 20}) {
    return TextStyle(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: textDark,
      letterSpacing: 0.2,
    );
  }

  static TextStyle emptyStateTitle() {
    return const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: textMuted,
      height: 1.5,
    );
  }
}

/// Which screen gradient to use for [GameBackground].
enum GameBackgroundStyle {
  hatchery,
  shop,
  collection,
  developer,
}
