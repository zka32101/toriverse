import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/round_result_model.dart';

/// Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Real-time listener for match document
/// Provides live updates when match state changes
final matchDocumentProvider =
    StreamProvider.family<DocumentSnapshot, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('matches').doc(matchId).snapshots();
});

/// Real-time listener for round results
/// Provides all round results for a match in order
final matchRoundResultsProvider =
    StreamProvider.family<List<RoundResultModel>, String>((ref, matchId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('roundResults')
      .where('matchId', isEqualTo: matchId)
      .orderBy('roundIndex', descending: false)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => RoundResultModel.fromJson(doc.data()))
        .toList();
  });
});

/// Fetch a specific round result
final roundResultProvider = FutureProvider.family<RoundResultModel?, String>(
  (ref, roundId) async {
    final firestore = ref.watch(firestoreProvider);
    final doc = await firestore.collection('roundResults').doc(roundId).get();
    if (!doc.exists) return null;
    return RoundResultModel.fromJson(doc.data()!);
  },
);

/// Write match data to Firestore
class FirestoreMatchRepository {
  final FirebaseFirestore _firestore;

  FirestoreMatchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Save a round result to Firestore
  Future<void> saveRoundResult(RoundResultModel result) async {
    try {
      await _firestore
          .collection('roundResults')
          .doc(result.id)
          .set(result.toJson());
    } catch (e) {
      throw Exception('Failed to save round result: $e');
    }
  }

  /// Update match document with new state
  Future<void> updateMatchState(
    String matchId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('matches').doc(matchId).update(updates);
    } catch (e) {
      throw Exception('Failed to update match state: $e');
    }
  }

  /// Get all matches for a user
  Future<List<DocumentSnapshot>> getUserMatches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('matches')
          .where('players', arrayContains: userId)
          .get();
      return snapshot.docs;
    } catch (e) {
      throw Exception('Failed to get user matches: $e');
    }
  }

  /// Create a new match document
  Future<String> createMatch({
    required List<String> playerIds,
    required String boardState,
  }) async {
    try {
      final doc = _firestore.collection('matches').doc();
      await doc.set({
        'id': doc.id,
        'players': playerIds,
        'boardState': boardState,
        'roundIndex': 0,
        'status': 'playing',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return doc.id;
    } catch (e) {
      throw Exception('Failed to create match: $e');
    }
  }

  /// End a match with results
  Future<void> endMatch(
    String matchId, {
    required List<String> winners,
    required List<int> finalScores,
  }) async {
    try {
      await _firestore.collection('matches').doc(matchId).update({
        'status': 'finished',
        'winners': winners,
        'finalScores': finalScores,
        'finishedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to end match: $e');
    }
  }
}

/// Provider for Firestore repository
final firestoreRepositoryProvider = Provider<FirestoreMatchRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreMatchRepository(firestore: firestore);
});
