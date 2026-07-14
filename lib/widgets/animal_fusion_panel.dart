import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../models/background_theme.dart';
import '../models/owned_animal.dart';
import '../services/custom_sprite_service.dart';
import '../services/game_service.dart';
import '../theme/game_theme.dart';
import '../utils/animal_fusion_logic.dart';
import '../utils/ui_sound.dart';
import 'game_sprite.dart';

/// Animal Fusion section for the Collection screen.
class AnimalFusionPanel extends StatelessWidget {
  const AnimalFusionPanel({
    super.key,
    required this.game,
    required this.theme,
    required this.customSprites,
    this.tutorialSectionKey,
  });

  final GameService game;
  final BackgroundTheme theme;
  final CustomSpriteService customSprites;
  final Key? tutorialSectionKey;

  static void showHelpDialog(BuildContext context, BackgroundTheme theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        ),
        title: Text(
          'How Fusion Works',
          style: TextStyle(
            color: theme.cardTextPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Fuse 2 matching animals with the same mutation.\n\n'
          'Fusion has an 80% success chance.\n\n'
          'If it fails, both animals are lost.\n\n'
          'Successful fusion upgrades the mutation.\n\n'
          'Sometimes Fusion jumps ahead two mutation levels.\n\n'
          'Shadow and Boss Mutation animals cannot be fused.\n\n'
          'Elite, Secret Reward, and battling animals are protected.',
          style: TextStyle(
            color: theme.cardTextSecondaryColor,
            fontSize: 14,
            height: 1.45,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  List<OwnedAnimal> _fusionCandidates() {
    return game.ownedAnimals
        .where(AnimalFusionLogic.shouldShowInFusionList)
        .toList()
      ..sort((a, b) {
        final animalA = GameData.animalById(a.animalId)?.name ?? a.animalId;
        final animalB = GameData.animalById(b.animalId)?.name ?? b.animalId;
        final nameCmp = animalA.compareTo(animalB);
        if (nameCmp != 0) return nameCmp;
        final indexA = AnimalFusionLogic.fusionLadder.indexOf(a.mutationId);
        final indexB = AnimalFusionLogic.fusionLadder.indexOf(b.mutationId);
        return indexA.compareTo(indexB);
      });
  }

  Future<void> _confirmAndFuse(BuildContext context, OwnedAnimal owned) async {
    final animal = GameData.animalById(owned.animalId);
    final inputMutation =
        GameData.mutationById(owned.mutationId) ?? GameData.mutations.first;
    if (animal == null) return;

    final inputName = inputMutation.fullName(animal);
    final primaryName = AnimalFusionLogic.successResultLabel(
      owned.mutationId,
      animal,
    );
    final luckyName = AnimalFusionLogic.luckyResultLabel(owned.mutationId, animal);
    final successPct = (AnimalFusionLogic.successChance * 100).round();
    final failPct = (AnimalFusionLogic.failureChance * 100).round();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GameTheme.cardRadius),
        ),
        title: Text(
          'Fuse 2 $inputName?',
          style: TextStyle(
            color: theme.cardTextPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consumes 2 $inputName.',
              style: TextStyle(color: theme.cardTextSecondaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              '$successPct% chance: $primaryName',
              style: TextStyle(
                color: theme.cardTextPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$failPct% chance: Fusion fails and both are lost.',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (luckyName != null) ...[
              const SizedBox(height: 6),
              Text(
                'Rare lucky chance: $luckyName!',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.cardTextSecondaryColor),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Fuse'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    UiSound.confirm(context);
    final outcome = game.fuseAnimals(owned);
    if (outcome == null || !context.mounted) return;

    if (outcome.succeeded) {
      if (outcome.wasLucky) {
        UiSound.rewardBigTriumph(context);
      } else {
        UiSound.rewardTriumph(context);
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _FusionResultDialog(
          theme: theme,
          customSprites: customSprites,
          outcome: outcome,
        ),
      );
    } else {
      UiSound.locked(context);
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _FusionFailureDialog(
          theme: theme,
          inputDisplayName: outcome.inputDisplayName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _fusionCandidates();

    return Container(
      key: tutorialSectionKey,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: GameTheme.cardDecoration(
        theme,
        borderColor: theme.primaryColor.withValues(alpha: 0.55),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '⚗️ Fusion',
                style: TextStyle(
                  color: theme.cardTextPrimaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              IconButton(
                tooltip: 'How Fusion Works',
                onPressed: () => showHelpDialog(context, theme),
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: theme.cardTextSecondaryColor,
                  size: 22,
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const Spacer(),
              Text(
                'Fuse 2 → 1',
                style: TextStyle(
                  color: theme.cardTextSecondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Fuse 2 matching animals with the same mutation to upgrade them.',
            style: TextStyle(
              color: theme.cardTextSecondaryColor,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '80% success · 20% fail · Rare lucky upgrade chance!\n'
            'Normal → Golden → Rainbow → Shadow',
            style: TextStyle(
              color: theme.cardTextSecondaryColor,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          if (candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No animals ready to fuse yet. Hatch duplicates and come back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.cardTextSecondaryColor,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: candidates.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return _FusionRow(
                    owned: candidates[index],
                    theme: theme,
                    customSprites: customSprites,
                    inBattle: game.isOwnedStackAutoBattling(candidates[index]),
                    onFuse: () => _confirmAndFuse(context, candidates[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FusionRow extends StatelessWidget {
  const _FusionRow({
    required this.owned,
    required this.theme,
    required this.customSprites,
    required this.inBattle,
    required this.onFuse,
  });

  final OwnedAnimal owned;
  final BackgroundTheme theme;
  final CustomSpriteService customSprites;
  final bool inBattle;
  final VoidCallback onFuse;

  @override
  Widget build(BuildContext context) {
    final animal = GameData.animalById(owned.animalId);
    if (animal == null) return const SizedBox.shrink();

    final mutation =
        GameData.mutationById(owned.mutationId) ?? GameData.mutations.first;
    final displayName = mutation.fullName(animal);
    final canFuse = AnimalFusionLogic.canFuseStack(owned, inBattle: inBattle);
    final blockReason =
        AnimalFusionLogic.blockReasonText(owned, inBattle: inBattle);
    final successName =
        AnimalFusionLogic.successResultLabel(owned.mutationId, animal);
    final luckyName =
        AnimalFusionLogic.luckyResultLabel(owned.mutationId, animal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canFuse
              ? theme.primaryColor.withValues(alpha: 0.45)
              : theme.cardTextSecondaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          GameSprite(
            customSprite: customSprites.getDisplaySprite(animal.id),
            animalId: animal.id,
            spritePath: animal.spritePath,
            fallbackEmoji: mutation.displayEmoji(animal),
            size: 44,
            semanticLabel: displayName,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.cardTextPrimaryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Qty: ${owned.quantity}',
                  style: TextStyle(
                    color: theme.cardTextSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                if (owned.mutationId != 'shadow' && owned.mutationId != 'boss')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '80% success · 20% fail',
                        style: TextStyle(
                          color: theme.cardTextSecondaryColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Success: $successName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.cardTextSecondaryColor,
                          fontSize: 11,
                        ),
                      ),
                      if (luckyName != null)
                        Text(
                          'Lucky: $luckyName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.amber.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      Text(
                        'Fail: lose both',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                if (blockReason != null)
                  Text(
                    blockReason,
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: canFuse ? onFuse : null,
            style: FilledButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 36),
            ),
            child: const Text('Fuse 2'),
          ),
        ],
      ),
    );
  }
}

class _FusionFailureDialog extends StatefulWidget {
  const _FusionFailureDialog({
    required this.theme,
    required this.inputDisplayName,
  });

  final BackgroundTheme theme;
  final String inputDisplayName;

  @override
  State<_FusionFailureDialog> createState() => _FusionFailureDialogState();
}

class _FusionFailureDialogState extends State<_FusionFailureDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
      ),
      title: Text(
        'Fusion failed!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red.shade700,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = 0.7 + sin(_controller.value * pi * 2) * 0.15;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Opacity(
                opacity: (1 - _controller.value * 0.35).clamp(0.4, 1.0),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade700.withValues(alpha: 0.35 * pulse),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade900.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 52,
                    color: Colors.red.shade300.withValues(alpha: pulse),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Both ${widget.inputDisplayName}s were lost.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.theme.cardTextPrimaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _FusionResultDialog extends StatefulWidget {
  const _FusionResultDialog({
    required this.theme,
    required this.customSprites,
    required this.outcome,
  });

  final BackgroundTheme theme;
  final CustomSpriteService customSprites;
  final AnimalFusionOutcome outcome;

  @override
  State<_FusionResultDialog> createState() => _FusionResultDialogState();
}

class _FusionResultDialogState extends State<_FusionResultDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _glowColor() {
    return switch (widget.outcome.resultMutationId) {
      'golden' => Colors.amber.shade600,
      'rainbow' => Colors.purple.shade400,
      'shadow' => Colors.deepPurple.shade700,
      _ => widget.theme.primaryColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final animal = GameData.animalById(widget.outcome.animalId);
    if (animal == null || widget.outcome.displayName == null) {
      return AlertDialog(content: Text(widget.outcome.displayName ?? 'Fusion'));
    }

    final mutation =
        GameData.mutationById(widget.outcome.resultMutationId!) ??
            GameData.mutations.first;
    final glow = _glowColor();
    final lucky = widget.outcome.wasLucky;

    return AlertDialog(
      backgroundColor: widget.theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GameTheme.cardRadius),
      ),
      title: Text(
        lucky ? 'Lucky Fusion!' : 'Fusion success!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: lucky ? Colors.amber.shade700 : widget.theme.cardTextPrimaryColor,
          fontWeight: FontWeight.w900,
        ),
      ),
      content: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = 0.85 + sin(_controller.value * pi * 2) * 0.15;
          final scale = 0.7 + _controller.value * 0.35;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: scale * (lucky ? 1.08 : 1.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glow.withValues(alpha: 0.55 * pulse),
                        blurRadius: lucky ? 36 : 24,
                        spreadRadius: lucky ? 6 : 2,
                      ),
                    ],
                  ),
                  child: GameSprite(
                    customSprite:
                        widget.customSprites.getDisplaySprite(animal.id),
                    animalId: animal.id,
                    spritePath: animal.spritePath,
                    fallbackEmoji: mutation.displayEmoji(animal),
                    size: lucky ? 88 : 76,
                    semanticLabel: widget.outcome.displayName,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Created ${widget.outcome.displayName}!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.theme.cardTextPrimaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            backgroundColor: widget.theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Nice!'),
        ),
      ],
    );
  }
}