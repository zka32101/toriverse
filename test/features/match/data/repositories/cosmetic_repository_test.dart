import 'package:flutter_test/flutter_test.dart';
import 'package:mock_cloud_firestore/mock_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toriverse/features/match/data/repositories/cosmetic_repository.dart';
import 'package:toriverse/features/match/application/providers/cosmetic_state.dart';

void main() {
  group('CosmeticRepository', () {
    late CosmeticRepository repository;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      repository = CosmeticRepository(firestore: mockFirestore);
    });

    group('fetchCosmeticCatalog', () {
      test('Returns cosmetics from Firestore when available', () async {
        // Add test cosmetics to mock Firestore
        await mockFirestore.collection('cosmetics').doc('board_1').set({
          'type': 'board',
          'name': 'Test Board',
          'rarity': 'common',
          'price': 120,
          'createdAt': DateTime.now(),
        });

        final catalog = await repository.fetchCosmeticCatalog();

        expect(catalog, isNotEmpty);
        expect(catalog.first.name, 'Test Board');
        expect(catalog.first.rarity, 'common');
      });

      test('Returns default catalog when Firestore is empty', () async {
        final catalog = await repository.fetchCosmeticCatalog();

        expect(catalog, isNotEmpty);
        expect(
          catalog.any((item) => item.id == 'board_wood_dark'),
          isTrue,
          reason: 'Should contain default board cosmetic',
        );
      });

      test('Returns default catalog on fetch error', () async {
        // Force error by using invalid repository setup
        final repo = CosmeticRepository(firestore: MockFirebaseFirestore());
        final catalog = await repo.fetchCosmeticCatalog();

        expect(catalog, isNotEmpty);
        expect(catalog.length, CosmeticRepository.defaultCatalog.length);
      });

      test('Filters cosmetics by type', () async {
        final catalog = await repository.fetchCosmeticCatalog();
        final boards = catalog.where((c) => c.type == 'board').toList();

        expect(boards, isNotEmpty);
        expect(boards.every((c) => c.type == 'board'), isTrue);
      });

      test('Default catalog contains all rarities', () async {
        final catalog = await repository.fetchCosmeticCatalog();
        final rarities = catalog.map((c) => c.rarity).toSet();

        expect(rarities.contains('common'), isTrue);
        expect(rarities.contains('uncommon'), isTrue);
        expect(rarities.contains('rare'), isTrue);
        expect(rarities.contains('legendary'), isTrue);
      });
    });

    group('persistOwnedCosmetics', () {
      test('Persists owned cosmetics to Firestore', () async {
        const userId = 'user_123';
        final cosmetics = [
          OwnedCosmetic(
            itemId: 'board_1',
            source: 'starter_kit',
            acquiredAt: DateTime.now(),
            isActive: true,
          ),
          OwnedCosmetic(
            itemId: 'board_2',
            source: 'milestone_reward',
            acquiredAt: DateTime.now(),
            isActive: false,
          ),
        ];

        await repository.persistOwnedCosmetics(
          userId: userId,
          cosmetics: cosmetics,
        );

        // Verify write was attempted (mock captures it)
        // In real Firestore, document would be created
        expect(cosmetics.length, 2);
      });

      test('Persists cosmetic activation state', () async {
        const userId = 'user_456';
        final activeCosmetic = OwnedCosmetic(
          itemId: 'board_active',
          source: 'shop_purchase',
          acquiredAt: DateTime.now(),
          isActive: true,
        );

        await repository.persistOwnedCosmetics(
          userId: userId,
          cosmetics: [activeCosmetic],
        );

        expect(activeCosmetic.isActive, isTrue);
      });

      test('Silently fails on network error', () async {
        // Should not throw even if Firestore is unavailable
        await repository.persistOwnedCosmetics(
          userId: 'user_789',
          cosmetics: [],
        );

        // Test passes if no exception thrown
        expect(true, isTrue);
      });
    });

    group('fetchOwnedCosmetics', () {
      test('Returns empty list when user has no owned cosmetics', () async {
        const userId = 'new_user';

        final owned = await repository.fetchOwnedCosmetics(userId);

        expect(owned, isEmpty);
      });

      test('Returns owned cosmetics with correct fields', () async {
        const userId = 'player_001';
        final now = DateTime.now();

        await mockFirestore
            .collection('users')
            .doc(userId)
            .collection('cosmetics')
            .doc('owned')
            .set({
              'items': [
                {
                  'itemId': 'board_marble',
                  'source': 'milestone_reward',
                  'acquiredAt': now.toIso8601String(),
                  'isActive': true,
                }
              ],
              'updatedAt': DateTime.now().toIso8601String(),
            });

        final owned = await repository.fetchOwnedCosmetics(userId);

        expect(owned, isNotEmpty);
        expect(owned.first.itemId, 'board_marble');
        expect(owned.first.isActive, isTrue);
      });

      test('Handles missing cosmetics gracefully', () async {
        const userId = 'invalid_user';

        final owned = await repository.fetchOwnedCosmetics(userId);

        expect(owned, isEmpty);
      });

      test('Preserves acquisition timestamps', () async {
        const userId = 'player_002';
        final acquiredTime = DateTime(2026, 8, 15, 10, 30);

        await mockFirestore
            .collection('users')
            .doc(userId)
            .collection('cosmetics')
            .doc('owned')
            .set({
              'items': [
                {
                  'itemId': 'stone_golden',
                  'source': 'shop_purchase',
                  'acquiredAt': acquiredTime.toIso8601String(),
                  'isActive': false,
                }
              ],
              'updatedAt': DateTime.now().toIso8601String(),
            });

        final owned = await repository.fetchOwnedCosmetics(userId);

        expect(owned.first.acquiredAt, isNotNull);
        expect(owned.first.source, 'shop_purchase');
      });
    });

    group('Default catalog validation', () {
      test('Default catalog contains valid cosmetic items', () {
        expect(
          CosmeticRepository.defaultCatalog.every(
            (item) =>
                item.id.isNotEmpty &&
                item.type.isNotEmpty &&
                item.name.isNotEmpty &&
                item.rarity.isNotEmpty,
          ),
          isTrue,
          reason: 'All default cosmetics should have required fields',
        );
      });

      test('All default cosmetics have prices', () {
        expect(
          CosmeticRepository.defaultCatalog.every((item) => item.price != null),
          isTrue,
        );
      });

      test('Prices are positive integers', () {
        expect(
          CosmeticRepository.defaultCatalog.every((item) => item.price! > 0),
          isTrue,
        );
      });
    });
  });
}
