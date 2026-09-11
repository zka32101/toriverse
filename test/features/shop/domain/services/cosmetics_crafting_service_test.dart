import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/domain/services/cosmetics_crafting_service.dart';

void main() {
  group('CosmeticsCraftingService', () {
    final service = CosmeticsCraftingService();

    test('getAllRecipes returns all recipes', () {
      final recipes = service.getAllRecipes();
      expect(recipes, isNotEmpty);
      expect(recipes.length, equals(3)); // 3 recipes defined
    });

    test('getRecipe returns correct recipe', () {
      final recipe = service.getRecipe('board_sakura');
      expect(recipe, isNotNull);
      expect(recipe!.resultId, equals('board_sakura'));
      expect(recipe.resultName, equals('さくら盤'));
      expect(recipe.craftingTimeMinutes, equals(60));
    });

    test('getRecipe returns null for unknown cosmetic', () {
      final recipe = service.getRecipe('unknown_cosmetic');
      expect(recipe, isNull);
    });

    test('canCraftCosmetic returns true when user has all materials', () {
      final inventory = {
        'board_classic': 3,
        'board_midnight': 2,
      };
      expect(service.canCraftCosmetic('board_sakura', inventory), isTrue);
    });

    test('canCraftCosmetic returns false when user lacks materials', () {
      final inventory = {
        'board_classic': 1, // Need 3
      };
      expect(service.canCraftCosmetic('board_sakura', inventory), isFalse);
    });

    test('canCraftCosmetic returns false for unknown recipe', () {
      final inventory = {'some_item': 10};
      expect(service.canCraftCosmetic('unknown_recipe', inventory), isFalse);
    });

    test('getAvailableRecipes filters to craftable recipes', () {
      final inventory = {
        'board_classic': 3,
        'board_midnight': 3,
      };
      final available = service.getAvailableRecipes(inventory);
      expect(available.length, greaterThan(0));
      expect(available.every((r) => r.requiredMaterials.every(
          (m) => (inventory[m] ?? 0) > 0)), isTrue);
    });

    test('getAvailableRecipes returns empty when no materials', () {
      final inventory = <String, int>{};
      final available = service.getAvailableRecipes(inventory);
      expect(available, isEmpty);
    });

    test('calculateCompletionTime returns valid future datetime', () {
      final now = DateTime.now();
      final completionTime = service.calculateCompletionTime('board_sakura');
      expect(completionTime.isAfter(now), isTrue);
      expect(
        completionTime.difference(now).inMinutes,
        equals(60), // board_sakura is 60 minutes
      );
    });

    test('calculateCompletionTime throws for unknown cosmetic', () {
      expect(
        () => service.calculateCompletionTime('unknown_cosmetic'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('calculateCraftXP returns correct values by rarity', () {
      expect(service.calculateCraftXP(CosmeticRarity.common), equals(10));
      expect(service.calculateCraftXP(CosmeticRarity.rare), equals(50));
      expect(service.calculateCraftXP(CosmeticRarity.limited), equals(100));
    });

    test('CraftingRecipe requires exactly 3 materials', () {
      expect(
        () => CraftingRecipe(
          resultId: 'test',
          resultName: 'Test',
          resultType: CosmeticType.board,
          resultRarity: CosmeticRarity.rare,
          requiredMaterials: ['a', 'b'], // Only 2, not 3
          craftingTimeMinutes: 60,
          priceYen: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('CraftingRecipe serialization roundtrip', () {
      final original = service.getRecipe('board_sakura')!;
      final map = original.toMap();
      final restored = CraftingRecipe.fromMap(map);

      expect(restored.resultId, equals(original.resultId));
      expect(restored.resultName, equals(original.resultName));
      expect(restored.craftingTimeMinutes, equals(original.craftingTimeMinutes));
      expect(restored.requiredMaterials, equals(original.requiredMaterials));
    });
  });
}
