import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/preferences_service.dart';
import '../utils/snackbar_utils.dart';

/// Listens for pending quest completion messages and shows compact SnackBars.
class QuestNotificationListener extends StatefulWidget {
  const QuestNotificationListener({
    super.key,
    required this.game,
    required this.preferences,
    required this.child,
  });

  final GameService game;
  final PreferencesService preferences;
  final Widget child;

  @override
  State<QuestNotificationListener> createState() =>
      _QuestNotificationListenerState();
}

class _QuestNotificationListenerState extends State<QuestNotificationListener> {
  @override
  void initState() {
    super.initState();
    widget.game.addListener(_showPendingNotification);
  }

  @override
  void dispose() {
    widget.game.removeListener(_showPendingNotification);
    super.dispose();
  }

  void _showPendingNotification() {
    final message = widget.game.consumePendingQuestNotification();
    if (message == null || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showGameSnackBar(
        context,
        message: message,
        backgroundColor: widget.preferences.selectedTheme.secondaryColor,
      );
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
