import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../services/game_service.dart';
import '../utils/snackbar_utils.dart';

/// Hidden developer tools for testing coins and forced hatches.
class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key, required this.game});

  final GameService game;

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final _coinController = TextEditingController();
  final _lifetimeController = TextEditingController();
  late String _selectedAnimalId;
  late String _selectedMutationId;

  GameService get game => widget.game;

  List<Animal> get _sortedAnimals {
    final list = List<Animal>.from(GameData.animals);
    list.sort(
      (a, b) => GameData.compareOwnedAnimals(a.id, b.id),
    );
    return list;
  }

  @override
  void initState() {
    super.initState();
    _coinController.text = '${game.coins}';
    _lifetimeController.text = '${game.lifetimeCoinsEarned}';
    _selectedAnimalId = GameData.animals.first.id;
    _selectedMutationId = GameData.mutations.first.id;
  }

  @override
  void dispose() {
    _coinController.dispose();
    _lifetimeController.dispose();
    super.dispose();
  }

  void _setCoinsFromField() {
    final value = int.tryParse(_coinController.text.trim());
    if (value == null) {
      _showMessage('Enter a valid number.');
      return;
    }
    game.setCoins(value);
    _showMessage('Coins set to $value.');
  }

  void _addCoins(int amount) {
    game.addCoins(amount);
    _coinController.text = '${game.coins}';
    _showMessage('Added $amount coins.');
  }

  void _resetCoins() {
    game.resetCoins();
    _coinController.text = '${game.coins}';
    _showMessage('Coins reset to 250.');
  }

  void _applyForcedHatch() {
    game.setForcedNextHatch(_selectedAnimalId, _selectedMutationId);
    final animal = GameData.animalById(_selectedAnimalId)!;
    final mutation = GameData.mutationById(_selectedMutationId)!;
    _showMessage(
      'Next hatch forced: ${mutation.fullName(animal)}',
    );
    setState(() {});
  }

  void _clearForcedHatch() {
    game.clearForcedNextHatch();
    _showMessage('Forced hatch cleared.');
    setState(() {});
  }

  void _showMessage(String text) {
    showGameSnackBar(context, message: text);
  }

  @override
  Widget build(BuildContext context) {
    final forcedAnimal = game.forcedNextAnimalId != null
        ? GameData.animalById(game.forcedNextAnimalId!)
        : null;
    final forcedMutation = game.forcedNextMutationId != null
        ? GameData.mutationById(game.forcedNextMutationId!)
        : null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Developer Tools'),
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Coins'),
          Text('Current: ${game.coins} coins'),
          const SizedBox(height: 12),
          TextField(
            controller: _coinController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Coin amount',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Set Coins',
            color: Colors.teal,
            onPressed: _setCoinsFromField,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickCoinButton(
                label: '+1,000',
                onPressed: () => _addCoins(1000),
              ),
              _QuickCoinButton(
                label: '+10,000',
                onPressed: () => _addCoins(10000),
              ),
              _QuickCoinButton(
                label: '+100,000',
                onPressed: () => _addCoins(100000),
              ),
              _QuickCoinButton(
                label: '+1,000,000',
                onPressed: () => _addCoins(1000000),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Reset to 250 coins',
            color: Colors.orange,
            onPressed: _resetCoins,
          ),
          const SizedBox(height: 32),
          _SectionTitle('Lifetime Coins (Unlock Testing)'),
          Text('Current: ${game.lifetimeCoinsEarned} lifetime coins'),
          const SizedBox(height: 12),
          TextField(
            controller: _lifetimeController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Lifetime coins earned',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Set Lifetime Coins Earned',
            color: Colors.teal,
            onPressed: () {
              final value = int.tryParse(_lifetimeController.text.trim());
              if (value == null) {
                _showMessage('Enter a valid number.');
                return;
              }
              game.setLifetimeCoinsEarned(value);
              _showMessage('Lifetime coins set to $value.');
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _QuickCoinButton(
                label: '+500 lifetime',
                onPressed: () {
                  game.addLifetimeCoinsEarned(500);
                  _lifetimeController.text = '${game.lifetimeCoinsEarned}';
                  _showMessage('Added 500 lifetime coins.');
                },
              ),
              _QuickCoinButton(
                label: '+5,000 lifetime',
                onPressed: () {
                  game.addLifetimeCoinsEarned(5000);
                  _lifetimeController.text = '${game.lifetimeCoinsEarned}';
                  _showMessage('Added 5,000 lifetime coins.');
                },
              ),
              _QuickCoinButton(
                label: '+50,000 lifetime',
                onPressed: () {
                  game.addLifetimeCoinsEarned(50000);
                  _lifetimeController.text = '${game.lifetimeCoinsEarned}';
                  _showMessage('Added 50,000 lifetime coins.');
                },
              ),
              _QuickCoinButton(
                label: '+1M lifetime',
                onPressed: () {
                  game.addLifetimeCoinsEarned(1000000);
                  _lifetimeController.text = '${game.lifetimeCoinsEarned}';
                  _showMessage('Added 1,000,000 lifetime coins.');
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Unlock all eggs (750K lifetime)',
            color: Colors.indigo,
            onPressed: () {
              game.setLifetimeCoinsEarned(750000);
              _lifetimeController.text = '${game.lifetimeCoinsEarned}';
              _showMessage('All eggs unlocked.');
            },
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Reset lifetime coins to 0',
            color: Colors.orange,
            onPressed: () {
              game.resetLifetimeCoinsEarned();
              _lifetimeController.text = '0';
              _showMessage('Lifetime coins reset to 0.');
            },
          ),
          const SizedBox(height: 32),
          _SectionTitle('Force Next Hatch'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: game.hasForcedNextHatch
                  ? Colors.green.shade50
                  : Colors.white,
              border: Border.all(
                color: game.hasForcedNextHatch
                    ? Colors.green
                    : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              game.hasForcedNextHatch && forcedAnimal != null && forcedMutation != null
                  ? 'ACTIVE: ${forcedMutation.fullName(forcedAnimal)}'
                  : 'No forced hatch active',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: game.hasForcedNextHatch
                    ? Colors.green.shade800
                    : Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _LabeledDropdown<String>(
            label: 'Animal',
            value: _selectedAnimalId,
            items: [
              for (final animal in _sortedAnimals)
                DropdownMenuItem(
                  value: animal.id,
                  child: Text(
                    '${animal.emoji} ${animal.name} (${animal.coinsPerSecond}/s)',
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedAnimalId = value);
            },
          ),
          const SizedBox(height: 12),
          _LabeledDropdown<String>(
            label: 'Mutation',
            value: _selectedMutationId,
            items: [
              for (final mutation in GameData.mutations)
                DropdownMenuItem(
                  value: mutation.id,
                  child: Text(
                    mutation.isNormal
                        ? 'Normal (none)'
                        : '${mutation.icon} ${mutation.displayName}',
                  ),
                ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedMutationId = value);
            },
          ),
          const SizedBox(height: 16),
          _BigButton(
            label: 'Set Forced Next Hatch',
            color: Colors.deepPurple,
            onPressed: _applyForcedHatch,
          ),
          const SizedBox(height: 12),
          _BigButton(
            label: 'Clear Forced Hatch',
            color: Colors.red.shade400,
            onPressed: _clearForcedHatch,
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(backgroundColor: color),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _QuickCoinButton extends StatelessWidget {
  const _QuickCoinButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
      child: Text(label),
    );
  }
}
