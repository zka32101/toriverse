import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/ai_takeover_state.dart';
import 'package:toriverse/features/match/application/services/inactivity_monitor.dart';

void main() {
  group('AITakeoverState', () {
    test('create() initializes empty takeover state', () {
      final state = AITakeoverState.create();
      expect(state.activeTakeovers, isEmpty);
      expect(state.consecutiveTimeouts, isEmpty);
      expect(state.hasAITakeover, isFalse);
    });

    test('activateTakeover() adds player to active takeovers', () {
      final state = AITakeoverState.create();
      final newState = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );

      expect(newState.activeTakeovers, contains('player_1'));
      expect(newState.activeTakeovers['player_1']?['reason'], 'timeout');
      expect(newState.hasAITakeover, isTrue);
    });

    test('activateTakeover() increments consecutive timeout count', () {
      final state = AITakeoverState.create();
      var newState = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );

      expect(newState.consecutiveTimeouts['player_1'], 1);

      newState = newState.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );

      expect(newState.consecutiveTimeouts['player_1'], 2);
    });

    test('activateTakeover() does not increment count for inactivity reason', () {
      final state = AITakeoverState.create();
      var newState = state.activateTakeover(
        playerId: 'player_1',
        reason: 'inactivity',
      );

      expect(newState.consecutiveTimeouts.containsKey('player_1'), isFalse);
    });

    test('deactivateTakeover() removes player from active takeovers', () {
      var state = AITakeoverState.create();
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.activeTakeovers, contains('player_1'));

      final newState = state.deactivateTakeover('player_1');
      expect(newState.activeTakeovers, isNot(contains('player_1')));
      expect(newState.hasAITakeover, isFalse);
    });

    test('deactivateTakeover() resets timeout counter on reconnect', () {
      var state = AITakeoverState.create();
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.consecutiveTimeouts['player_1'], 1);

      final newState = state.deactivateTakeover('player_1');
      expect(newState.consecutiveTimeouts['player_1'], 0);
    });

    test('isAIControlled() returns correct status', () {
      var state = AITakeoverState.create();
      expect(state.isAIControlled('player_1'), isFalse);

      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.isAIControlled('player_1'), isTrue);
    });

    test('aiControlledPlayers getter returns all AI-controlled players', () {
      var state = AITakeoverState.create();
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      state = state.activateTakeover(
        playerId: 'player_2',
        reason: 'inactivity',
      );

      expect(state.aiControlledPlayers, contains('player_1'));
      expect(state.aiControlledPlayers, contains('player_2'));
      expect(state.aiControlledPlayers, hasLength(2));
    });
  });

  group('InactivityMonitor', () {
    test('create() initializes with current time for all players', () {
      final playerIds = ['player_0', 'player_1', 'player_2'];
      final monitor = InactivityMonitor.create(playerIds: playerIds);

      expect(monitor.lastActivityByPlayer.keys, containsAll(playerIds));
      for (final playerId in playerIds) {
        expect(monitor.lastActivityByPlayer[playerId], isNotNull);
      }
    });

    test('isInactive() returns false for active players', () {
      final playerIds = ['player_0', 'player_1'];
      final monitor = InactivityMonitor.create(playerIds: playerIds);

      expect(monitor.isInactive('player_0'), isFalse);
      expect(monitor.isInactive('player_1'), isFalse);
    });

    test('isInactive() returns true after timeout period', () async {
      final now = DateTime.now();
      final pastTime = now.subtract(const Duration(seconds: 50));

      final monitor = InactivityMonitor(
        lastActivityByPlayer: {
          'player_0': pastTime,
        },
        inactivityTimeoutMs: 45000,
      );

      expect(monitor.isInactive('player_0'), isTrue);
    });

    test('recordActivity() updates last activity time', () {
      final playerIds = ['player_0', 'player_1'];
      var monitor = InactivityMonitor.create(playerIds: playerIds);

      final originalTime = monitor.lastActivityByPlayer['player_0']!;

      // Small delay to ensure time difference
      Future.delayed(const Duration(milliseconds: 100));

      monitor = monitor.recordActivity('player_0');
      final newTime = monitor.lastActivityByPlayer['player_0']!;

      expect(newTime, isAfter(originalTime));
    });

    test('getInactivePlayers() returns only inactive players', () async {
      final now = DateTime.now();
      final recentTime = now.subtract(const Duration(seconds: 10));
      final pastTime = now.subtract(const Duration(seconds: 50));

      final monitor = InactivityMonitor(
        lastActivityByPlayer: {
          'player_0': recentTime,
          'player_1': pastTime,
          'player_2': recentTime,
        },
        inactivityTimeoutMs: 45000,
      );

      final inactivePlayers =
          monitor.getInactivePlayers(['player_0', 'player_1', 'player_2']);
      expect(inactivePlayers, contains('player_1'));
      expect(inactivePlayers, isNot(contains('player_0')));
      expect(inactivePlayers, isNot(contains('player_2')));
    });

    test('msUntilInactive() returns time until timeout', () {
      final now = DateTime.now();
      final pastTime = now.subtract(const Duration(seconds: 30));

      final monitor = InactivityMonitor(
        lastActivityByPlayer: {
          'player_0': pastTime,
        },
        inactivityTimeoutMs: 45000,
      );

      final msUntil = monitor.msUntilInactive('player_0');
      expect(msUntil, greaterThan(0));
      expect(msUntil, lessThanOrEqualTo(15000)); // ~15 seconds remaining
    });

    test('resetAllActivity() resets all player activity times', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 50));

      var monitor = InactivityMonitor(
        lastActivityByPlayer: {
          'player_0': pastTime,
          'player_1': pastTime,
        },
        inactivityTimeoutMs: 45000,
      );

      expect(monitor.isInactive('player_0'), isTrue);
      expect(monitor.isInactive('player_1'), isTrue);

      monitor = monitor.resetAllActivity();

      expect(monitor.isInactive('player_0'), isFalse);
      expect(monitor.isInactive('player_1'), isFalse);
    });
  });

  group('RoundSubmissionMonitor', () {
    test('create() initializes with no submissions', () {
      final playerIds = ['player_0', 'player_1', 'player_2'];
      final monitor = RoundSubmissionMonitor.create(playerIds: playerIds);

      expect(monitor.submissionTimeByPlayer.length, 3);
      for (final playerId in playerIds) {
        expect(monitor.submissionTimeByPlayer[playerId], isNull);
      }
    });

    test('recordSubmission() marks player as submitted', () {
      final playerIds = ['player_0', 'player_1'];
      var monitor = RoundSubmissionMonitor.create(playerIds: playerIds);

      expect(monitor.hasSubmitted('player_0'), isFalse);

      monitor = monitor.recordSubmission('player_0');

      expect(monitor.hasSubmitted('player_0'), isTrue);
      expect(monitor.submissionTimeByPlayer['player_0'], isNotNull);
    });

    test('isSubmissionTimedOut() returns false before timeout', () {
      final playerIds = ['player_0', 'player_1'];
      final monitor = RoundSubmissionMonitor.create(playerIds: playerIds);

      expect(monitor.isSubmissionTimedOut('player_0'), isFalse);
      expect(monitor.isSubmissionTimedOut('player_1'), isFalse);
    });

    test('isSubmissionTimedOut() returns true after timeout period', () async {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 35));

      final monitor = RoundSubmissionMonitor(
        submissionTimeByPlayer: {
          'player_0': null,
        },
        roundStartedAt: pastTime,
        submissionTimeoutMs: 30000,
      );

      expect(monitor.isSubmissionTimedOut('player_0'), isTrue);
    });

    test('isSubmissionTimedOut() returns false for submitted players', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 35));

      final monitor = RoundSubmissionMonitor(
        submissionTimeByPlayer: {
          'player_0': DateTime.now(),
        },
        roundStartedAt: pastTime,
        submissionTimeoutMs: 30000,
      );

      expect(monitor.isSubmissionTimedOut('player_0'), isFalse);
    });

    test('getTimedOutPlayers() returns only timed-out players', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 35));

      final monitor = RoundSubmissionMonitor(
        submissionTimeByPlayer: {
          'player_0': null,
          'player_1': DateTime.now(),
          'player_2': null,
        },
        roundStartedAt: pastTime,
        submissionTimeoutMs: 30000,
      );

      final timedOut =
          monitor.getTimedOutPlayers(['player_0', 'player_1', 'player_2']);
      expect(timedOut, contains('player_0'));
      expect(timedOut, contains('player_2'));
      expect(timedOut, isNot(contains('player_1')));
    });

    test('msUntilSubmissionTimeout() returns time until timeout', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 20));

      final monitor = RoundSubmissionMonitor(
        submissionTimeByPlayer: {'player_0': null},
        roundStartedAt: pastTime,
        submissionTimeoutMs: 30000,
      );

      final msUntil = monitor.msUntilSubmissionTimeout();
      expect(msUntil, greaterThan(0));
      expect(msUntil, lessThanOrEqualTo(10000)); // ~10 seconds remaining
    });

    test('toString() shows submission count', () {
      final playerIds = ['player_0', 'player_1', 'player_2'];
      var monitor = RoundSubmissionMonitor.create(playerIds: playerIds);

      monitor = monitor.recordSubmission('player_0');
      monitor = monitor.recordSubmission('player_1');

      final str = monitor.toString();
      expect(str, contains('submitted=2/3'));
    });
  });

  group('AI Takeover Integration Scenarios', () {
    test('Timeout scenario: Player A times out, gets AI takeover', () {
      final state = AITakeoverState.create();
      final newState = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );

      expect(newState.isAIControlled('player_1'), isTrue);
      expect(newState.consecutiveTimeouts['player_1'], 1);
      expect(newState.hasAITakeover, isTrue);
    });

    test('Reconnection scenario: Player reconnects, AI takeover deactivates', () {
      var state = AITakeoverState.create();
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.isAIControlled('player_1'), isTrue);

      final reconnected = state.deactivateTakeover('player_1');
      expect(reconnected.isAIControlled('player_1'), isFalse);
      expect(reconnected.consecutiveTimeouts['player_1'], 0);
    });

    test('General inactivity scenario: Player inactive for 45+ seconds', () {
      final pastTime = DateTime.now().subtract(const Duration(seconds: 50));

      final monitor = InactivityMonitor(
        lastActivityByPlayer: {
          'player_0': DateTime.now(),
          'player_1': pastTime,
          'player_2': DateTime.now(),
        },
        inactivityTimeoutMs: 45000,
      );

      final inactive =
          monitor.getInactivePlayers(['player_0', 'player_1', 'player_2']);
      expect(inactive, contains('player_1'));
      expect(inactive, hasLength(1));
    });

    test('Multiple timeouts: Player times out twice', () {
      var state = AITakeoverState.create();

      // First timeout
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.consecutiveTimeouts['player_1'], 1);

      // Second timeout
      state = state.activateTakeover(
        playerId: 'player_1',
        reason: 'timeout',
      );
      expect(state.consecutiveTimeouts['player_1'], 2);
    });
  });
}
