import 'package:flutter/material.dart';

import 'models/background_theme.dart';
import 'screens/hatchery_screen.dart';
import 'services/custom_egg_service.dart';
import 'services/custom_sprite_service.dart';
import 'services/game_service.dart';
import 'services/preferences_service.dart';
import 'services/sprite_rating_service.dart';
import 'services/sprite_reference_overlay_service.dart';
import 'widgets/game_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EggHatchersApp());
}

class EggHatchersApp extends StatefulWidget {
  const EggHatchersApp({super.key});

  @override
  State<EggHatchersApp> createState() => _EggHatchersAppState();
}

class _EggHatchersAppState extends State<EggHatchersApp>
    with WidgetsBindingObserver {
  final GameService _game = GameService();
  final PreferencesService _preferences = PreferencesService();
  final CustomSpriteService _customSprites = CustomSpriteService();
  final CustomEggService _customEggs = CustomEggService();
  final SpriteRatingService _spriteRating = SpriteRatingService();
  final SpriteReferenceOverlayService _referenceOverlay =
      SpriteReferenceOverlayService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _game.addListener(_onGameChanged);
    _preferences.addListener(_onGameChanged);
    _customSprites.addListener(_onGameChanged);
    _customEggs.addListener(_onGameChanged);
    _spriteRating.addListener(_onGameChanged);
    _referenceOverlay.addListener(_onGameChanged);
  }

  Future<void> _initialize() async {
    await Future.wait([
      _game.initialize(),
      _preferences.initialize(),
      _customSprites.initialize(),
      _customEggs.initialize(),
      _spriteRating.initialize(),
      _referenceOverlay.initialize(),
    ]);
    if (mounted) setState(() {});
  }

  void _onGameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _game.save();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _game.removeListener(_onGameChanged);
    _preferences.removeListener(_onGameChanged);
    _customSprites.removeListener(_onGameChanged);
    _customEggs.removeListener(_onGameChanged);
    _spriteRating.removeListener(_onGameChanged);
    _referenceOverlay.removeListener(_onGameChanged);
    _game.dispose();
    super.dispose();
  }

  bool get _isReady =>
      _game.isInitialized &&
      _preferences.isInitialized &&
      _customSprites.isInitialized &&
      _customEggs.isInitialized &&
      _spriteRating.isInitialized &&
      _referenceOverlay.isInitialized;

  @override
  Widget build(BuildContext context) {
    final theme = _isReady
        ? _preferences.selectedTheme
        : BackgroundThemes.defaultTheme;

    return MaterialApp(
      title: 'Egg Hatchers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: theme.primaryColor,
          brightness: theme.isDark ? Brightness.dark : Brightness.light,
        ),
        scaffoldBackgroundColor: theme.scaffoldColor,
        canvasColor: theme.scaffoldColor,
        dialogTheme: DialogThemeData(backgroundColor: theme.cardColor),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      builder: (context, child) {
        return ColoredBox(
          color: theme.scaffoldColor,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: _isReady
          ? HatcheryScreen(
              game: _game,
              preferences: _preferences,
              customSprites: _customSprites,
              customEggs: _customEggs,
              spriteRating: _spriteRating,
              referenceOverlay: _referenceOverlay,
            )
          : const _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = BackgroundThemes.defaultTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      body: GameBackground(
        theme: theme,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🐣', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                'Egg Hatchers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 24),
              CircularProgressIndicator(color: theme.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
