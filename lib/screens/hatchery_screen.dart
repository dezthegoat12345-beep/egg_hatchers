import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/custom_egg_service.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../services/sprite_rating_service.dart';
import '../services/sprite_reference_overlay_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/coin_header.dart';
import '../widgets/game_background.dart';
import '../widgets/luck_panel.dart';
import '../widgets/owned_animal_list.dart';
import '../widgets/phone_width_layout.dart';
import '../widgets/quest_notification_listener.dart';
import '../widgets/rebirth_panel.dart';
import 'backgrounds_screen.dart';
import 'collection_screen.dart';
import 'custom_sprites_screen.dart';
import 'developer_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';

/// Main home screen: coins, income, owned animals, and navigation.
class HatcheryScreen extends StatefulWidget {
  const HatcheryScreen({
    super.key,
    required this.game,
    required this.preferences,
    required this.customSprites,
    required this.customEggs,
    required this.spriteRating,
    required this.referenceOverlay,
  });

  final GameService game;
  final PreferencesService preferences;
  final CustomSpriteService customSprites;
  final CustomEggService customEggs;
  final SpriteRatingService spriteRating;
  final SpriteReferenceOverlayService referenceOverlay;

  @override
  State<HatcheryScreen> createState() => _HatcheryScreenState();
}

class _HatcheryScreenState extends State<HatcheryScreen> {
  int _coinTapCount = 0;

  GameService get game => widget.game;
  PreferencesService get preferences => widget.preferences;
  CustomSpriteService get customSprites => widget.customSprites;
  CustomEggService get customEggs => widget.customEggs;

  void _onCoinTap() {
    _coinTapCount++;
    if (_coinTapCount >= 3) {
      _coinTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeveloperScreen(
            game: game,
            customSprites: customSprites,
          ),
        ),
      );
    }
  }

  void _handleUpgrade(
    BuildContext context,
    String animalId,
    String mutationId,
    String displayName,
  ) {
    final newLevel = game.upgradeAnimal(animalId, mutationId);
    if (newLevel != null) {
      showGameSnackBar(
        context,
        message: '$displayName upgraded to Level $newLevel!',
        backgroundColor: Colors.teal.shade400,
      );
    } else {
      showGameSnackBar(
        context,
        message: 'Not enough coins to upgrade $displayName.',
        backgroundColor: Colors.red.shade400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, preferences, customSprites]),
      builder: (context, _) {
        final bg = preferences.selectedTheme;

        return QuestNotificationListener(
          game: game,
          preferences: preferences,
          child: Scaffold(
          backgroundColor: bg.scaffoldColor,
          extendBody: true,
          appBar: PhoneWidthAppBar(
            title: '🐣 Egg Hatchers',
            titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            backgroundColor: bg.appBarColor,
            foregroundColor: Colors.white,
          ),
          body: GameBackground(
            theme: bg,
            child: PhoneWidthLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CoinHeader(
                    coins: game.coins,
                    coinsPerSecond: game.coinsPerSecond,
                    lifetimeCoinsEarned: game.lifetimeCoinsEarned,
                    onCoinTap: _onCoinTap,
                    theme: bg,
                  ),
                  const SizedBox(height: 14),
                  LuckPanel(game: game, theme: bg),
                  const SizedBox(height: 14),
                  RebirthPanel(game: game, theme: bg),
                  const SizedBox(height: 18),
                  _HatcheryNavGrid(
                              theme: bg,
                              items: [
                                _HatcheryNavItem(
                                  label: '🛒 Shop',
                                  color: bg.secondaryColor,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ShopScreen(
                                        game: game,
                                        preferences: preferences,
                                        customSprites: customSprites,
                                        customEggs: customEggs,
                                      ),
                                    ),
                                  ),
                                ),
                                _HatcheryNavItem(
                                  label: '🎯 Quests',
                                  color: bg.panelAccentColor,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuestsScreen(
                                        game: game,
                                        preferences: preferences,
                                      ),
                                    ),
                                  ),
                                ),
                                _HatcheryNavItem(
                                  label: '📚 Collection',
                                  color: bg.primaryColor,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CollectionScreen(
                                        game: game,
                                        preferences: preferences,
                                        customSprites: customSprites,
                                      ),
                                    ),
                                  ),
                                ),
                                _HatcheryNavItem(
                                  label: '🎨 Themes',
                                  color: bg.appBarColor,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BackgroundsScreen(
                                        preferences: preferences,
                                        customSprites: customSprites,
                                        game: game,
                                        spriteRating: widget.spriteRating,
                                        referenceOverlay: widget.referenceOverlay,
                                      ),
                                    ),
                                  ),
                                ),
                                _HatcheryNavItem(
                                  label: '✏️ Sprites',
                                  color: bg.secondaryColor.withValues(alpha: 0.85),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CustomSpritesScreen(
                                        preferences: preferences,
                                        customSprites: customSprites,
                                        game: game,
                                        spriteRating: widget.spriteRating,
                                        referenceOverlay: widget.referenceOverlay,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Your Animals',
                              style: GameTheme.sectionTitle(bg),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: game.ownedAnimals.isEmpty
                                  ? _EmptyHatchery(theme: bg)
                                  : OwnedAnimalList(
                                      game: game,
                                      theme: bg,
                                      compact: true,
                                      customSprites: customSprites,
                                      onUpgrade: (animalId, mutationId, name) =>
                                          _handleUpgrade(
                                        context,
                                        animalId,
                                        mutationId,
                                        name,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
        );
      },
    );
  }
}

class _HatcheryNavItem {
  const _HatcheryNavItem({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _HatcheryNavGrid extends StatelessWidget {
  const _HatcheryNavGrid({
    required this.theme,
    required this.items,
  });

  final BackgroundTheme theme;
  final List<_HatcheryNavItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final useTwoColumns = constraints.maxWidth >= 340;
        final itemWidth = useTwoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _NavButton(
                  label: item.label,
                  theme: theme,
                  color: item.color,
                  onTap: item.onTap,
                  compact: useTwoColumns,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.theme,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final BackgroundTheme theme;
  final Color color;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: GameTheme.filledButton(
        theme,
        color: color,
        height: compact ? 50 : 56,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: compact ? 16 : 18),
      ),
    );
  }
}

class _EmptyHatchery extends StatelessWidget {
  const _EmptyHatchery({required this.theme});

  final BackgroundTheme theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: GameTheme.cardDecoration(theme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥚', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 14),
            Text(
              'No animals yet.\nHatch your first egg!',
              textAlign: TextAlign.center,
              style: GameTheme.emptyStateTitle(theme),
            ),
            const SizedBox(height: 8),
            Text(
              'Visit the Shop to get started 🐣',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.cardTextSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
