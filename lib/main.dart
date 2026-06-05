import 'package:flutter/material.dart';

import 'screens/hatchery_screen.dart';
import 'services/game_service.dart';
import 'theme/game_theme.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _game.initialize();
    _game.addListener(_onGameChanged);
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
    _game.dispose();
    super.dispose();
  }

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
        scaffoldBackgroundColor: GameTheme.cream,
        useMaterial3: true,
        fontFamily: 'Roboto',
        filledButtonTheme: FilledButtonThemeData(
          style: GameTheme.filledButton(const Color(0xFF4DB6AC)),
        ),
      ),
      home: _game.isInitialized
          ? HatcheryScreen(game: _game)
          : const _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameTheme.cream,
      body: GameBackground(
        style: GameBackgroundStyle.hatchery,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🐣', style: TextStyle(fontSize: 72)),
              SizedBox(height: 16),
              Text(
                'Egg Hatchers',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: GameTheme.textDark,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: Color(0xFF4DB6AC)),
            ],
          ),
        ),
      ),
    );
  }
}
