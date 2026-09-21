import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/domain/services/cosmetic_showcase_service.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Builds a [CosmeticItem] with sensible defaults for the fields this test
/// suite doesn't care about, so each test case only has to specify what it's
/// actually exercising.
CosmeticItem _testCosmetic({
  required String id,
  required String name,
  required CosmeticType type,
  required CosmeticRarity rarity,
  required int price,
  DateTime? releaseDate,
}) {
  return CosmeticItem(
    id: id,
    name: name,
    type: type,
    rarity: rarity,
    price: price,
    description: 'Test cosmetic',
    colorScheme: 'default',
    previewImageUrl: 'assets/test.png',
    releaseDate: releaseDate ?? DateTime(2026, 1, 1),
    requiresMinVersion: '0.1.0',
    revenuekatProductId: 'test_product_$id',
  );
}

void main() {
  group('CosmeticShowcaseService', () {
    final service = CosmeticShowcaseService();

    // Create test cosmetics
    final cosmetics = [
      _testCosmetic(
        id: 'board_classic',
        name: 'Classic Board',
        type: CosmeticType.board,
        rarity: CosmeticRarity.common,
        price: 120,
      ),
      _testCosmetic(
        id: 'board_sakura',
        name: 'Sakura Board',
        type: CosmeticType.board,
        rarity: CosmeticRarity.rare,
        price: 240,
      ),
      _testCosmetic(
        id: 'limited_apex',
        name: 'Limited Apex',
        type: CosmeticType.board,
        rarity: CosmeticRarity.limited,
        price: 500,
      ),
      _testCosmetic(
        id: 'stone_red',
        name: 'Red Stone',
        type: CosmeticType.stoneRed,
        rarity: CosmeticRarity.common,
        price: 120,
      ),
    ];

    test('calculateStats counts cosmetics correctly', () {
      final stats = service.calculateStats(cosmetics);

      expect(stats.totalOwned, equals(4));
      expect(stats.byRarity[CosmeticRarity.common], equals(2));
      expect(stats.byRarity[CosmeticRarity.rare], equals(1));
      expect(stats.byRarity[CosmeticRarity.limited], equals(1));
    });

    test('calculateStats counts by type', () {
      final stats = service.calculateStats(cosmetics);

      expect(stats.byType[CosmeticType.board], equals(3));
      expect(stats.byType[CosmeticType.stoneRed], equals(1));
    });

    test('calculateCompletionPercentage returns correct value', () {
      expect(service.calculateCompletionPercentage(5, 10), equals(50.0));
      expect(service.calculateCompletionPercentage(10, 10), equals(100.0));
      expect(service.calculateCompletionPercentage(0, 10), equals(0.0));
    });

    test('calculateCompletionPercentage handles zero total', () {
      expect(service.calculateCompletionPercentage(0, 0), equals(0.0));
    });

    test('getShowcaseDisplay organizes by rarity', () {
      final display = service.getShowcaseDisplay(cosmetics, cosmetics);

      expect(display.totalOwned, equals(4));
      expect(display.limitedEditions.length, equals(1));
      expect(display.rareCosmetics.length, equals(1));
      expect(display.commonCosmetics.length, equals(2));
    });

    test('getShowcaseDisplay sorts newest first within rarity', () {
      final now = DateTime.now();
      final older = now.subtract(const Duration(days: 1));

      final cosmeticsWithDates = [
        _testCosmetic(
          id: 'old',
          name: 'Old Item',
          type: CosmeticType.board,
          rarity: CosmeticRarity.common,
          price: 120,
          releaseDate: older,
        ),
        _testCosmetic(
          id: 'new',
          name: 'New Item',
          type: CosmeticType.board,
          rarity: CosmeticRarity.common,
          price: 120,
          releaseDate: now,
        ),
      ];

      final display = service.getShowcaseDisplay(cosmeticsWithDates, cosmeticsWithDates);
      expect(display.commonCosmetics[0].id, equals('new')); // Newest first
    });

    test('compareCollections calculates correctly', () {
      final userA = [cosmetics[0], cosmetics[1], cosmetics[2]];
      final userB = [cosmetics[0], cosmetics[1], cosmetics[3]];

      final comparison = service.compareCollections(userA, userB);

      expect(comparison.userACount, equals(3));
      expect(comparison.userBCount, equals(3));
      expect(comparison.sharedCount, equals(2)); // board_classic, board_sakura
      expect(comparison.userAUniqueCount, equals(1)); // limited_apex
      expect(comparison.userBUniqueCount, equals(1)); // stone_red
    });

    test('CollectionComparison.getLeader determines winner', () {
      var comparison = CollectionComparison(
        userACount: 5,
        userBCount: 3,
        sharedCount: 2,
        userAUniqueCount: 2,
        userBUniqueCount: 1,
        userACompletion: 5,
        userBCompletion: 3,
      );
      expect(comparison.getLeader(), equals('A'));

      comparison = CollectionComparison(
        userACount: 3,
        userBCount: 5,
        sharedCount: 2,
        userAUniqueCount: 1,
        userBUniqueCount: 2,
        userACompletion: 3,
        userBCompletion: 5,
      );
      expect(comparison.getLeader(), equals('B'));

      comparison = CollectionComparison(
        userACount: 5,
        userBCount: 5,
        sharedCount: 5,
        userAUniqueCount: 0,
        userBUniqueCount: 0,
        userACompletion: 5,
        userBCompletion: 5,
      );
      expect(comparison.getLeader(), equals('Tie'));
    });

    test('generateShareText includes all stats', () {
      final stats = service.calculateStats(cosmetics);
      final text = service.generateShareText('TestUser', stats, 75);

      expect(text.contains('TestUser'), isTrue);
      expect(text.contains('4'), isTrue); // Total count
      expect(text.contains('75'), isTrue); // Completion %
      expect(text.contains('#トリバース'), isTrue);
    });

    test('getAchievements tracks common collector', () {
      final commons = [
        _testCosmetic(
          id: 'common1',
          name: 'Common 1',
          type: CosmeticType.board,
          rarity: CosmeticRarity.common,
          price: 120,
        ),
      ];
      final allCosmetics = commons;

      final achievements = service.getAchievements(commons, allCosmetics);

      expect(
        achievements.any((a) => a.id == 'collect_all_common'),
        isTrue,
      );
    });

    test('getAchievements tracks exclusive owner', () {
      final owned = [
        _testCosmetic(
          id: 'limited',
          name: 'Limited',
          type: CosmeticType.board,
          rarity: CosmeticRarity.limited,
          price: 500,
        ),
      ];
      final allCosmetics = owned;

      final achievements = service.getAchievements(owned, allCosmetics);

      expect(
        achievements.any((a) => a.id == 'first_limited'),
        isTrue,
      );
    });

    test('getAchievements tracks collector milestones', () {
      final owned = List.generate(
        25,
        (i) => _testCosmetic(
          id: 'cosmetic_$i',
          name: 'Cosmetic $i',
          type: CosmeticType.board,
          rarity: CosmeticRarity.common,
          price: 120,
        ),
      );
      final allCosmetics = owned;

      final achievements = service.getAchievements(owned, allCosmetics);

      expect(
        achievements.any((a) => a.id == 'collector_10'),
        isTrue,
      );
      expect(
        achievements.any((a) => a.id == 'collector_25'),
        isTrue,
      );
    });

    test('CosmeticShowcaseDisplay.getCompletionPercentage works', () {
      final display = service.getShowcaseDisplay(cosmetics, cosmetics);
      expect(display.getCompletionPercentage(), equals(100.0));
    });
  });
}
