import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/inactivity_monitor.dart';

/// Provider for tracking round submission state
/// (separate from general inactivity)
class RoundSubmissionMonitorNotifier
    extends StateNotifier<RoundSubmissionMonitor?> {
  RoundSubmissionMonitorNotifier() : super(null);

  /// Start monitoring submissions for a new round
  void startMonitoring({
    required List<String> playerIds,
    int submissionTimeoutMs = 30000,
  }) {
    state = RoundSubmissionMonitor.create(
      playerIds: playerIds,
      submissionTimeoutMs: submissionTimeoutMs,
    );
  }

  /// Record a player's submission
  void recordSubmission(String playerId) {
    final current = state;
    if (current != null) {
      state = current.recordSubmission(playerId);
    }
  }

  /// Reset for next round
  void reset() {
    state = null;
  }
}

/// Provider for round submission monitoring
final roundSubmissionMonitorProvider = StateNotifierProvider<
    RoundSubmissionMonitorNotifier,
    RoundSubmissionMonitor?>((ref) {
  return RoundSubmissionMonitorNotifier();
});

/// Stream that monitors submission timeouts
/// Emits the milliseconds remaining in submission window
final submissionTimeoutStreamProvider =
    StreamProvider<int>((ref) async* {
  final monitor = ref.watch(roundSubmissionMonitorProvider);
  if (monitor == null) {
    yield 0;
    return;
  }

  while (true) {
    final remaining = monitor.msUntilSubmissionTimeout();
    yield remaining;

    if (remaining <= 0) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
  }
});
