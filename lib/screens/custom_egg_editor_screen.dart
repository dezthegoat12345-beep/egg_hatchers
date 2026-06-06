import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/game_data.dart';
import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/custom_egg.dart';
import '../services/custom_egg_service.dart';
import '../services/preferences_service.dart';
import '../theme/game_theme.dart';
import '../utils/custom_egg_logic.dart';
import '../utils/format_utils.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/game_background.dart';

/// Form for creating or editing a custom egg.
class CustomEggEditorScreen extends StatefulWidget {
  const CustomEggEditorScreen({
    super.key,
    required this.preferences,
    required this.customEggs,
    this.existing,
  });

  final PreferencesService preferences;
  final CustomEggService customEggs;
  final CustomEgg? existing;

  @override
  State<CustomEggEditorScreen> createState() => _CustomEggEditorScreenState();
}

class _CustomEggEditorScreenState extends State<CustomEggEditorScreen> {
  late final CustomEgg _draft;
  late final TextEditingController _nameController;
  late final TextEditingController _emojiController;
  late final TextEditingController _costController;
  late final Set<String> _selectedAnimalIds;
  late final Map<String, int> _animalWeights;
  late bool _isEnabled;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _draft = widget.existing ?? CustomEgg.newDraft();
    _nameController = TextEditingController(text: _draft.name);
    _emojiController = TextEditingController(text: _draft.emoji);
    _costController = TextEditingController(text: '${_draft.cost}');
    _selectedAnimalIds = Set<String>.from(_draft.selectedAnimalIds);
    _animalWeights = Map<String, int>.from(_draft.animalWeights);
    _isEnabled = _draft.isEnabled;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _costController.dispose();
    super.dispose();
  }

  CustomEgg _buildDraftEgg() {
    return _draft.copyWith(
      name: _nameController.text.trim().isEmpty
          ? 'My Custom Egg'
          : _nameController.text.trim(),
      emoji: _emojiController.text.trim(),
      cost: int.tryParse(_costController.text.trim()) ?? _draft.cost,
      selectedAnimalIds: _selectedAnimalIds.toList(),
      animalWeights: Map.from(_animalWeights),
      isEnabled: _isEnabled,
    );
  }

  int get _minimumCost {
    if (_selectedAnimalIds.isEmpty) return 1;
    return _buildDraftEgg().minimumCost;
  }

  int? get _enteredCost => int.tryParse(_costController.text.trim());

  bool get _costBelowMinimum {
    final cost = _enteredCost;
    if (cost == null || _selectedAnimalIds.isEmpty) return false;
    return cost < _minimumCost;
  }

  List<Animal> get _sortedAnimals {
    final list = List<Animal>.from(GameData.animals);
    list.sort((a, b) {
      final rarity = b.rarity.sortOrder.compareTo(a.rarity.sortOrder);
      if (rarity != 0) return rarity;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  void _toggleAnimal(String animalId, bool checked) {
    setState(() {
      if (checked) {
        _selectedAnimalIds.add(animalId);
        _animalWeights.putIfAbsent(animalId, () => 1);
      } else {
        _selectedAnimalIds.remove(animalId);
        _animalWeights.remove(animalId);
      }
    });
  }

  void _changeWeight(String animalId, int delta) {
    final current = _animalWeights[animalId] ?? 1;
    final next = (current + delta).clamp(
      CustomEggLogic.minWeight,
      CustomEggLogic.maxWeight,
    );
    setState(() => _animalWeights[animalId] = next);
  }

  void _applyMinimumCost() {
    setState(() {
      _costController.text = '$_minimumCost';
    });
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showError('Enter an egg name.');
      return;
    }
    if (name.length > CustomEgg.maxNameLength) {
      _showError('Name must be ${CustomEgg.maxNameLength} characters or less.');
      return;
    }

    final cost = _enteredCost;
    if (cost == null || cost < 1) {
      _showError('Cost must be at least 1.');
      return;
    }

    if (_selectedAnimalIds.isEmpty) {
      _showError('Select at least one animal.');
      return;
    }

    final draft = _buildDraftEgg();
    if (cost < draft.minimumCost) {
      _showError(
        'Cost must be at least ${formatCoins(draft.minimumCost)} coins '
        'for these animals.',
      );
      return;
    }

    final emoji = _emojiController.text.trim();
    final egg = draft.copyWith(
      name: name,
      emoji: emoji.isEmpty ? '🥚' : emoji,
      cost: cost,
    );

    await widget.customEggs.saveEgg(egg);
    if (!mounted) return;

    showGameSnackBar(
      context,
      message: '${egg.name} saved!',
      backgroundColor: widget.preferences.selectedTheme.primaryColor,
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    showGameSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red.shade400,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.preferences.selectedTheme;
    final draft = _buildDraftEgg();

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? '✏️ Edit Egg' : '🥚 New Egg',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: GameBackground(
        theme: theme,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth > 520 ? 520.0 : double.infinity;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _FieldCard(
                              theme: theme,
                              child: TextField(
                                controller: _nameController,
                                maxLength: CustomEgg.maxNameLength,
                                onChanged: (_) => setState(() {}),
                                style: TextStyle(
                                  color: theme.cardTextPrimaryColor,
                                ),
                                decoration: _inputDecoration(
                                  theme,
                                  'Egg name',
                                  hint: 'My Custom Egg',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FieldCard(
                              theme: theme,
                              child: TextField(
                                controller: _emojiController,
                                maxLength: 4,
                                style: const TextStyle(fontSize: 28),
                                decoration: _inputDecoration(
                                  theme,
                                  'Egg emoji',
                                  hint: '🥚',
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: GameTheme.cardDecoration(theme),
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Minimum cost: 🪙 ${formatCoins(_minimumCost)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: theme.cardTextPrimaryColor,
                                    ),
                                  ),
                                  if (_selectedAnimalIds.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'Select animals to calculate minimum cost.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: theme.cardTextSecondaryColor,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FieldCard(
                              theme: theme,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _costController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (_) => setState(() {}),
                                    style: TextStyle(
                                      color: theme.cardTextPrimaryColor,
                                    ),
                                    decoration: _inputDecoration(
                                      theme,
                                      'Cost (coins)',
                                      hint: '1000',
                                    ),
                                  ),
                                  if (_costBelowMinimum) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Cost must be at least '
                                      '${formatCoins(_minimumCost)} coins.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    onPressed: _selectedAnimalIds.isEmpty
                                        ? null
                                        : _applyMinimumCost,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: theme.primaryColor,
                                      side: BorderSide(color: theme.primaryColor),
                                    ),
                                    child: const Text('Use Minimum Cost'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: GameTheme.cardDecoration(theme),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: SwitchListTile(
                                  title: Text(
                                    'Enabled in shop',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: theme.cardTextPrimaryColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _isEnabled
                                        ? 'Visible in the Egg Shop'
                                        : 'Saved but hidden from shop',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.cardTextSecondaryColor,
                                    ),
                                  ),
                                  value: _isEnabled,
                                  activeThumbColor: theme.primaryColor,
                                  onChanged: (value) =>
                                      setState(() => _isEnabled = value),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select animals & hatch weights',
                              style: GameTheme.sectionTitle(theme, size: 15),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_selectedAnimalIds.length} selected',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.cardTextSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._sortedAnimals.map(
                              (animal) => _AnimalWeightTile(
                                animal: animal,
                                theme: theme,
                                selected:
                                    _selectedAnimalIds.contains(animal.id),
                                weight: _animalWeights[animal.id] ?? 1,
                                chancePercent: _selectedAnimalIds
                                        .contains(animal.id)
                                    ? CustomEggLogic.chancePercentForAnimal(
                                        draft,
                                        animal.id,
                                      ).round()
                                    : null,
                                onToggle: (checked) =>
                                    _toggleAnimal(animal.id, checked),
                                onWeightChange: (delta) =>
                                    _changeWeight(animal.id, delta),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: FilledButton(
                          onPressed: _save,
                          style: GameTheme.filledButton(
                            theme,
                            color: theme.primaryColor,
                            height: 52,
                          ),
                          child: const Text(
                            'Save Custom Egg',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BackgroundTheme theme,
    String label, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: theme.cardTextSecondaryColor),
      hintStyle: TextStyle(color: theme.cardTextSecondaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.cardBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.cardBorderColor),
      ),
      counterStyle: TextStyle(color: theme.cardTextSecondaryColor),
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.theme, required this.child});

  final BackgroundTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: GameTheme.cardDecoration(theme),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _AnimalWeightTile extends StatelessWidget {
  const _AnimalWeightTile({
    required this.animal,
    required this.theme,
    required this.selected,
    required this.weight,
    required this.chancePercent,
    required this.onToggle,
    required this.onWeightChange,
  });

  final Animal animal;
  final BackgroundTheme theme;
  final bool selected;
  final int weight;
  final int? chancePercent;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onWeightChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: GameTheme.cardDecoration(theme),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            CheckboxListTile(
              value: selected,
              activeColor: theme.primaryColor,
              title: Text(
                '${animal.emoji} ${animal.name}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.cardTextPrimaryColor,
                ),
              ),
              subtitle: Text(
                '${animal.rarity.label} · ${animal.coinsPerSecond}/s',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.cardTextSecondaryColor,
                ),
              ),
              onChanged: (value) => onToggle(value ?? false),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Text(
                      'Weight',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.cardTextSecondaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: weight > CustomEggLogic.minWeight
                          ? () => onWeightChange(-1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline),
                      color: theme.primaryColor,
                    ),
                    Text(
                      '$weight',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.cardTextPrimaryColor,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: weight < CustomEggLogic.maxWeight
                          ? () => onWeightChange(1)
                          : null,
                      icon: const Icon(Icons.add_circle_outline),
                      color: theme.primaryColor,
                    ),
                    const Spacer(),
                    Text(
                      '$chancePercent%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
