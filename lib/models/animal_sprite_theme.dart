/// Visual style for built-in animal sprites (separate from background themes).
class AnimalSpriteTheme {
  const AnimalSpriteTheme({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

/// Available animal sprite themes.
class AnimalSpriteThemes {
  AnimalSpriteThemes._();

  static const classic = AnimalSpriteTheme(
    id: 'classic',
    name: 'Classic',
    description: 'Current polished animal sprites',
  );

  static const retroPixel = AnimalSpriteTheme(
    id: 'retroPixel',
    name: 'Retro Pixel',
    description: 'Chunky pixel-art animals',
  );

  static const all = [classic, retroPixel];

  static const defaultTheme = classic;

  static AnimalSpriteTheme byId(String? id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return defaultTheme;
  }
}
