import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/game_background.dart';

/// Lets the player pick and preview background themes.
class BackgroundsScreen extends StatelessWidget {
  const BackgroundsScreen({super.key, required this.preferences});

  final PreferencesService preferences;

  Future<void> _selectTheme(BuildContext context, BackgroundTheme theme) async {
    await preferences.setBackgroundTheme(theme);
    if (context.mounted) {
      showGameSnackBar(
        context,
        message: 'Background changed to ${theme.name}!',
        backgroundColor: const Color(0xFF4DB6AC),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        final selected = preferences.selectedTheme;
        final isDark = selected.isDark;

        return Scaffold(
          backgroundColor:
              isDark ? selected.colors.first : GameTheme.cream,
          appBar: AppBar(
            title: const Text(
              '🎨 Backgrounds',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            centerTitle: true,
            backgroundColor: const Color(0xFF7E57C2),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: GameBackground(
            theme: selected,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Pick a cozy background for your hatchery!',
                    style: GameTheme.sectionTitle(
                      isDark: isDark,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final theme in BackgroundThemes.all) ...[
                    _ThemeOptionCard(
                      theme: theme,
                      isSelected: theme.id == selected.id,
                      isDarkBackground: isDark,
                      onTap: () => _selectTheme(context, theme),
                    ),
                    const SizedBox(height: 12),
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

class _ThemeOptionCard extends StatelessWidget {
  const _ThemeOptionCard({
    required this.theme,
    required this.isSelected,
    required this.isDarkBackground,
    required this.onTap,
  });

  final BackgroundTheme theme;
  final bool isSelected;
  final bool isDarkBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        child: Container(
          decoration: GameTheme.cardDecoration(
            isDark: isDarkBackground,
            borderColor: isSelected ? const Color(0xFF4DB6AC) : null,
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: theme.gradient,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: GameTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      theme.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: GameTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4DB6AC).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF4DB6AC)),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF4DB6AC),
                    size: 22,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
