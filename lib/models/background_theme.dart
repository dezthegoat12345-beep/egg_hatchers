import 'package:flutter/material.dart';

/// A selectable background gradient theme for the game UI.
class BackgroundTheme {
  const BackgroundTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.colors,
    this.isDark = false,
  });

  final String id;
  final String name;
  final String description;
  final List<Color> colors;
  final bool isDark;

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors,
      );

  Color get previewStart => colors.first;
  Color get previewEnd => colors.last;
}

/// All available background themes.
class BackgroundThemes {
  BackgroundThemes._();

  static const hatcheryDefault = BackgroundTheme(
    id: 'hatchery_default',
    name: 'Hatchery Default',
    description: 'Soft pastel egg hatchery look',
    colors: [
      Color(0xFFFFF3C4),
      Color(0xFFFFF8F0),
      Color(0xFFFFE8D6),
    ],
  );

  static const sunnyMeadow = BackgroundTheme(
    id: 'sunny_meadow',
    name: 'Sunny Meadow',
    description: 'Light green and yellow outdoor vibes',
    colors: [
      Color(0xFFE8F5E9),
      Color(0xFFFFF9C4),
      Color(0xFFC8E6C9),
    ],
  );

  static const candyClouds = BackgroundTheme(
    id: 'candy_clouds',
    name: 'Candy Clouds',
    description: 'Pink, purple, and sky-blue fun',
    colors: [
      Color(0xFFFCE4EC),
      Color(0xFFE1BEE7),
      Color(0xFFE3F2FD),
    ],
  );

  static const oceanBreeze = BackgroundTheme(
    id: 'ocean_breeze',
    name: 'Ocean Breeze',
    description: 'Cool light blue and teal waves',
    colors: [
      Color(0xFFE1F5FE),
      Color(0xFFB2EBF2),
      Color(0xFF80DEEA),
    ],
  );

  static const starrySpace = BackgroundTheme(
    id: 'starry_space',
    name: 'Starry Space',
    description: 'Deep cosmic blue and purple',
    colors: [
      Color(0xFF0D1B2A),
      Color(0xFF1B263B),
      Color(0xFF3D348B),
    ],
    isDark: true,
  );

  static const goldenGlow = BackgroundTheme(
    id: 'golden_glow',
    name: 'Golden Glow',
    description: 'Warm cream and golden shimmer',
    colors: [
      Color(0xFFFFF8E1),
      Color(0xFFFFECB3),
      Color(0xFFFFE082),
    ],
  );

  static const shadowNight = BackgroundTheme(
    id: 'shadow_night',
    name: 'Shadow Night',
    description: 'Mysterious purple and midnight tones',
    colors: [
      Color(0xFF1A1025),
      Color(0xFF2D1B4E),
      Color(0xFF0D0D0D),
    ],
    isDark: true,
  );

  static const all = <BackgroundTheme>[
    hatcheryDefault,
    sunnyMeadow,
    candyClouds,
    oceanBreeze,
    starrySpace,
    goldenGlow,
    shadowNight,
  ];

  static const defaultTheme = hatcheryDefault;

  static BackgroundTheme byId(String id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return defaultTheme;
  }
}
