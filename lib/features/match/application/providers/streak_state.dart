import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents player's match completion streak
///
/// Tracks consecutive completed matches. Incremented on match finish.
/// Reset on manual quit or connection timeout (but NOT on AI takeover).
class StreakState {
  /// Current active streak count
  final int currentStreak;

  /// All-time best streak (never decreases)
  final int bestStreak;

  /// Timestamp of last match completion
  final DateTime? lastCompletedAt;

  /// Reason streak was reset (null = active)
  /// Values: 'manual_quit', 'connection_timeout', 'system_error'
  final String? streakResetReason;

  /// Timestamp when streak was last reset
  final DateTime? streakResetAt;

  /// Milestone boundaries for rewards and badges
  static final milestoneBoundaries = [3, 5, 10, 25, 50, 100];

  const StreakState({
    required this.currentStreak,
    required this.bestStreak,
    this.lastCompletedAt,
    this.streakResetReason,
    this.streakResetAt,
  });

  /// Computed: Is the streak currently active?
  bool get isStreakActive => streakResetReason == null;

  /// Computed: Is current streak at a milestone boundary?
  bool get isAtMilestone => milestoneBoundaries.contains(currentStreak);

  /// Computed: What is the next milestone after current streak?
  int get nextMilestone {
    for (final boundary in milestoneBoundaries) {
      if (boundary > currentStreak) return boundary;
    }
    // If at or past highest milestone, return next round number
    return ((currentStreak ~/ 25) + 1) * 25;
  }

  /// Check if a value is at a milestone
  static bool isMilestone(int value) => milestoneBoundaries.contains(value);

  /// Initialize empty streak for new player
  static StreakState create() {
    return const StreakState(
      currentStreak: 0,
      bestStreak: 0,
    );
  }

  /// Record a match completion (increment streak)
  StreakState recordCompletion() {
    final newStreak = currentStreak + 1;
    final newBest = newStreak > bestStreak ? newStreak : bestStreak;

    return StreakState(
      currentStreak: newStreak,
      bestStreak: newBest,
      lastCompletedAt: DateTime.now(),
      streakResetReason: null, // Active streak continues
      streakResetAt: streakResetAt,
    );
  }

  /// Reset streak due to player action or timeout
  /// [reason]: 'manual_quit', 'connection_timeout', 'system_error'
  StreakState resetStreak(String reason) {
    return StreakState(
      currentStreak: 0,
      bestStreak: bestStreak, // Best streak never decreases
      lastCompletedAt: lastCompletedAt,
      streakResetReason: reason,
      streakResetAt: DateTime.now(),
    );
  }

  /// Resume active streak after being inactive
  /// (Called when player resumes play without losing streak)
  StreakState resume() {
    return StreakState(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      lastCompletedAt: DateTime.now(),
      streakResetReason: null,
      streakResetAt: streakResetAt,
    );
  }

  /// Merge with server state (for sync)
  /// Prefers higher values to avoid streak loss on sync
  StreakState mergeWithServer(StreakState remote) {
    // If remote has higher current streak, use it
    // Unless we're in active state and remote is reset
    if (remote.isStreakActive && !isStreakActive) {
      return remote; // Remote streak is active, use it
    } else if (isStreakActive && !remote.isStreakActive) {
      return this; // Local streak is active, keep it
    }

    // Both active or both reset: use higher current streak
    if (remote.currentStreak > currentStreak) {
      return remote;
    }
    return this;
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'streakResetReason': streakResetReason,
      'streakResetAt': streakResetAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  static StreakState fromFirestore(Map<String, dynamic> data) {
    return StreakState(
      currentStreak: data['currentStreak'] as int? ?? 0,
      bestStreak: data['bestStreak'] as int? ?? 0,
      lastCompletedAt: data['lastCompletedAt'] != null
          ? DateTime.parse(data['lastCompletedAt'] as String)
          : null,
      streakResetReason: data['streakResetReason'] as String?,
      streakResetAt: data['streakResetAt'] != null
          ? DateTime.parse(data['streakResetAt'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'StreakState(current=$currentStreak, best=$bestStreak, active=$isStreakActive)';
}

/// Notifier for managing streak state
class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier() : super(StreakState.create());

  /// Record a match completion (increment streak)
  void recordMatchCompletion() {
    state = state.recordCompletion();
  }

  /// Reset streak due to player abandoning match
  /// [reason]: 'manual_quit', 'connection_timeout', 'system_error'
  void resetStreak(String reason) {
    state = state.resetStreak(reason);
  }

  /// Resume active streak after inactivity
  void resume() {
    state = state.resume();
  }

  /// Sync with server state
  void syncFromServer(StreakState remote) {
    state = state.mergeWithServer(remote);
  }

  /// Reset to initial state (logout, new account)
  void reset() {
    state = StreakState.create();
  }
}

/// Provider for streak state
final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier();
});

/// Provider for current streak (read-only)
final currentStreakProvider = Provider<int>((ref) {
  return ref.watch(streakProvider).currentStreak;
});

/// Provider for best streak (read-only)
final bestStreakProvider = Provider<int>((ref) {
  return ref.watch(streakProvider).bestStreak;
});

/// Provider for streak active status (read-only)
final streakActiveProvider = Provider<bool>((ref) {
  return ref.watch(streakProvider).isStreakActive;
});

/// Provider for next milestone (read-only)
final nextMilestoneProvider = Provider<int>((ref) {
  return ref.watch(streakProvider).nextMilestone;
});

/// Provider for checking if at milestone (read-only)
final isAtMilestoneProvider = Provider<bool>((ref) {
  return ref.watch(streakProvider).isAtMilestone;
});
