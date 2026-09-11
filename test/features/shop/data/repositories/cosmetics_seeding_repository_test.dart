import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/data/repositories/cosmetics_seeding_repository.dart';
import 'package:toriverse/features/shop/data/seeds/cosmetics_seed_data.dart';

void main() {
  group('CosmeticsSeediingRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CosmeticsSeediingRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CosmeticsSeediingRepository(firestore: fakeFirestore);
    });

    test('seedAllCosmetics() seeds all cosmetics to Firestore', () async {
      final seededCount = await repository.seedAllCosmetics();

      expect(seededCount, CosmeticsSeedData.getAllCosmetics().length);

      // Verify cosmetics are in Firestore
      final snapshot = await fakeFirestore.collection('cosmetics').get();
      expect(snapshot.docs.length, CosmeticsSeedData.getAllCosmetics().length);
    });

    test('seedAllCosmetics() creates cosmetics with correct IDs', () async {
      await repository.seedAllCosmetics();

      final expectedIds =
          CosmeticsSeedData.getAllCosmetics().map((c) => c.id).toSet();
      final snapshot = await fakeFirestore.collection('cosmetics').get();
      final actualIds = snapshot.docs.map((d) => d.id).toSet();

      expect(actualIds, expectedIds);
    });

    test('seedAllCosmetics() seeds board cosmetics', () async {
      await repository.seedAllCosmetics();

      final boards = await fakeFirestore
          .collection('cosmetics')
          .where('typeString', isEqualTo: 'board')
          .get();

      expect(boards.docs.length, 5);
    });

    test('seedAllCosmetics() seeds stone cosmetics', () async {
      await repository.seedAllCosmetics();

      final blackStones = await fakeFirestore
          .collection('cosmetics')
          .where('typeString', isEqualTo: 'stoneBlack')
          .get();
      final whiteStones = await fakeFirestore
          .collection('cosmetics')
          .where('typeString', isEqualTo: 'stoneWhite')
          .get();
      final redStones = await fakeFirestore
          .collection('cosmetics')
          .where('typeString', isEqualTo: 'stoneRed')
          .get();

      expect(blackStones.docs.length, 5);
      expect(whiteStones.docs.length, 5);
      expect(redStones.docs.length, 5);
    });

    test('seedAllCosmetics() seeds limited edition cosmetics', () async {
      await repository.seedAllCosmetics();

      final limited = await fakeFirestore
          .collection('cosmetics')
          .where('rarity', isEqualTo: 'limited')
          .get();

      expect(limited.docs.length, 3);
    });

    test('seedAllCosmetics() is idempotent', () async {
      // First seed
      final count1 = await repository.seedAllCosmetics();

      // Second seed
      final count2 = await repository.seedAllCosmetics();

      expect(count1, count2);

      final snapshot = await fakeFirestore.collection('cosmetics').get();
      expect(snapshot.docs.length, count1);
    });

    test('verifySeedData() returns correct counts', () async {
      await repository.seedAllCosmetics();

      final result = await repository.verifySeedData();

      expect(result.expected, CosmeticsSeedData.getAllCosmetics().length);
      expect(result.found, result.expected);
    });

    test('verifySeedData() detects missing cosmetics', () async {
      // Seed only some cosmetics
      final boards = CosmeticsSeedData.getBoardCosmetics();
      for (final cosmetic in boards) {
        await fakeFirestore
            .collection('cosmetics')
            .doc(cosmetic.id)
            .set(cosmetic.toMap());
      }

      final result = await repository.verifySeedData();

      expect(result.found, boards.length);
      expect(result.expected, CosmeticsSeedData.getAllCosmetics().length);
      expect(result.found, lessThan(result.expected));
    });

    test('clearAllCosmetics() removes all cosmetics', () async {
      await repository.seedAllCosmetics();

      final deletedCount = await repository.clearAllCosmetics();

      expect(deletedCount, CosmeticsSeedData.getAllCosmetics().length);

      final snapshot = await fakeFirestore.collection('cosmetics').get();
      expect(snapshot.docs.length, 0);
    });

    test('getAllCosmeticsFromFirestore() retrieves seeded cosmetics', () async {
      await repository.seedAllCosmetics();

      final cosmetics = await repository.getAllCosmeticsFromFirestore();

      expect(cosmetics.length, CosmeticsSeedData.getAllCosmetics().length);

      final ids = cosmetics.map((c) => c.id).toSet();
      final expectedIds =
          CosmeticsSeedData.getAllCosmetics().map((c) => c.id).toSet();
      expect(ids, expectedIds);
    });

    test('getAllCosmeticsFromFirestore() retrieves correct cosmetic data',
        () async {
      await repository.seedAllCosmetics();

      final cosmetics = await repository.getAllCosmeticsFromFirestore();
      final classic =
          cosmetics.firstWhere((c) => c.id == 'board_classic');

      expect(classic.name, 'クラシック盤');
      expect(classic.typeString, 'board');
      expect(classic.priceJpy, 300);
      expect(classic.rarity.toString(), contains('common'));
    });

    test('getAllCosmeticsFromFirestore() handles empty Firestore', () async {
      final cosmetics = await repository.getAllCosmeticsFromFirestore();

      expect(cosmetics, isEmpty);
    });

    test('Seeded cosmetics have correct price structure', () async {
      await repository.seedAllCosmetics();

      final cosmetics = await repository.getAllCosmeticsFromFirestore();

      final boards = cosmetics.where((c) => c.typeString == 'board');
      expect(boards.every((c) => c.priceJpy == 300), true);

      final stones = cosmetics.where((c) =>
          c.typeString == 'stoneBlack' ||
          c.typeString == 'stoneWhite' ||
          c.typeString == 'stoneRed');
      expect(stones.every((c) => c.priceJpy == 120), true);

      final limited = cosmetics.where((c) => c.rarity.toString().contains('limited'));
      expect(limited.every((c) => c.priceJpy == 500), true);
    });

    test('Seeded cosmetics have descriptions', () async {
      await repository.seedAllCosmetics();

      final cosmetics = await repository.getAllCosmeticsFromFirestore();

      expect(cosmetics.every((c) => c.description != null), true);
      expect(cosmetics.every((c) => (c.description ?? '').isNotEmpty), true);
    });

    test('Limited edition cosmetics have availability windows', () async {
      await repository.seedAllCosmetics();

      final cosmetics = await repository.getAllCosmeticsFromFirestore();
      final limited = cosmetics
          .where((c) => c.rarity.toString().contains('limited'));

      for (final cosmetic in limited) {
        expect(cosmetic.availableFrom, isNotNull);
        expect(cosmetic.availableUntil, isNotNull);
      }
    });
  });
}
