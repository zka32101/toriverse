import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/round_result_model.dart';

/// Repository for Firestore round result operations
class RoundResultRepository {
  final FirebaseFirestore _firestore;
  static const String _collectionPath = 'roundResults';

  RoundResultRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Create a new round result document
  Future<void> createRoundResult(RoundResultModel result) async {
    await _firestore
        .collection(_collectionPath)
        .doc(result.id)
        .set(result.toJson());
  }

  /// Get round result by ID
  Future<RoundResultModel?> getRoundResultById(String id) async {
    final doc = await _firestore.collection(_collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    return RoundResultModel.fromJson({...data, 'id': doc.id});
  }

  /// Update round result as processed
  Future<void> markRoundProcessed(
    String id,
    List<String> processOrder,
    String? bonusTriggered,
    List<String> rescueCardsGranted,
  ) async {
    await _firestore.collection(_collectionPath).doc(id).update({
      'processedAt': FieldValue.serverTimestamp(),
      'processOrder': processOrder,
      'bonusTriggered': bonusTriggered ?? '',
      'rescueCardsGranted': rescueCardsGranted,
    });
  }

  /// Add replay events for animation
  Future<void> addReplayEvents(String id, List<Map<String, dynamic>> events) async {
    await _firestore.collection(_collectionPath).doc(id).update({
      'replayEvents': FieldValue.arrayUnion(
          events.map((e) => {'type': e['type'], 'data': e['data'], 'delayMs': e['delayMs'] ?? 0}).toList()),
    });
  }

  /// Get all round results for a match
  Future<List<RoundResultModel>> getRoundResultsByMatchId(String matchId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('matchId', isEqualTo: matchId)
        .orderBy('roundIndex')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return RoundResultModel.fromJson({...data, 'id': doc.id});
    }).toList();
  }

  /// Stream specific round result (real-time updates)
  Stream<RoundResultModel?> streamRoundResult(String id) {
    return _firestore
        .collection(_collectionPath)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return RoundResultModel.fromJson({...data, 'id': doc.id});
    });
  }
}
