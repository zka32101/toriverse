import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI takeover state for handling disconnected players
///
/// Tracks which players have been replaced by AI due to disconnection/inactivity.
/// Each takeover includes activation time and reason for debugging/analytics.
class AITakeoverState {
  /// Map of playerId -> takeover info (null = human, non-null = AI active)
  /// { playerId: { 'reason': 'inactivity'|'timeout', 'activatedAt': timestamp } }
  final Map<String, Map<String, dynamic>> activeTakeovers;

  /// Track consecutive timeouts per player (for analytics)
  final Map<String, int> consecutiveTimeouts;

  /// Flag: was this match affected by any AI takeover?
  /// Used for soft launch filtering (exclude AI-modified matches from metrics if needed)
  bool get hasAITakeover => activeTakeovers.isNotEmpty;

  /// List of player IDs currently controlled by AI
  List<String> get aiControlledPlayers => activeTakeovers.keys.toList();

  const AITakeoverState({
    required this.activeTakeovers,
    this.consecutiveTimeouts = const {},
  });

  /// Activate AI takeover for a player
  AITakeoverState activateTakeover({
    required String playerId,
    required String reason, // 'inactivity', 'timeout', 'manual'
  }) {
    final updated = Map<String, Map<String, dynamic>>.from(activeTakeovers);
    updated[playerId] = {
      'reason': reason,
      'activatedAt': DateTime.now().toIso8601String(),
    };

    final newTimeouts = Map<String, int>.from(consecutiveTimeouts);
    if (reason == 'timeout') {
      newTimeouts[playerId] = (newTimeouts[playerId] ?? 0) + 1;
    }

    return AITakeoverState(
      activeTakeovers: updated,
      consecutiveTimeouts: newTimeouts,
    );
  }

  /// Deactivate AI takeover (player reconnected)
  AITakeoverState deactivateTakeover(String playerId) {
    final updated = Map<String, Map<String, dynamic>>.from(activeTakeovers);
    updated.remove(playerId);

    final newTimeouts = Map<String, int>.from(consecutiveTimeouts);
    newTimeouts[playerId] = 0; // Reset timeout counter on reconnect

    return AITakeoverState(
      activeTakeovers: updated,
      consecutiveTimeouts: newTimeouts,
    );
  }

  /// Check if a specific player is AI-controlled
  bool isAIControlled(String playerId) {
    return activeTakeovers.containsKey(playerId);
  }

  /// Initialize empty takeover state (new match)
  static AITakeoverState create() {
    return const AITakeoverState(
      activeTakeovers: {},
      consecutiveTimeouts: {},
    );
  }
}

/// Notifier for managing AI takeover state
class AITakeoverNotifier extends StateNotifier<AITakeoverState> {
  AITakeoverNotifier() : super(AITakeoverState.create());

  /// Activate AI takeover for a player
  void activateTakeover({required String playerId, required String reason}) {
    state = state.activateTakeover(playerId: playerId, reason: reason);
  }

  /// Deactivate AI takeover (player reconnected)
  void deactivateTakeover(String playerId) {
    state = state.deactivateTakeover(playerId);
  }

  /// Reset for new match
  void reset() {
    state = AITakeoverState.create();
  }
}

/// Provider for AI takeover state
final aiTakeoverProvider =
    StateNotifierProvider<AITakeoverNotifier, AITakeoverState>((ref) {
  return AITakeoverNotifier();
});
