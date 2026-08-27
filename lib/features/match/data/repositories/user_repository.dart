import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Repository for Firestore user operations
class UserRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'users';

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new user document
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(_collectionPath)
        .doc(user.uid)
        .set(user.toJson());
  }

  /// Get user by UID
  Future<UserModel?> getUserByUid(String uid) async {
    final doc =
        await _firestore.collection(_collectionPath).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }

  /// Update user rank points
  Future<void> addRankPoints(String uid, int points) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'rankPoints': FieldValue.increment(points),
    });
  }

  /// Increment completed match streak
  Future<void> incrementStreak(String uid) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'completedMatchStreak': FieldValue.increment(1),
      'lastPlayedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Reset completed match streak
  Future<void> resetStreak(String uid) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'completedMatchStreak': 0,
    });
  }

  /// Use free match
  Future<void> useFreeMatch(String uid) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'freeMatchUsedToday': FieldValue.increment(1),
    });
  }

  /// Reset daily free match quota
  Future<void> resetDailyFreeMatch(String uid) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'freeMatchUsedToday': 0,
      'lastDailyResetAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update subscription status
  Future<void> updateSubscriptionStatus(String uid, String status) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'subscriptionStatus': status,
    });
  }

  /// Add cosmetic item to user's collection
  Future<void> addCosmetic(String uid, String cosmeticId) async {
    await _firestore.collection(_collectionPath).doc(uid).update({
      'ownedCosmetics': FieldValue.arrayUnion([cosmeticId]),
    });
  }

  /// Logout: null-safe deletion not needed in Firestore (auth handled separately)
  /// This is a marker method for consistency
  Future<void> logout(String uid) async {
    // Auth logout is handled by FirebaseAuth
    // User document remains in Firestore for historical data
  }
}
