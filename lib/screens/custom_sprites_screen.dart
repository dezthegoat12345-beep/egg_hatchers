import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/custom_sprite_data.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../services/sprite_rating_service.dart';
import '../services/sprite_reference_overlay_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/custom_sprite_preview.dart';
import '../widgets/game_background.dart';
import '../widgets/phone_width_layout.dart';
import 'sprite_editor_screen.dart';

/// Lists all animals so the player can create or edit custom sprites.
class CustomSpritesScreen extends StatelessWidget {
  const CustomSpritesScreen({
    super.key,
    required this.preferences,
    required this.customSprites,
    required this.game,
    required this.spriteRating,
    required this.referenceOverlay,
  });

  final PreferencesService preferences;
  final CustomSpriteService customSprites;
  final GameService game;
  final SpriteRatingService spriteRating;
  final SpriteReferenceOverlayService referenceOverlay;

  Future<void> _confirmResetAll(BuildContext context, BackgroundTheme theme) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        ),
        title: Text(
          'Reset All Custom Sprites?',
          style: TextStyle(
            color: theme.cardTextPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will delete all custom animal sprites and restore the '
          'original sprites. This cannot be undone.',
          style: TextStyle(
            color: theme.cardTextSecondaryColor,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.cardTextSecondaryColor),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset All'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await customSprites.resetAllCustomSprites();
    await spriteRating.clearAllClaims();
    if (!context.mounted) return;

    showGameSnackBar(
      context,
      message: 'All custom sprites reset.',
      backgroundColor: Colors.red.shade400,
    );
  }

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
            child: PhoneWidthLayout(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Text(
                    'Draw your own 16×16 sprites for any animal!',
                    style: GameTheme.sectionTitle(theme, size: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Custom sprites are saved only on this device and are '
                    'not shared online.',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.cardTextSecondaryColor,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: GameTheme.cardDecoration(theme),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Show Custom Sprites',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.cardTextPrimaryColor,
                          ),
                        ),
                        subtitle: Text(
                          customSprites.showCustomSprites
                              ? 'Custom art appears in the game'
                              : 'Custom art is hidden (still saved)',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.cardTextSecondaryColor,
                          ),
                        ),
                        value: customSprites.showCustomSprites,
                        activeThumbColor: theme.primaryColor,
                        onChanged: (value) =>
                            customSprites.setShowCustomSprites(value),
                      ),
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
                            game: game,
                            spriteRating: spriteRating,
                            referenceOverlay: referenceOverlay,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmResetAll(context, theme),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red.shade700,
                    ),
                    label: Text(
                      'Reset All Custom Sprites',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: BorderSide(color: Colors.red.shade300),
                      backgroundColor: Colors.red.shade50.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
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
