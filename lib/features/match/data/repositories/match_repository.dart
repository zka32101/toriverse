import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match_model.dart';

/// Repository for Firestore match operations
class MatchRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'matches';

  MatchRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new match document
  Future<String> createMatch(MatchModel match) async {
    final doc = await _firestore
        .collection(_collectionPath)
        .add(match.toJson());
    return doc.id;
  }

  /// Get match by ID
  Future<MatchModel?> getMatchById(String matchId) async {
    final doc =
        await _firestore.collection(_collectionPath).doc(matchId).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return MatchModel.fromJson({...data, 'id': doc.id});
  }

  /// Update match status
  Future<void> updateMatchStatus(String matchId, String status) async {
    await _firestore.collection(_collectionPath).doc(matchId).update({
      'status': status,
    });
  }

  /// Update match board state
  Future<void> updateBoardState(String matchId, List<int> boardState, int roundIndex) async {
    await _firestore.collection(_collectionPath).doc(matchId).update({
      'boardState': boardState,
      'roundIndex': roundIndex,
    });
  }

  /// Add ready player
  Future<void> addReadyPlayer(String matchId, String playerId) async {
    await _firestore.collection(_collectionPath).doc(matchId).update({
      'readyPlayers': FieldValue.arrayUnion([playerId]),
    });
  }

  /// Set match as started
  Future<void> markMatchStarted(String matchId) async {
    await _firestore.collection(_collectionPath).doc(matchId).update({
      'status': 'playing',
      'startedAt': FieldValue.serverTimestamp(),
      'currentPhase': 'submitPhase',
    });
  }

  /// Set match as finished with final scores
  Future<void> markMatchFinished(String matchId, List<int> finalScores) async {
    await _firestore.collection(_collectionPath).doc(matchId).update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
      'finalScores': finalScores,
    });
  }

  /// Get matches for a user (as player)
  Future<List<MatchModel>> getMatchesByPlayerId(String playerId, {int limit = 10}) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('players', arrayContains: playerId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MatchModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Stream match updates (real-time listener)
  Stream<MatchModel?> streamMatch(String matchId) {
    return _firestore
        .collection(_collectionPath)
        .doc(matchId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return MatchModel.fromJson({...data, 'id': doc.id});
    });
  }
}
