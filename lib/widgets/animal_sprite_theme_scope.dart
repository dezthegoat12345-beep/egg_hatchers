import 'package:flutter/widgets.dart';

import '../models/animal_sprite_theme.dart';

/// Exposes the current [AnimalSpriteTheme] to sprite widgets without threading
/// preferences through every screen.
class AnimalSpriteThemeScope extends InheritedWidget {
  const AnimalSpriteThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  final AnimalSpriteTheme theme;

  static AnimalSpriteTheme of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AnimalSpriteThemeScope>();
    return scope?.theme ?? AnimalSpriteThemes.defaultTheme;
  }

  @override
  bool updateShouldNotify(AnimalSpriteThemeScope oldWidget) {
    return oldWidget.theme.id != theme.id;
  }
}
