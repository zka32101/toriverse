import 'package:flutter/foundation.dart';

/// Monitors player inactivity and detects disconnections
///
/// Tracks the last activity (move submission) for each player.
/// If a player doesn't submit within the configured timeout,
/// they are marked as inactive and eligible for AI takeover.
class InactivityMonitor {
  /// Last activity timestamp per player
  final Map<String, DateTime> lastActivityByPlayer;

  /// Inactivity timeout in milliseconds (default: 45 seconds)
  /// If no activity for 45s, player is assumed disconnected
  final int inactivityTimeoutMs;

  InactivityMonitor({
    required this.lastActivityByPlayer,
    this.inactivityTimeoutMs = 45000,
  });

  /// Record activity for a player
  InactivityMonitor recordActivity(String playerId) {
    final updated = Map<String, DateTime>.from(lastActivityByPlayer);
    updated[playerId] = DateTime.now();
    return InactivityMonitor(
      lastActivityByPlayer: updated,
      inactivityTimeoutMs: inactivityTimeoutMs,
    );
  }

  /// Check if a player is inactive
  bool isInactive(String playerId) {
    final lastActivity = lastActivityByPlayer[playerId];
    if (lastActivity == null) return false;

    final elapsed = DateTime.now().difference(lastActivity).inMilliseconds;
    return elapsed > inactivityTimeoutMs;
  }

  /// Get list of inactive players
  List<String> getInactivePlayers(List<String> allPlayers) {
    return allPlayers.where((playerId) => isInactive(playerId)).toList();
  }

  /// Get time remaining until player is marked inactive (milliseconds)
  /// Returns 0 if already inactive, negative if player never recorded activity
  int msUntilInactive(String playerId) {
    final lastActivity = lastActivityByPlayer[playerId];
    if (lastActivity == null) return inactivityTimeoutMs;

    final elapsed = DateTime.now().difference(lastActivity).inMilliseconds;
    return (inactivityTimeoutMs - elapsed).clamp(0, inactivityTimeoutMs);
  }

  /// Initialize with fresh activity for all players
  static InactivityMonitor create({
    required List<String> playerIds,
    int inactivityTimeoutMs = 45000,
  }) {
    final now = DateTime.now();
    return InactivityMonitor(
      lastActivityByPlayer: {for (final id in playerIds) id: now},
      inactivityTimeoutMs: inactivityTimeoutMs,
    );
  }

  /// Reset inactivity counter for all players (new round)
  InactivityMonitor resetAllActivity() {
    final now = DateTime.now();
    return InactivityMonitor(
      lastActivityByPlayer: {
        for (final id in lastActivityByPlayer.keys) id: now
      },
      inactivityTimeoutMs: inactivityTimeoutMs,
    );
  }

  @override
  String toString() =>
      'InactivityMonitor(inactive=${getInactivePlayers(lastActivityByPlayer.keys.toList()).length}/${lastActivityByPlayer.length})';
}

/// Tracks submission state per player for the current round
///
/// Different from InactivityMonitor: this tracks whether a player
/// has submitted their move in the current round specifically.
/// Timeout on submission = immediate AI takeover trigger.
class RoundSubmissionMonitor {
  /// Submission time per player in current round
  final Map<String, DateTime?> submissionTimeByPlayer;

  /// Timeout in milliseconds for submission window
  /// Default: 30s per Remote Config
  final int submissionTimeoutMs;

  /// Timestamp when this round started
  final DateTime roundStartedAt;

  RoundSubmissionMonitor({
    required this.submissionTimeByPlayer,
    required this.roundStartedAt,
    this.submissionTimeoutMs = 30000,
  });

  /// Record submission for a player
  RoundSubmissionMonitor recordSubmission(String playerId) {
    final updated = Map<String, DateTime?>.from(submissionTimeByPlayer);
    updated[playerId] = DateTime.now();
    return RoundSubmissionMonitor(
      submissionTimeByPlayer: updated,
      roundStartedAt: roundStartedAt,
      submissionTimeoutMs: submissionTimeoutMs,
    );
  }

  /// Check if a player has submitted this round
  bool hasSubmitted(String playerId) {
    return submissionTimeByPlayer[playerId] != null;
  }

  /// Check if a player's submission has timed out
  bool isSubmissionTimedOut(String playerId) {
    if (hasSubmitted(playerId)) return false;

    final elapsed = DateTime.now().difference(roundStartedAt).inMilliseconds;
    return elapsed > submissionTimeoutMs;
  }

  /// Get list of players who timed out (didn't submit)
  List<String> getTimedOutPlayers(List<String> allPlayers) {
    return allPlayers
        .where((playerId) => isSubmissionTimedOut(playerId))
        .toList();
  }

  /// Get time remaining for submission window (milliseconds)
  int msUntilSubmissionTimeout() {
    final elapsed = DateTime.now().difference(roundStartedAt).inMilliseconds;
    return (submissionTimeoutMs - elapsed).clamp(0, submissionTimeoutMs);
  }

  /// Initialize for new round
  static RoundSubmissionMonitor create({
    required List<String> playerIds,
    int submissionTimeoutMs = 30000,
  }) {
    return RoundSubmissionMonitor(
      submissionTimeByPlayer: {for (final id in playerIds) id: null},
      roundStartedAt: DateTime.now(),
      submissionTimeoutMs: submissionTimeoutMs,
    );
  }

  @override
  String toString() =>
      'RoundSubmissionMonitor(submitted=${submissionTimeByPlayer.values.where((t) => t != null).length}/${submissionTimeByPlayer.length})';
}
