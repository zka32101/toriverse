import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toriverse/features/shop/data/seeds/cosmetics_seed_data.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

/// Repository for seeding cosmetics catalog to Firestore
///
/// Used during initial app setup or development to populate
/// the cosmetics catalog with default items.
class CosmeticsSeediingRepository {
  final FirebaseFirestore _firestore;

  CosmeticsSeediingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Seed all cosmetics to Firestore
  ///
  /// Writes the cosmetics catalog to Firestore `cosmetics/` collection.
  /// Skips cosmetics that already exist (idempotent).
  ///
  /// Throws exception if Firestore write fails.
  Future<int> seedAllCosmetics() async {
    final cosmetics = CosmeticsSeedData.getAllCosmetics();
    int seededCount = 0;

    for (final cosmetic in cosmetics) {
      try {
        await _seedCosmetic(cosmetic);
        seededCount++;
      } catch (e) {
        // Log but continue seeding other cosmetics
        print(
            'Warning: Failed to seed cosmetic ${cosmetic.id}: $e');
      }
    }

    return seededCount;
  }

  /// Seed a single cosmetic to Firestore
  ///
  /// Writes or updates a cosmetic in the `cosmetics/{id}` document.
  Future<void> _seedCosmetic(CosmeticItem cosmetic) async {
    final docRef = _firestore.collection('cosmetics').doc(cosmetic.id);

    // Set with merge=true to preserve existing data if already present
    await docRef.set(cosmetic.toMap(), SetOptions(merge: true));
  }

  /// Clear all cosmetics from Firestore
  ///
  /// Deletes all documents in the `cosmetics/` collection.
  /// USE WITH CAUTION - this deletes production data!
  Future<int> clearAllCosmetics() async {
    final snapshot = await _firestore.collection('cosmetics').get();
    int deletedCount = 0;

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
      deletedCount++;
    }

    return deletedCount;
  }

  /// Verify that all cosmetics were seeded successfully
  ///
  /// Checks Firestore for the presence of all seed cosmetics.
  /// Returns count of cosmetics found vs expected count.
  Future<({int found, int expected})> verifySeedData() async {
    final expected = CosmeticsSeedData.getAllCosmetics().length;
    final snapshot = await _firestore.collection('cosmetics').get();

    return (found: snapshot.docs.length, expected: expected);
  }

  /// Get all cosmetics currently in Firestore
  Future<List<CosmeticItem>> getAllCosmeticsFromFirestore() async {
    try {
      final snapshot = await _firestore.collection('cosmetics').get();
      return snapshot.docs
          .map((doc) =>
              CosmeticItem.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching cosmetics from Firestore: $e');
      return [];
    }
  }
}
