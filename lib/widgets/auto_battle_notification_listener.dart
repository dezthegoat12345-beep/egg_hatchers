import 'package:flutter/material.dart';

import '../models/background_theme.dart';
import '../services/game_service.dart';
import '../utils/snackbar_utils.dart';

/// Shows snackbars when a background auto battle completes.
class AutoBattleNotificationListener extends StatefulWidget {
  const AutoBattleNotificationListener({
    super.key,
    required this.game,
    required this.theme,
    required this.child,
  });

  final GameService game;
  final BackgroundTheme theme;
  final Widget child;

  @override
  State<AutoBattleNotificationListener> createState() =>
      _AutoBattleNotificationListenerState();
}

class _AutoBattleNotificationListenerState
    extends State<AutoBattleNotificationListener> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_showPendingNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingNotification();
    });
  }

  @override
  void dispose() {
    widget.game.removeListener(_showPendingNotification);
    super.dispose();
  }

  void _showPendingNotification() {
    final summary = widget.game.consumePendingAutoBattleCompletion();
    if (summary == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameSnackBar(
        context,
        message: summary.notificationMessage,
        backgroundColor: widget.theme.secondaryColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
