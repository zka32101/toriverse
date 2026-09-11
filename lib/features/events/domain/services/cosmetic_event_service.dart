import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/cosmetic_model.dart';

/// Service for managing event cosmetics
class CosmeticEventService {
  final FirebaseFirestore _firestore;

  const CosmeticEventService(this._firestore);

  /// Get all limited cosmetics for an event
  Future<List<LimitedCosmetic>> getLimitedCosmetics(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('cosmetics')
          .doc('limited')
          .collection(eventId)
          .get();

      return snapshot.docs
          .map((doc) =>
              LimitedCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get limited cosmetics as a stream
  Stream<List<LimitedCosmetic>> watchLimitedCosmetics(String eventId) {
    return _firestore
        .collection('cosmetics')
        .doc('limited')
        .collection(eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              LimitedCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Get single limited cosmetic details
  Future<LimitedCosmetic?> getCosmeticDetails({
    required String eventId,
    required String cosmeticId,
  }) async {
    try {
      final doc = await _firestore
          .collection('cosmetics')
          .doc('limited')
          .collection(eventId)
          .doc(cosmeticId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return LimitedCosmetic.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Unlock a cosmetic for a user
  Future<void> unlockCosmetic({
    required String uid,
    required String cosmeticId,
    required String eventId,
    String method = 'challenge',
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .doc(cosmeticId)
          .set({
        'cosmeticId': cosmeticId,
        'eventId': eventId,
        'unlockedAt': FieldValue.serverTimestamp(),
        'method': method,
        'equipped': false,
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user has unlocked a cosmetic
  Future<bool> hasUnlockedCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .doc(cosmeticId)
          .get();

      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get user's unlocked cosmetics for an event
  Future<List<UserEventCosmetic>> getUnlockedCosmetics({
    required String uid,
    required String eventId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs
          .map((doc) =>
              UserEventCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Watch user's unlocked cosmetics stream
  Stream<List<UserEventCosmetic>> watchUnlockedCosmetics({
    required String uid,
    required String eventId,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('eventCosmetics')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              UserEventCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }

  /// Equip a cosmetic
  Future<void> equipCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .doc(cosmeticId)
          .update({'equipped': true});
    } catch (e) {
      rethrow;
    }
  }

  /// Unequip a cosmetic
  Future<void> unequipCosmetic({
    required String uid,
    required String cosmeticId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .doc(cosmeticId)
          .update({'equipped': false});
    } catch (e) {
      rethrow;
    }
  }

  /// Get currently equipped cosmetic for user
  Future<UserEventCosmetic?> getEquippedCosmetic(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .where('equipped', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return UserEventCosmetic.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if cosmetic is event exclusive
  Future<bool> isEventExclusive({
    required String eventId,
    required String cosmeticId,
  }) async {
    try {
      final cosmetic = await getCosmeticDetails(
        eventId: eventId,
        cosmeticId: cosmeticId,
      );

      return cosmetic?.eventExclusive ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get cosmetics by rarity
  Future<List<LimitedCosmetic>> getCosmeticsByRarity({
    required String eventId,
    required String rarity,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('cosmetics')
          .doc('limited')
          .collection(eventId)
          .where('rarity', isEqualTo: rarity)
          .get();

      return snapshot.docs
          .map((doc) =>
              LimitedCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get cosmetics by type
  Future<List<LimitedCosmetic>> getCosmeticsByType({
    required String eventId,
    required String type,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('cosmetics')
          .doc('limited')
          .collection(eventId)
          .where('type', isEqualTo: type)
          .get();

      return snapshot.docs
          .map((doc) =>
              LimitedCosmetic.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Count unlocked cosmetics for user in event
  Future<int> getUnlockedCosmeticCount({
    required String uid,
    required String eventId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventCosmetics')
          .where('eventId', isEqualTo: eventId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
