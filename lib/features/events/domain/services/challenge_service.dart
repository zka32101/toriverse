import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/event_model.dart';

/// Service for managing event challenges
class ChallengeService {
  final FirebaseFirestore _firestore;

  const ChallengeService(this._firestore);

  /// Get daily challenges for a user in an event
  Future<List<Challenge>> getDailyChallenges({
    required String eventId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('challenges')
          .where('isDaily', isEqualTo: true)
          .where('endDate', isGreaterThan: DateTime.now())
          .orderBy('endDate')
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get weekly challenges
  Future<List<Challenge>> getWeeklyChallenges({
    required String eventId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('challenges')
          .where('isDaily', isEqualTo: false)
          .where('endDate', isGreaterThan: DateTime.now())
          .orderBy('endDate')
          .get();

      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get single challenge details
  Future<Challenge?> getChallengeDetails({
    required String eventId,
    required String challengeId,
  }) async {
    try {
      final doc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('challenges')
          .doc(challengeId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return Challenge.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get user's progress on a specific challenge
  Future<int> getChallengeProgress({
    required String uid,
    required String eventId,
    required String challengeId,
  }) async {
    try {
      // In a real implementation, this would track progress from match history
      // For now, return 0 (not started)
      final progressDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      if (!progressDoc.exists) {
        return 0;
      }

      final completed =
          (progressDoc.data()?['completedChallenges'] as List?)?.cast<String>() ??
              [];
      return completed.contains(challengeId) ? 100 : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Validate if a challenge is completed
  Future<bool> validateChallengeCompletion({
    required String uid,
    required String eventId,
    required String challengeId,
  }) async {
    try {
      final challenge = await getChallengeDetails(
        eventId: eventId,
        challengeId: challengeId,
      );

      if (challenge == null) {
        return false;
      }

      // This is simplified - in production, would check actual match history
      // and validate against challenge conditions
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mark challenge as completed and award reward
  Future<void> completeChallenge({
    required String uid,
    required String eventId,
    required String challengeId,
  }) async {
    try {
      final challenge = await getChallengeDetails(
        eventId: eventId,
        challengeId: challengeId,
      );

      if (challenge == null) {
        throw Exception('Challenge not found');
      }

      // Mark as completed
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .update({
        'completedChallenges': FieldValue.arrayUnion([challengeId]),
        'totalScore': FieldValue.increment(challenge.reward.rankPoints),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Unlock cosmetic if specified
      if (challenge.reward.cosmeticId.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .collection('eventCosmetics')
            .doc(challenge.reward.cosmeticId)
            .set({
          'cosmeticId': challenge.reward.cosmeticId,
          'eventId': eventId,
          'unlockedAt': FieldValue.serverTimestamp(),
          'method': 'challenge',
          'equipped': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get challenge completion count for user in event
  Future<int> getChallengeCompletionCount({
    required String uid,
    required String eventId,
  }) async {
    try {
      final progressDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      if (!progressDoc.exists) {
        return 0;
      }

      final completed =
          (progressDoc.data()?['completedChallenges'] as List?)
              ?.length ??
              0;
      return completed;
    } catch (e) {
      return 0;
    }
  }

  /// Get all completed challenges for user in event
  Future<List<String>> getCompletedChallenges({
    required String uid,
    required String eventId,
  }) async {
    try {
      final progressDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('eventProgress')
          .doc(eventId)
          .get();

      if (!progressDoc.exists) {
        return [];
      }

      return List<String>.from(
        (progressDoc.data()?['completedChallenges'] as List?) ?? [],
      );
    } catch (e) {
      return [];
    }
  }

  /// Get reward points for a challenge
  Future<int> getChallengeRewardPoints({
    required String eventId,
    required String challengeId,
  }) async {
    try {
      final challenge = await getChallengeDetails(
        eventId: eventId,
        challengeId: challengeId,
      );

      return challenge?.reward.rankPoints ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Reset daily challenges for user (call daily)
  Future<void> resetDailyChallenges({
    required String uid,
    required String eventId,
  }) async {
    try {
      // Get daily challenges
      final dailySnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('challenges')
          .where('isDaily', isEqualTo: true)
          .get();

      if (dailySnapshot.docs.isEmpty) {
        return;
      }

      // Reset completed challenges tracking (actual implementation would be more complex)
      // For now, this is a placeholder
    } catch (e) {
      // Silent failure
    }
  }

  /// Watch challenges stream for an event
  Stream<List<Challenge>> watchChallenges(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('challenges')
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Challenge.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).handleError((e) {
      return [];
    });
  }
}
