import 'package:riverpod/riverpod.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';
import '../../../match/application/providers/firestore_round_result_service_provider.dart';

/// Match results with player ranking information
class MatchResult {
  final String matchId;
  final List<String> playerIds;
  final Map<String, int> stoneCounts;
  final int totalRounds;
  final DateTime? completedAt;

  MatchResult({
    required this.matchId,
    required this.playerIds,
    required this.stoneCounts,
    required this.totalRounds,
    required this.completedAt,
  });

  /// Get player rankings sorted by stone count (highest first)
  List<(String, int, int)> get playerRankings {
    final entries = stoneCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    final rankings = <(String, int, int)>[];
    for (int i = 0; i < entries.length; i++) {
      rankings.add((entries[i].key, i + 1, entries[i].value));
    }
    return rankings;
  }

  /// Get winner player ID
  String? get winnerId {
    if (stoneCounts.isEmpty) return null;
    return stoneCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

/// Fetch match results from Firestore
/// Provides game statistics and ranking information
final matchResultProvider =
    FutureProvider.family<MatchResult?, String>((ref, matchId) async {
  final firestoreService = ref.watch(firestoreRoundResultServiceProvider);

  try {
    // Fetch the latest round result which contains completion info
    final latestRound =
        await firestoreService.fetchLatestRoundResult(matchId);

    if (latestRound == null) {
      return null;
    }

    // In a production app, we would fetch the full match document to get:
    // - Player IDs
    // - Player names
    // - Start time, end time
    // - Match status
    // etc.

    // For now, return null to indicate results not yet persisted
    // This will be enhanced when we have full match persistence

    return null;
  } catch (e) {
    return null;
  }
});

/// Check if match is complete (finished status)
final isMatchCompleteProvider =
    FutureProvider.family<bool, String>((ref, matchId) async {
  final firestoreService = ref.watch(firestoreRoundResultServiceProvider);

  try {
    final isComplete = await firestoreService.isMatchComplete(matchId);
    return isComplete;
  } catch (e) {
    return false;
  }
});

/// Fetch all round results for a match
final matchRoundResultsProvider =
    FutureProvider.family<List<RoundResultModel>, String>(
        (ref, matchId) async {
  final firestoreService = ref.watch(firestoreRoundResultServiceProvider);

  try {
    return await firestoreService.fetchMatchRoundResults(matchId);
  } catch (e) {
    return [];
  }
});
