import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Service for cosmetics crafting system
///
/// Allows players to combine common cosmetics into rarer variants.
/// Implements recipe-based crafting with inventory management.
class CosmeticsCraftingService {
  /// Crafting recipe: 3 commons + 1 rare = 1 rare cosmetic
  ///
  /// Maps rare cosmetic ID to required common cosmetic IDs.
  static const Map<String, CraftingRecipe> craftingRecipes = {
    'board_sakura': CraftingRecipe(
      resultId: 'board_sakura',
      resultName: 'さくら盤',
      resultType: CosmeticType.board,
      resultRarity: CosmeticRarity.rare,
      requiredMaterials: [
        'board_classic',
        'board_classic',
        'board_classic',
      ],
      craftingTimeMinutes: 60,
      priceYen: 300,
    ),
    'board_neon': CraftingRecipe(
      resultId: 'board_neon',
      resultName: 'ネオン盤',
      resultType: CosmeticType.board,
      resultRarity: CosmeticRarity.rare,
      requiredMaterials: [
        'board_midnight',
        'board_midnight',
        'board_midnight',
      ],
      craftingTimeMinutes: 60,
      priceYen: 300,
    ),
    'board_crystal': CraftingRecipe(
      resultId: 'board_crystal',
      resultName: 'クリスタル盤',
      resultType: CosmeticType.board,
      resultRarity: CosmeticRarity.rare,
      requiredMaterials: [
        'board_classic',
        'board_midnight',
        'board_midnight',
      ],
      craftingTimeMinutes: 90,
      priceYen: 300,
    ),
  };

  /// Get available recipes for user
  ///
  /// Returns recipes where user has required materials.
  List<CraftingRecipe> getAvailableRecipes(
    Map<String, int> userInventory,
  ) {
    return craftingRecipes.entries
        .where((entry) {
          final recipe = entry.value;
          // Check if user has all required materials
          return recipe.requiredMaterials.every((material) {
            return (userInventory[material] ?? 0) > 0;
          });
        })
        .map((entry) => entry.value)
        .toList();
  }

  /// Check if user can craft a specific cosmetic
  bool canCraftCosmetic(
    String cosmeticId,
    Map<String, int> userInventory,
  ) {
    final recipe = craftingRecipes[cosmeticId];
    if (recipe == null) return false;

    return recipe.requiredMaterials.every((material) {
      return (userInventory[material] ?? 0) > 0;
    });
  }

  /// Calculate crafting completion time
  ///
  /// Returns DateTime when crafting will complete.
  DateTime calculateCompletionTime(String cosmeticId) {
    final recipe = craftingRecipes[cosmeticId];
    if (recipe == null) {
      throw ArgumentError('Unknown cosmetic: $cosmeticId');
    }

    final now = DateTime.now();
    return now.add(Duration(minutes: recipe.craftingTimeMinutes));
  }

  /// Get crafting recipe by cosmetic ID
  CraftingRecipe? getRecipe(String cosmeticId) {
    return craftingRecipes[cosmeticId];
  }

  /// Get all available recipes
  List<CraftingRecipe> getAllRecipes() {
    return craftingRecipes.values.toList();
  }

  /// Calculate craft XP reward
  ///
  /// Awards XP to track crafting achievements.
  int calculateCraftXP(CosmeticRarity rarity) {
    switch (rarity) {
      case CosmeticRarity.common:
        return 10;
      case CosmeticRarity.rare:
        return 50;
      case CosmeticRarity.limited:
        return 100;
    }
  }
}

/// Crafting recipe definition
class CraftingRecipe {
  /// ID of cosmetic produced by this recipe
  final String resultId;

  /// Display name of result cosmetic
  final String resultName;

  /// Type of result (board or stone)
  final CosmeticType resultType;

  /// Rarity of result
  final CosmeticRarity resultRarity;

  /// List of material cosmetic IDs required (3x common)
  final List<String> requiredMaterials;

  /// Time to craft in minutes
  final int craftingTimeMinutes;

  /// Cost of recipe (if any)
  final int priceYen;

  const CraftingRecipe({
    required this.resultId,
    required this.resultName,
    required this.resultType,
    required this.resultRarity,
    required this.requiredMaterials,
    required this.craftingTimeMinutes,
    required this.priceYen,
  }) : assert(requiredMaterials.length == 3, 'Recipe requires exactly 3 materials');

  /// Convert to JSON for storage
  Map<String, dynamic> toMap() => {
        'result_id': resultId,
        'result_name': resultName,
        'result_type': resultType.toString(),
        'result_rarity': resultRarity.toString(),
        'required_materials': requiredMaterials,
        'crafting_time_minutes': craftingTimeMinutes,
        'price_yen': priceYen,
      };

  /// Create from JSON
  factory CraftingRecipe.fromMap(Map<String, dynamic> map) {
    return CraftingRecipe(
      resultId: map['result_id'] as String,
      resultName: map['result_name'] as String,
      resultType: _parseCosmeticType(map['result_type'] as String),
      resultRarity: _parseCosmeticRarity(map['result_rarity'] as String),
      requiredMaterials:
          List<String>.from(map['required_materials'] as List),
      craftingTimeMinutes: map['crafting_time_minutes'] as int,
      priceYen: map['price_yen'] as int,
    );
  }
}

/// Parse cosmetic type from string
CosmeticType _parseCosmeticType(String value) {
  switch (value) {
    case 'CosmeticType.board':
      return CosmeticType.board;
    case 'CosmeticType.stoneBlack':
      return CosmeticType.stoneBlack;
    case 'CosmeticType.stoneWhite':
      return CosmeticType.stoneWhite;
    case 'CosmeticType.stoneRed':
      return CosmeticType.stoneRed;
    default:
      throw ArgumentError('Unknown cosmetic type: $value');
  }
}

/// Parse cosmetic rarity from string
CosmeticRarity _parseCosmeticRarity(String value) {
  switch (value) {
    case 'CosmeticRarity.common':
      return CosmeticRarity.common;
    case 'CosmeticRarity.rare':
      return CosmeticRarity.rare;
    case 'CosmeticRarity.limited':
      return CosmeticRarity.limited;
    default:
      throw ArgumentError('Unknown rarity: $value');
  }
}
