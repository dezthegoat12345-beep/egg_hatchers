import 'package:flutter/material.dart';

import '../models/hatch_result.dart';
import '../models/egg.dart';
import 'animal_card.dart';

/// Animated dialog shown after buying an egg to reveal the hatched animal.
class HatchDialog extends StatefulWidget {
  const HatchDialog({
    super.key,
    required this.egg,
    required this.result,
  });

  final Egg egg;
  final HatchResult result;

  static Future<void> show(
    BuildContext context, {
    required Egg egg,
    required HatchResult result,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => HatchDialog(egg: egg, result: result),
    );
  }

  @override
  State<HatchDialog> createState() => _HatchDialogState();
}

class _HatchDialogState extends State<HatchDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shakeAnimation;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 0.0), weight: 1),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        setState(() => _revealed = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.result.mutation.hatchMessage(widget.result.animal);
    final isMutated = !widget.result.mutation.isNormal;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _revealed ? (isMutated ? 'Mutation!' : 'It hatched!') : 'Hatching...',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isMutated && _revealed
                    ? Colors.deepPurple
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            if (_revealed)
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isMutated ? FontWeight.bold : FontWeight.normal,
                  color: isMutated ? Colors.deepPurple.shade700 : Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
            const SizedBox(height: 20),
            if (!_revealed)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: Transform.scale(
                      scale: _scaleAnimation.value.clamp(0.8, 1.3),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.egg.emoji,
                  style: const TextStyle(fontSize: 80),
                ),
              )
            else ...[
              Text(
                widget.result.mutation.displayEmoji(widget.result.animal),
                style: const TextStyle(fontSize: 80),
              ),
              const SizedBox(height: 12),
              AnimalCard(
                animal: widget.result.animal,
                mutation: widget.result.mutation,
                compact: true,
              ),
            ],
            const SizedBox(height: 20),
            if (_revealed)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: isMutated ? Colors.deepPurple : Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isMutated ? 'Amazing!' : 'Awesome!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
