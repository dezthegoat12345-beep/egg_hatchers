import 'package:flutter/material.dart';

import 'models/background_theme.dart';
import 'screens/hatchery_screen.dart';
import 'services/game_service.dart';
import 'services/preferences_service.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _game.addListener(_onGameChanged);
    _preferences.addListener(_onGameChanged);
  }

  Future<void> _initialize() async {
    await Future.wait([
      _game.initialize(),
      _preferences.initialize(),
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
    _game.dispose();
    super.dispose();
  }

  bool get _isReady => _game.isInitialized && _preferences.isInitialized;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egg Hatchers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: BackgroundThemes.defaultTheme.scaffoldColor,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: _isReady
          ? HatcheryScreen(game: _game, preferences: _preferences)
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
