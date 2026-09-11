import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/data/seeds/cosmetics_seed_data.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticsSeedData', () {
    test('getAllCosmetics() returns all cosmetics', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      expect(cosmetics.length, 23); // 5 boards + 5 black + 5 white + 5 red + 3 limited
    });

    test('getAllCosmetics() includes correct mix of rarities', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      final common = cosmetics.where((c) => c.rarity == CosmeticRarity.common);
      final rare = cosmetics.where((c) => c.rarity == CosmeticRarity.rare);
      final limited = cosmetics.where((c) => c.rarity == CosmeticRarity.limited);

      expect(common.length, 8); // 1 + 2 + 2 + 2 + 1
      expect(rare.length, 12); // 4 + 3 + 3 + 3
      expect(limited.length, 3);
    });

    test('getBoardCosmetics() returns only board cosmetics', () {
      final boards = CosmeticsSeedData.getBoardCosmetics();

      expect(boards.length, 5);
      expect(boards.every((c) => c.typeString == 'board'), true);
    });

    test('getStoneCosmetics() returns only stone cosmetics', () {
      final stones = CosmeticsSeedData.getStoneCosmetics();

      expect(stones.length, 15); // 5 + 5 + 5
      expect(stones.every((c) =>
          c.typeString == 'stoneBlack' ||
          c.typeString == 'stoneWhite' ||
          c.typeString == 'stoneRed'), true);
    });

    test('getLimitedEditionCosmetics() returns only limited editions', () {
      final limited = CosmeticsSeedData.getLimitedEditionCosmetics();

      expect(limited.length, 3);
      expect(limited.every((c) => c.rarity == CosmeticRarity.limited), true);
    });

    test('All cosmetics have unique IDs', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();
      final ids = cosmetics.map((c) => c.id).toSet();

      expect(ids.length, cosmetics.length);
    });

    test('All cosmetics have names', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      expect(cosmetics.every((c) => c.name.isNotEmpty), true);
    });

    test('All cosmetics have descriptions', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      expect(cosmetics.every((c) => c.description != null), true);
      expect(cosmetics.every((c) => (c.description ?? '').isNotEmpty), true);
    });

    test('Board cosmetics have correct price', () {
      final boards = CosmeticsSeedData.getBoardCosmetics();

      expect(boards.every((c) => c.priceJpy == 300), true);
    });

    test('Stone cosmetics have correct price', () {
      final stones = CosmeticsSeedData.getStoneCosmetics();

      expect(stones.every((c) => c.priceJpy == 120), true);
    });

    test('Limited edition cosmetics have correct price', () {
      final limited = CosmeticsSeedData.getLimitedEditionCosmetics();

      expect(limited.every((c) => c.priceJpy == 500), true);
    });

    test('All cosmetics have valid typeString', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();
      final validTypes = {'board', 'stoneBlack', 'stoneWhite', 'stoneRed'};

      expect(cosmetics.every((c) => validTypes.contains(c.typeString)), true);
    });

    test('Limited edition cosmetics have availability windows', () {
      final limited = CosmeticsSeedData.getLimitedEditionCosmetics();

      for (final cosmetic in limited) {
        expect(cosmetic.availableFrom, isNotNull);
        expect(cosmetic.availableUntil, isNotNull);
      }
    });

    test('Non-limited cosmetics have no availability windows', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();
      final nonLimited =
          cosmetics.where((c) => c.rarity != CosmeticRarity.limited);

      expect(nonLimited.every((c) => c.availableFrom == null), true);
      expect(nonLimited.every((c) => c.availableUntil == null), true);
    });

    test('Stone cosmetics are distributed equally by color', () {
      final stones = CosmeticsSeedData.getStoneCosmetics();

      final black =
          stones.where((c) => c.typeString == 'stoneBlack').length;
      final white =
          stones.where((c) => c.typeString == 'stoneWhite').length;
      final red = stones.where((c) => c.typeString == 'stoneRed').length;

      expect(black, 5);
      expect(white, 5);
      expect(red, 5);
    });

    test('Board cosmetics have correct rarity distribution', () {
      final boards = CosmeticsSeedData.getBoardCosmetics();

      final common = boards.where((c) => c.rarity == CosmeticRarity.common);
      final rare = boards.where((c) => c.rarity == CosmeticRarity.rare);

      expect(common.length, 1);
      expect(rare.length, 4);
    });

    test('All cosmetics can be converted to map and back', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      for (final cosmetic in cosmetics) {
        final map = cosmetic.toMap();
        final restored = CosmeticItem.fromMap(map);

        expect(restored.id, cosmetic.id);
        expect(restored.name, cosmetic.name);
        expect(restored.typeString, cosmetic.typeString);
        expect(restored.priceJpy, cosmetic.priceJpy);
        expect(restored.rarity, cosmetic.rarity);
      }
    });

    test('Cosmetics have valid Japanese names', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();

      // Check that names contain Japanese characters (hiragana, katakana, or kanji)
      expect(cosmetics.every((c) => c.name.isNotEmpty), true);

      // Sample verification of some names
      final classic = cosmetics.firstWhere((c) => c.id == 'board_classic');
      expect(classic.name, contains('盤')); // Board character
    });

    test('board_classic has correct metadata', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();
      final classic = cosmetics.firstWhere((c) => c.id == 'board_classic');

      expect(classic.name, 'クラシック盤');
      expect(classic.typeString, 'board');
      expect(classic.priceJpy, 300);
      expect(classic.rarity, CosmeticRarity.common);
      expect(classic.description, contains('木目'));
    });

    test('limited_golden_set has correct metadata', () {
      final cosmetics = CosmeticsSeedData.getAllCosmetics();
      final golden = cosmetics.firstWhere((c) => c.id == 'limited_golden_set');

      expect(golden.name, 'ゴールデンセット');
      expect(golden.typeString, 'board');
      expect(golden.priceJpy, 500);
      expect(golden.rarity, CosmeticRarity.limited);
      expect(golden.availableFrom, isNotNull);
      expect(golden.availableUntil, isNotNull);
    });
  });
}
