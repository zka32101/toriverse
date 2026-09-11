import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticItem Model Tests', () {
    group('Construction', () {
      test('creates cosmetic item with all fields', () {
        final releaseDate = DateTime(2026, 9, 1);
        final endDate = DateTime(2026, 9, 30);

        final cosmetic = CosmeticItem(
          id: 'board_sakura',
          type: CosmeticType.board,
          name: 'Cherry Blossom Board',
          description: 'Beautiful spring themed board',
          price: 300,
          rarity: CosmeticRarity.rare,
          colorScheme: 'pink_white',
          previewImageUrl: 'https://example.com/sakura.png',
          releaseDate: releaseDate,
          limitedEditionEndDate: endDate,
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'cosmetic_board_sakura',
        );

        expect(cosmetic.id, equals('board_sakura'));
        expect(cosmetic.name, equals('Cherry Blossom Board'));
        expect(cosmetic.price, equals(300));
        expect(cosmetic.rarity, equals(CosmeticRarity.rare));
        expect(cosmetic.isLimitedEdition, isTrue);
      });

      test('creates common cosmetic without limited edition date', () {
        final cosmetic = CosmeticItem(
          id: 'board_default',
          type: CosmeticType.board,
          name: 'Default Board',
          description: 'Standard board',
          price: 0,
          rarity: CosmeticRarity.common,
          colorScheme: 'standard',
          previewImageUrl: 'https://example.com/default.png',
          releaseDate: DateTime(2026, 8, 1),
          limitedEditionEndDate: null,
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'cosmetic_board_default',
        );

        expect(cosmetic.isLimitedEdition, isFalse);
        expect(cosmetic.limitedEditionEndDate, isNull);
      });
    });

    group('typeString conversion', () {
      test('converts board type to string', () {
        final cosmetic = _createTestCosmetic(type: CosmeticType.board);
        expect(cosmetic.typeString, equals('board'));
      });

      test('converts stone black type to string', () {
        final cosmetic = _createTestCosmetic(type: CosmeticType.stoneBlack);
        expect(cosmetic.typeString, equals('stone_black'));
      });

      test('converts stone white type to string', () {
        final cosmetic = _createTestCosmetic(type: CosmeticType.stoneWhite);
        expect(cosmetic.typeString, equals('stone_white'));
      });

      test('converts stone red type to string', () {
        final cosmetic = _createTestCosmetic(type: CosmeticType.stoneRed);
        expect(cosmetic.typeString, equals('stone_red'));
      });
    });

    group('Availability checks', () {
      test('item is available if released and not expired', () {
        final now = DateTime.now();
        final cosmetic = CosmeticItem(
          id: 'test_1',
          type: CosmeticType.board,
          name: 'Test',
          description: 'Test',
          price: 100,
          rarity: CosmeticRarity.common,
          colorScheme: 'test',
          previewImageUrl: 'url',
          releaseDate: now.subtract(Duration(days: 1)),
          limitedEditionEndDate: now.add(Duration(days: 1)),
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'test',
        );

        expect(cosmetic.isCurrentlyAvailable, isTrue);
      });

      test('item is not available if not yet released', () {
        final now = DateTime.now();
        final cosmetic = CosmeticItem(
          id: 'test_1',
          type: CosmeticType.board,
          name: 'Test',
          description: 'Test',
          price: 100,
          rarity: CosmeticRarity.common,
          colorScheme: 'test',
          previewImageUrl: 'url',
          releaseDate: now.add(Duration(days: 1)),
          limitedEditionEndDate: null,
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'test',
        );

        expect(cosmetic.isCurrentlyAvailable, isFalse);
      });

      test('item is not available if limited edition expired', () {
        final now = DateTime.now();
        final cosmetic = CosmeticItem(
          id: 'test_1',
          type: CosmeticType.board,
          name: 'Test',
          description: 'Test',
          price: 100,
          rarity: CosmeticRarity.common,
          colorScheme: 'test',
          previewImageUrl: 'url',
          releaseDate: now.subtract(Duration(days: 10)),
          limitedEditionEndDate: now.subtract(Duration(days: 1)),
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'test',
        );

        expect(cosmetic.isCurrentlyAvailable, isFalse);
      });
    });

    group('Serialization', () {
      test('converts to map with correct keys', () {
        final cosmetic = _createTestCosmetic();
        final map = cosmetic.toMap();

        expect(map['id'], equals('board_test'));
        expect(map['type'], equals('board'));
        expect(map['name'], equals('Test Board'));
        expect(map['price'], equals(300));
        expect(map['rarity'], equals('rare'));
      });

      test('creates from map', () {
        final original = _createTestCosmetic();
        final map = original.toMap();
        final restored = CosmeticItem.fromMap(map);

        expect(restored.id, equals(original.id));
        expect(restored.name, equals(original.name));
        expect(restored.price, equals(original.price));
        expect(restored.type, equals(original.type));
      });

      test('fromMap handles missing optional fields', () {
        final map = {
          'id': 'test',
          'type': 'board',
          'name': 'Test',
          'description': 'Test',
          'price': 100,
          'rarity': 'common',
          'color_scheme': 'test',
          'preview_image_url': 'url',
          'release_date': _now,
          'limited_edition_end_date': null,
          'revenueket_product_id': 'test',
          // missing 'requires_min_version'
        };

        final cosmetic = CosmeticItem.fromMap(map);
        expect(cosmetic.requiresMinVersion, equals('0.1.0')); // Default value
      });
    });

    group('copyWith', () {
      test('copies with single field change', () {
        final original = _createTestCosmetic();
        final updated = original.copyWith(price: 500);

        expect(updated.price, equals(500));
        expect(updated.id, equals(original.id));
        expect(updated.name, equals(original.name));
      });

      test('copies with multiple field changes', () {
        final original = _createTestCosmetic();
        final updated = original.copyWith(
          name: 'New Name',
          price: 120,
          rarity: CosmeticRarity.limited,
        );

        expect(updated.name, equals('New Name'));
        expect(updated.price, equals(120));
        expect(updated.rarity, equals(CosmeticRarity.limited));
        expect(updated.id, equals(original.id)); // Unchanged
      });
    });

    group('Equality', () {
      test('items with same id are equal', () {
        final cosmetic1 = _createTestCosmetic();
        final cosmetic2 = _createTestCosmetic();

        expect(cosmetic1, equals(cosmetic2));
      });

      test('items with different ids are not equal', () {
        final cosmetic1 = _createTestCosmetic();
        final cosmetic2 = _createTestCosmetic(id: 'board_different');

        expect(cosmetic1, isNot(equals(cosmetic2)));
      });

      test('hashCode is consistent with equality', () {
        final cosmetic1 = _createTestCosmetic();
        final cosmetic2 = _createTestCosmetic();

        expect(cosmetic1.hashCode, equals(cosmetic2.hashCode));
      });
    });
  });

  group('UserCosmetic Model Tests', () {
    test('creates user cosmetic', () {
      final now = DateTime.now();
      final userCosmetic = UserCosmetic(
        cosmeticId: 'board_sakura',
        purchasedAt: now,
        purchaseSource: 'shop',
        revenuekatProductId: 'cosmetic_board_sakura',
      );

      expect(userCosmetic.cosmeticId, equals('board_sakura'));
      expect(userCosmetic.purchaseSource, equals('shop'));
    });

    test('serializes and deserializes', () {
      final now = DateTime.now();
      final original = UserCosmetic(
        cosmeticId: 'board_test',
        purchasedAt: now,
        purchaseSource: 'seasonal_reward',
        revenuekatProductId: 'test_product',
      );

      final map = original.toMap();
      final restored = UserCosmetic.fromMap(map);

      expect(restored.cosmeticId, equals(original.cosmeticId));
      expect(restored.purchaseSource, equals(original.purchaseSource));
    });
  });

  group('UserCosmeticsPreference Model Tests', () {
    test('creates with defaults', () {
      final prefs = const UserCosmeticsPreference();

      expect(prefs.activeBoard, equals('default'));
      expect(prefs.activeStoneBlack, equals('default'));
      expect(prefs.activeStoneWhite, equals('default'));
      expect(prefs.activeStoneRed, equals('default'));
    });

    test('creates with custom values', () {
      final prefs = const UserCosmeticsPreference(
        activeBoard: 'board_sakura',
        activeStoneBlack: 'stone_black_1',
        activeStoneWhite: 'stone_white_1',
        activeStoneRed: 'stone_red_1',
      );

      expect(prefs.activeBoard, equals('board_sakura'));
      expect(prefs.activeStoneBlack, equals('stone_black_1'));
    });

    test('copyWith preserves unchanged fields', () {
      final original = const UserCosmeticsPreference(
        activeBoard: 'board_1',
        activeStoneBlack: 'stone_1',
      );

      final updated = original.copyWith(activeBoard: 'board_2');

      expect(updated.activeBoard, equals('board_2'));
      expect(updated.activeStoneBlack, equals('stone_1'));
      expect(updated.activeStoneWhite, equals('default'));
    });

    test('serializes and deserializes', () {
      final original = const UserCosmeticsPreference(
        activeBoard: 'board_test',
        activeStoneRed: 'stone_red_test',
      );

      final map = original.toMap();
      final restored = UserCosmeticsPreference.fromMap(map);

      expect(restored.activeBoard, equals(original.activeBoard));
      expect(restored.activeStoneRed, equals(original.activeStoneRed));
    });
  });
}

// Helper functions
final _now = DateTime(2026, 9, 2);

CosmeticItem _createTestCosmetic({
  String id = 'board_test',
  CosmeticType type = CosmeticType.board,
}) {
  return CosmeticItem(
    id: id,
    type: type,
    name: 'Test Board',
    description: 'Test description',
    price: 300,
    rarity: CosmeticRarity.rare,
    colorScheme: 'test',
    previewImageUrl: 'https://example.com/test.png',
    releaseDate: _now,
    limitedEditionEndDate: _now.add(Duration(days: 30)),
    requiresMinVersion: '0.1.0',
    revenuekatProductId: 'cosmetic_board_test',
  );
}
