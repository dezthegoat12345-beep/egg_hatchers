import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/background_theme.dart';
import '../navigation/app_page_route.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import '../utils/collection_quest_logic.dart';
import '../widgets/game_background.dart';
import '../widgets/hatch_dialog.dart';
import '../widgets/phone_width_layout.dart';
import 'developer_screen.dart';

/// Player-facing secret screen unlocked by tapping the Hatchery coin 3 times.
class SecretToolsScreen extends StatelessWidget {
  const SecretToolsScreen({
    super.key,
    required this.game,
    required this.customSprites,
    required this.theme,
  });

  final GameService game;
  final CustomSpriteService customSprites;
  final BackgroundTheme theme;

  Future<void> _claimSecretVoidEgg(BuildContext context) async {
    final result = game.claimSecretVoidEggReward();
    if (result == null || !context.mounted) return;

    final voidEgg = GameData.eggById('void') ?? GameData.eggById('space');
    if (voidEgg == null) return;

    await HatchDialog.show(
      context,
      egg: voidEgg,
      result: result,
      theme: theme,
      customSprites: customSprites,
      revealedTitle: 'Secret Void Egg!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: game,
      builder: (context, _) {
        final collected = CollectionQuestLogic.collectedBaseAnimalCount(game.state);
        final total = CollectionQuestLogic.totalBaseAnimalCount;
        final claimed = game.secretSpaceEggClaimed;

        return ReturnToHatcheryPopScope(
          theme: theme,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PhoneWidthAppBar(
              title: '🔐 Secret Hatchery',
              titleStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              backgroundColor: theme.appBarColor,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leading: ReturnToHatcheryBackButton(
                theme: theme,
                color: Colors.white,
              ),
            ),
            body: GameBackground(
              theme: theme,
              child: PhoneWidthLayout(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: GameTheme.panelDecoration(theme),
                      child: Column(
                        children: [
                          const Text('🥚✨', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'You found the secret hatchery!',
                            textAlign: TextAlign.center,
                            style: GameTheme.sectionTitle(theme, size: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Shhh… only curious hatchers make it here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.cardTextSecondaryColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: GameTheme.panelDecoration(theme),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your stats',
                            style: GameTheme.sectionTitle(theme, size: 16),
                          ),
                          const SizedBox(height: 12),
                          _StatRow(
                            theme: theme,
                            icon: '🔄',
                            label: 'Rebirth level',
                            value: '${game.rebirthLevel}',
                          ),
                          const SizedBox(height: 8),
                          _StatRow(
                            theme: theme,
                            icon: '🐾',
                            label: 'Collection',
                            value: '$collected / $total animals',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: GameTheme.panelDecoration(theme),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Secret reward',
                            style: GameTheme.sectionTitle(theme, size: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Free Void Egg with 3x luck.',
                            style: TextStyle(
                              color: theme.cardTextSecondaryColor,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          FilledButton.icon(
                            onPressed: claimed
                                ? null
                                : () => _claimSecretVoidEgg(context),
                            icon: Text(claimed ? '✅' : '🚀'),
                            label: Text(
                              claimed
                                  ? 'Secret Void Egg claimed'
                                  : 'Claim Secret Void Egg',
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.secondaryColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  theme.panelAccentColor.withValues(alpha: 0.35),
                              disabledForegroundColor:
                                  theme.cardTextSecondaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (kDebugMode) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          pushDevToolsRoute(
                            context,
                            builder: (_) => DeveloperScreen(
                              game: game,
                              customSprites: customSprites,
                              returnTheme: theme,
                            ),
                          );
                        },
                        icon: const Icon(Icons.build_outlined, size: 18),
                        label: const Text('Developer Tools (Debug)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.cardTextSecondaryColor,
                          side: BorderSide(
                            color: theme.panelAccentColor.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ],
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

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BackgroundTheme theme;
  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.cardTextSecondaryColor,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.cardTextPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
