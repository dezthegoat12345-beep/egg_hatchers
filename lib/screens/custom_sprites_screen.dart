import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/custom_sprite_data.dart';
import '../services/custom_sprite_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../widgets/custom_sprite_preview.dart';
import '../widgets/game_background.dart';
import 'sprite_editor_screen.dart';

/// Lists all animals so the player can create or edit custom sprites.
class CustomSpritesScreen extends StatelessWidget {
  const CustomSpritesScreen({
    super.key,
    required this.preferences,
    required this.customSprites,
  });

  final PreferencesService preferences;
  final CustomSpriteService customSprites;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([preferences, customSprites]),
      builder: (context, _) {
        final theme = preferences.selectedTheme;
        final animals = List<Animal>.from(GameData.animals)
          ..sort((a, b) {
            final rarity = b.rarity.sortOrder.compareTo(a.rarity.sortOrder);
            if (rarity != 0) return rarity;
            return a.name.compareTo(b.name);
          });

        return Scaffold(
          backgroundColor: theme.scaffoldColor,
          appBar: AppBar(
            title: const Text(
              '🎨 Custom Sprites',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor: theme.appBarColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: GameBackground(
            theme: theme,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Draw your own 16×16 sprites for any animal!',
                    style: GameTheme.sectionTitle(theme, size: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Custom art is saved on this device only.',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.cardTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final animal in animals) ...[
                    _AnimalSpriteTile(
                      animal: animal,
                      theme: theme,
                      hasCustom: customSprites.hasCustomSprite(animal.id),
                      customSprite: customSprites.getSprite(animal.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpriteEditorScreen(
                            animal: animal,
                            theme: theme,
                            customSprites: customSprites,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnimalSpriteTile extends StatelessWidget {
  const _AnimalSpriteTile({
    required this.animal,
    required this.theme,
    required this.hasCustom,
    required this.customSprite,
    required this.onTap,
  });

  final Animal animal;
  final BackgroundTheme theme;
  final bool hasCustom;
  final CustomSpriteData? customSprite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        child: Container(
          decoration: GameTheme.cardDecoration(theme),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.cardBorderColor.withValues(alpha: 0.45),
                  ),
                ),
                child: CustomSpritePreview(
                  customSprite: customSprite,
                  spritePath: animal.spritePath,
                  fallbackEmoji: animal.emoji,
                  size: 44,
                  emojiFontSize: 30,
                  semanticLabel: animal.name,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: theme.cardTextPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCustom ? '✏️ Custom sprite saved' : 'Tap to draw',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasCustom
                            ? theme.primaryColor
                            : theme.cardTextSecondaryColor,
                        fontWeight:
                            hasCustom ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.cardTextSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
