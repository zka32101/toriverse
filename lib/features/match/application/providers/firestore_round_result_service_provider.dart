import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_round_result_service.dart';
import '../services/offline_queue_service.dart';
import 'firestore_match_provider.dart';

/// Riverpod provider for Firestore round result service
/// Includes offline queue support for automatic operation queuing on failures
final firestoreRoundResultServiceProvider =
    Provider<FirestoreRoundResultService>((ref) {
  final repository = FirestoreMatchRepository();

  // Create offline queue service for retry management
  final offlineQueue = OfflineQueueService();

  return FirestoreRoundResultService(
    repository: repository,
    offlineQueue: offlineQueue,
  );
});
