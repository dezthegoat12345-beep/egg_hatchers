import 'package:flutter/material.dart';

import 'screens/hatchery_screen.dart';
import 'services/game_service.dart';

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
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
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
    return const Scaffold(
      backgroundColor: Color(0xFFFFF8E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🐣', style: TextStyle(fontSize: 72)),
            SizedBox(height: 16),
            Text(
              'Egg Hatchers',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.teal),
          ],
        ),
      ),
    );
  }
}
