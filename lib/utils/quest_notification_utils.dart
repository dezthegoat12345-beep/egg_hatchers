import 'package:flutter/material.dart';

import '../screens/quests_screen.dart';
import '../services/game_service.dart';
import '../services/preferences_service.dart';
import 'snackbar_utils.dart';

/// Shows a deferred or immediate pending quest completion notification.
void showPendingQuestCompletionNotification(
  BuildContext context, {
  required GameService game,
  required PreferencesService preferences,
}) {
  final message =
      game.releaseDeferredQuestNotification() ??
      game.consumePendingQuestNotification();
  if (message == null) return;

  showQuestCompletionSnackBar(
    context,
    message: message,
    backgroundColor: preferences.selectedTheme.secondaryColor,
    onViewQuests: () => openQuestsScreen(
      context,
      game: game,
      preferences: preferences,
    ),
  );
}

void openQuestsScreen(
  BuildContext context, {
  required GameService game,
  required PreferencesService preferences,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => QuestsScreen(
        game: game,
        preferences: preferences,
      ),
    ),
  );
}
