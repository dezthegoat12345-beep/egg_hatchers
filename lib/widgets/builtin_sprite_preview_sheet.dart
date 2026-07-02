import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/animal_sprite_theme.dart';
import '../models/background_theme.dart';
import '../models/custom_sprite_data.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../widgets/custom_sprite_preview.dart';
import '../widgets/pixel_sprite.dart';

/// Large built-in / custom sprite preview for inspecting Animal Style art.
void showBuiltinSpritePreviewSheet({
  required BuildContext context,
  required Animal animal,
  required PreferencesService preferences,
  CustomSpriteData? customSprite,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _BuiltinSpritePreviewSheet(
      animal: animal,
      preferences: preferences,
      customSprite: customSprite,
    ),
  );
}

class _BuiltinSpritePreviewSheet extends StatelessWidget {
  const _BuiltinSpritePreviewSheet({
    required this.animal,
    required this.preferences,
    this.customSprite,
  });

  final Animal animal;
  final PreferencesService preferences;
  final CustomSpriteData? customSprite;

  static const double _largePreviewSize = 160;

  @override
  Widget build(BuildContext context) {
    final theme = preferences.selectedTheme;
    final hasCustom =
        customSprite != null && customSprite!.hasVisiblePixels;

    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 480,
              maxHeight: MediaQuery.sizeOf(context).height * 0.82,
            ),
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(GameTheme.cardRadius),
              border: Border.all(color: theme.cardBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.cardTextPrimaryColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.cardTextSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Animal Style: ${preferences.animalSpriteTheme.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.cardTextSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PreviewPanel(
                    theme: theme,
                    label: 'Built-in Style',
                    subtitle: preferences.animalSpriteTheme.id ==
                            AnimalSpriteThemes.retroPixel.id
                        ? 'Retro Pixel (crisp block scaling)'
                        : 'Classic PNG',
                    child: CustomSpritePreview(
                      animalId: animal.id,
                      spritePath: animal.spritePath,
                      fallbackEmoji: animal.emoji,
                      size: _largePreviewSize,
                      emojiFontSize: _largePreviewSize * 0.55,
                      semanticLabel: '${animal.name} built-in preview',
                    ),
                  ),
                  if (hasCustom) ...[
                    const SizedBox(height: 16),
                    _PreviewPanel(
                      theme: theme,
                      label: 'Your Custom Sprite',
                      subtitle: '16×16 custom art (overrides in game)',
                      child: PixelSprite(
                        data: customSprite!,
                        size: _largePreviewSize,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Tap outside or ✕ to close. Tap the row to open the sprite editor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.cardTextSecondaryColor,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.theme,
    required this.label,
    required this.subtitle,
    required this.child,
  });

  final BackgroundTheme theme;
  final String label;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameTheme.cardDecoration(theme),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            label,
            style: GameTheme.sectionTitle(theme, size: 15),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.cardTextSecondaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 180,
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.cardBorderColor.withValues(alpha: 0.5),
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
