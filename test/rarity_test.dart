import 'package:egg_hatchers/data/game_data.dart';
import 'package:egg_hatchers/models/animal.dart';
import 'package:egg_hatchers/models/background_theme.dart';
import 'package:egg_hatchers/theme/game_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('??? rarity is above mythic in sort order', () {
    expect(Rarity.unknown.sortOrder, greaterThan(Rarity.mythic.sortOrder));
    expect(Rarity.unknown.label, '???');
    expect(Rarity.unknown.id, '???');
  });

  test('top-tier hatchable animals use ??? rarity', () {
    expect(GameData.animalById('nebula_hydra')!.rarity, Rarity.unknown);
    expect(GameData.animalById('night_rooster')!.rarity, Rarity.unknown);
  });

  test('egg golem pet is legendary', () {
    expect(GameData.animalById('egg_golem_pet')!.rarity, Rarity.legendary);
  });

  test('mythic animals still use mythic rarity', () {
    expect(GameData.animalById('galaxy_dragon')!.rarity, Rarity.mythic);
    expect(GameData.animalById('cosmic_phoenix')!.rarity, Rarity.mythic);
  });

  test('??? border color adapts for dark and light themes', () {
    final darkBorder = GameTheme.rarityBorderColor(
      Rarity.unknown,
      BackgroundThemes.shadowNight,
    );
    final lightBorder = GameTheme.rarityBorderColor(
      Rarity.unknown,
      BackgroundThemes.sunnyMeadow,
    );

    expect(darkBorder, const Color(0xFFE8E8E8));
    expect(lightBorder, const Color(0xFF0A0A0A));
  });
}
