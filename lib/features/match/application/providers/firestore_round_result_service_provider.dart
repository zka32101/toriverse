import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_round_result_service.dart';
import 'firestore_match_provider.dart';

/// Riverpod provider for Firestore round result service
final firestoreRoundResultServiceProvider =
    Provider<FirestoreRoundResultService>((ref) {
  final repository = FirestoreMatchRepository();
  return FirestoreRoundResultService(repository: repository);
});
