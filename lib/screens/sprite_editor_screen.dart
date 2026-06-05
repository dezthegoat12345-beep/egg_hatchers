import 'package:flutter/material.dart';

import '../models/animal.dart';
import '../models/background_theme.dart';
import '../models/custom_sprite_data.dart';
import '../services/custom_sprite_service.dart';
import '../theme/game_theme.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/custom_sprite_preview.dart';
import '../widgets/game_background.dart';
import '../widgets/pixel_sprite.dart';

/// Simple 16×16 pixel editor for one animal sprite.
class SpriteEditorScreen extends StatefulWidget {
  const SpriteEditorScreen({
    super.key,
    required this.animal,
    required this.theme,
    required this.customSprites,
  });

  final Animal animal;
  final BackgroundTheme theme;
  final CustomSpriteService customSprites;

  @override
  State<SpriteEditorScreen> createState() => _SpriteEditorScreenState();
}

class _SpriteEditorScreenState extends State<SpriteEditorScreen> {
  late CustomSpriteData _data;
  int? _selectedColor = SpritePalette.colors.first;
  bool _eraserSelected = false;

  @override
  void initState() {
    super.initState();
    _data = widget.customSprites.getSprite(widget.animal.id) ??
        CustomSpriteData.empty();
  }

  void _clear() {
    setState(() => _data = CustomSpriteData.empty());
  }

  Future<void> _save() async {
    await widget.customSprites.saveSprite(widget.animal.id, _data);
    if (!mounted) return;
    showGameSnackBar(
      context,
      message: '${widget.animal.name} sprite saved!',
      backgroundColor: widget.theme.primaryColor,
    );
  }

  Future<void> _reset() async {
    await widget.customSprites.resetSprite(widget.animal.id);
    if (!mounted) return;
    setState(() => _data = CustomSpriteData.empty());
    showGameSnackBar(
      context,
      message: '${widget.animal.name} reset to original sprite.',
      backgroundColor: widget.theme.secondaryColor,
    );
  }

  void _selectColor(int? color) {
    setState(() {
      _selectedColor = color;
      _eraserSelected = color == SpritePalette.transparent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final activeColor =
        _eraserSelected ? SpritePalette.transparent : _selectedColor;

    return Scaffold(
      backgroundColor: theme.scaffoldColor,
      appBar: AppBar(
        title: Text(
          '✏️ ${widget.animal.name}',
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: GameTheme.cardDecoration(theme),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Tap squares to draw. Choose a color below.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.cardTextSecondaryColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              PixelSpriteEditor(
                                data: _data,
                                selectedColor: activeColor,
                                onChanged: (next) => setState(() => _data = next),
                                canvasSize: 240,
                                themeColor: theme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: GameTheme.cardDecoration(theme),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preview',
                                style: GameTheme.sectionTitle(theme, size: 15),
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: theme.cardBorderColor
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: _data.hasVisiblePixels
                                      ? PixelSprite(data: _data, size: 96)
                                      : CustomSpritePreview(
                                          spritePath: widget.animal.spritePath,
                                          fallbackEmoji: widget.animal.emoji,
                                          size: 96,
                                          emojiFontSize: 64,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: GameTheme.cardDecoration(theme),
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Palette',
                                style: GameTheme.sectionTitle(theme, size: 15),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _PaletteSwatch(
                                    label: 'Eraser',
                                    color: Colors.transparent,
                                    isSelected: _eraserSelected,
                                    onTap: () => _selectColor(
                                      SpritePalette.transparent,
                                    ),
                                    showEraserIcon: true,
                                    theme: theme,
                                  ),
                                  for (var i = 0;
                                      i < SpritePalette.colors.length;
                                      i++)
                                    _PaletteSwatch(
                                      label: SpritePalette.labels[i],
                                      color: Color(SpritePalette.colors[i]!),
                                      isSelected: !_eraserSelected &&
                                          _selectedColor ==
                                              SpritePalette.colors[i],
                                      onTap: () =>
                                          _selectColor(SpritePalette.colors[i]),
                                      theme: theme,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _clear,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  foregroundColor: theme.cardTextPrimaryColor,
                                  side: BorderSide(color: theme.cardBorderColor),
                                ),
                                child: const Text('Clear'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _reset,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  foregroundColor: theme.cardTextPrimaryColor,
                                  side: BorderSide(color: theme.cardBorderColor),
                                ),
                                child: const Text('Reset'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        FilledButton(
                          onPressed: _save,
                          style: GameTheme.filledButton(
                            theme,
                            color: theme.primaryColor,
                            height: 52,
                          ),
                          child: const Text(
                            'Save Sprite',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.showEraserIcon = false,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final BackgroundTheme theme;
  final bool showEraserIcon;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: showEraserIcon ? Colors.white : color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.primaryColor : theme.cardBorderColor,
              width: isSelected ? 3 : 1.5,
            ),
          ),
          child: showEraserIcon
              ? Icon(
                  Icons.auto_fix_off_rounded,
                  size: 20,
                  color: theme.cardTextSecondaryColor,
                )
              : null,
        ),
      ),
    );
  }
}
