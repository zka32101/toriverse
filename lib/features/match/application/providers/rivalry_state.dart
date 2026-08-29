import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rivalry scores aggregated from recent rounds
/// Structure: { attacker_index: { target_index: stone_count } }
///
/// This tracks "who attacked whom" over the last 3 rounds,
/// enabling the rivalry indicator to show alliances/2v1 dynamics.
class RivalryState {
  /// Accumulates attack breakdowns from recent rounds
  /// List order: oldest → newest
  /// Each element: { attacker_index: { target_index: stone_count } }
  final List<Map<int, Map<int, int>>> recentRounds;

  /// Aggregated scores from recentRounds
  /// Computed lazily on demand via aggregateScores()
  final Map<int, Map<int, int>>? _cachedScores;

  const RivalryState({
    required this.recentRounds,
    Map<int, Map<int, int>>? cachedScores,
  }) : _cachedScores = cachedScores;

  /// Get aggregated rivalry scores across recent rounds
  Map<int, Map<int, int>> getAggregatedScores() {
    if (_cachedScores != null) {
      return _cachedScores!;
    }

    final scores = <int, Map<int, int>>{};
    for (final round in recentRounds) {
      round.forEach((attacker, targets) {
        final attackerScores = scores.putIfAbsent(attacker, () => {});
        targets.forEach((target, count) {
          attackerScores[target] = (attackerScores[target] ?? 0) + count;
        });
      });
    }
    return scores;
  }

  /// Add a new round's attack breakdown to the history
  RivalryState addRound(Map<int, Map<int, int>> roundBreakdown) {
    final updated = List<Map<int, Map<int, int>>>.from(recentRounds);
    updated.add(roundBreakdown);

    // Keep only last 3 rounds (default window)
    if (updated.length > 3) {
      updated.removeAt(0);
    }

    return RivalryState(
      recentRounds: updated,
      cachedScores: null, // Invalidate cache
    );
  }

  /// Reset rivalry tracking (new match)
  static RivalryState create() {
    return const RivalryState(recentRounds: []);
  }
}

/// Notifier for managing rivalry state
class RivalryNotifier extends StateNotifier<RivalryState> {
  RivalryNotifier() : super(RivalryState.create());

  /// Add a round's attack breakdown
  void recordRound(Map<int, Map<int, int>> roundBreakdown) {
    state = state.addRound(roundBreakdown);
  }

  /// Reset to new match
  void reset() {
    state = RivalryState.create();
  }
}

/// Provider for rivalry tracking across rounds
final rivalryProvider =
    StateNotifierProvider<RivalryNotifier, RivalryState>((ref) {
  return RivalryNotifier();
});
