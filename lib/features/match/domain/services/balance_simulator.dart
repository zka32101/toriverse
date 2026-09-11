import 'dart:math';
import '../entities/board.dart';
import 'ai_player.dart';
import 'bonus_calculator.dart';
import 'rivalry_tracker.dart';

/// Monte Carlo simulation for balance verification
/// Runs N AI-only matches to detect game-breaking mechanics
class BalanceSimulator {
  static const int defaultSimulationCount = 1000;
  static const int aiSearchDepth = 2; // Shallow for speed (1000 sims × 60 rounds)

  /// Run N simulations and collect statistics
  static Future<SimulationReport> runSimulations({
    int matchCount = defaultSimulationCount,
    int aiDepth = aiSearchDepth,
  }) async {
    final matches = <MatchResult>[];

    for (int i = 0; i < matchCount; i++) {
      final match = _simulateSingleMatch(aiDepth: aiDepth);
      matches.add(match);

      // Progress indication every 100 matches
      if ((i + 1) % 100 == 0) {
        print('Completed ${i + 1}/$matchCount matches...');
      }
    }

    return _analyzeResults(matches);
  }

  /// Simulate one complete match
  static MatchResult _simulateSingleMatch({
    required int aiDepth,
  }) {
    final board = Board.initial();
    final playerIds = ['AI_0', 'AI_1', 'AI_2'];
    final rounds = <RoundStats>[];
    final bonusActivations = [0, 0, 0]; // Per player
    var roundIndex = 0;

    while (roundIndex < 64) {
      // Collect current board state
      final stoneCounts = board.countStones();
      final p0Stones = stoneCounts[Board.black] ?? 0;
      final p1Stones = stoneCounts[Board.white] ?? 0;
      final p2Stones = stoneCounts[Board.red] ?? 0;

      // Check if game is over
      bool anyHasMove = false;
      for (int i = 0; i < 3; i++) {
        if (board.getValidMoves(i).isNotEmpty) {
          anyHasMove = true;
          break;
        }
      }

      if (!anyHasMove) {
        break;
      }

      // Generate moves for all 3 players (simultaneous)
      final moves = <int, int?>{}; // playerIdx -> position
      final roundBonus = <int>{};

      for (int playerIdx = 0; playerIdx < 3; playerIdx++) {
        final validMoves = board.getValidMoves(playerIdx);
        if (validMoves.isEmpty) {
          moves[playerIdx] = null;
        } else {
          // Check if weak bonus should activate
          final shouldActivate = BonusCalculator.shouldActivateBonus(
            roundsRemaining: 64 - roundIndex,
            stoneCounts: [p0Stones, p1Stones, p2Stones],
            previousActivations: bonusActivations[playerIdx],
            playerIndex: playerIdx,
          );

          if (shouldActivate) {
            roundBonus.add(playerIdx);
            bonusActivations[playerIdx]++;
          }

          // Get AI move
          final move = AIPlayer.suggestMove(
            board,
            playerIdx,
            depth: aiDepth,
          );

          if (move != null) {
            moves[playerIdx] = move;
          }
        }
      }

      // Randomize processing order
      final processOrder = ProcessOrderRandomizer.randomizeOrder(playerIds);

      // Apply moves in order
      var moveCount = 0;
      for (final playerId in processOrder) {
        final playerIdx = playerIds.indexOf(playerId);
        final move = moves[playerIdx];

        if (move != null) {
          final row = move ~/ 8;
          final col = move % 8;

          // Only apply if still valid on current board state
          if (board.getValidMoves(playerIdx).any((m) => m[0] == row && m[1] == col)) {
            board.placeStone(row, col, playerIdx);
            moveCount++;
          }
        }
      }

      rounds.add(RoundStats(
        roundIndex: roundIndex,
        moveCount: moveCount,
        bonusActivatedPlayers: List.from(roundBonus),
      ));

      roundIndex++;
    }

    // Final stone count
    final finalCounts = board.countStones();
    final scores = [
      finalCounts[Board.black] ?? 0,
      finalCounts[Board.white] ?? 0,
      finalCounts[Board.red] ?? 0,
    ];

    // Determine winner(s)
    final maxScore = scores.reduce(max);
    final winners = [
      for (int i = 0; i < 3; i++)
        if (scores[i] == maxScore) i,
    ];

    return MatchResult(
      roundsPlayed: roundIndex,
      scores: scores,
      winners: winners,
      bonusActivationCounts: bonusActivations,
      rounds: rounds,
    );
  }

  /// Analyze all match results
  static SimulationReport _analyzeResults(List<MatchResult> matches) {
    final report = SimulationReport(
      totalMatches: matches.length,
      avgRoundsPerMatch: _averageRounds(matches),
      winRateByPlayer: _computeWinRates(matches),
      bonusActivationStats: _analyzeBonusStats(matches),
      gameBalanceIssues: _detectIssues(matches),
    );

    return report;
  }

  static double _averageRounds(List<MatchResult> matches) {
    final sum = matches.fold<int>(0, (acc, m) => acc + m.roundsPlayed);
    return sum / matches.length;
  }

  static Map<int, double> _computeWinRates(List<MatchResult> matches) {
    final winCounts = [0, 0, 0];
    final totalParticipations = [0, 0, 0];

    for (final match in matches) {
      for (int i = 0; i < 3; i++) {
        totalParticipations[i]++;
        if (match.winners.contains(i)) {
          winCounts[i]++;
        }
      }
    }

    return {
      0: totalParticipations[0] > 0 ? winCounts[0] / totalParticipations[0] : 0,
      1: totalParticipations[1] > 0 ? winCounts[1] / totalParticipations[1] : 0,
      2: totalParticipations[2] > 0 ? winCounts[2] / totalParticipations[2] : 0,
    };
  }

  static BonusActivationStats _analyzeBonusStats(List<MatchResult> matches) {
    int totalActivations = 0;
    final activationsByPlayer = [0, 0, 0];
    final matchesWithBonus = [0, 0, 0];

    for (final match in matches) {
      for (int i = 0; i < 3; i++) {
        activationsByPlayer[i] += match.bonusActivationCounts[i];
        totalActivations += match.bonusActivationCounts[i];

        if (match.bonusActivationCounts[i] > 0) {
          matchesWithBonus[i]++;
        }
      }
    }

    return BonusActivationStats(
      totalActivations: totalActivations,
      avgActivationsPerMatch: totalActivations / matches.length,
      matchesWithBonusByPlayer: {
        0: matchesWithBonus[0] / matches.length,
        1: matchesWithBonus[1] / matches.length,
        2: matchesWithBonus[2] / matches.length,
      },
      avgActivationsPerPlayerPerMatch: {
        0: activationsByPlayer[0] / matches.length,
        1: activationsByPlayer[1] / matches.length,
        2: activationsByPlayer[2] / matches.length,
      },
    );
  }

  static List<BalanceIssue> _detectIssues(List<MatchResult> matches) {
    final issues = <BalanceIssue>[];

    // Check win rate variance (all players should be ~33% in balanced game)
    final winRates = _computeWinRates(matches);
    final rates = [winRates[0]!, winRates[1]!, winRates[2]!];
    final avgRate = rates.reduce((a, b) => a + b) / 3;
    final maxDeviation = rates.map((r) => (r - avgRate).abs()).reduce(max);

    if (maxDeviation > 0.15) {
      // More than 15% deviation from equal (33%) is suspicious
      issues.add(BalanceIssue(
        severity: IssueSeverity.high,
        category: 'Win Rate Imbalance',
        description: 'Win rate variance >15%: ${winRates.values.map((v) => '${(v * 100).toStringAsFixed(1)}%').join(', ')}',
        recommendation: 'Check if one player position is inherently advantaged',
      ));
    }

    // Check for stalemate patterns (short games with few rounds)
    final shortGames = matches.where((m) => m.roundsPlayed < 10).length;
    if (shortGames > matches.length * 0.1) {
      issues.add(BalanceIssue(
        severity: IssueSeverity.medium,
        category: 'Stalemate/Pass Chains',
        description: '${(shortGames / matches.length * 100).toStringAsFixed(1)}% of games had <10 rounds (likely pass chains)',
        recommendation: 'Review end-game rules and pass logic',
      ));
    }

    // Check if weak bonus is effective (do losers activate it?)
    final bonusStats = _analyzeBonusStats(matches);
    if (bonusStats.avgActivationsPerMatch < 0.1) {
      // Less than 0.1 activations per match (1 per 10 matches)
      issues.add(BalanceIssue(
        severity: IssueSeverity.low,
        category: 'Low Bonus Activation',
        description: 'Weak bonus activates <1 time per 10 matches (${(bonusStats.avgActivationsPerMatch * 10).toStringAsFixed(1)} expected)',
        recommendation: 'Consider lowering activation threshold or extending eligible window',
      ));
    }

    return issues;
  }
}

/// Single match simulation result
class MatchResult {
  final int roundsPlayed;
  final List<int> scores; // [player0, player1, player2]
  final List<int> winners; // Indices of winners (can be multiple in tie)
  final List<int> bonusActivationCounts;
  final List<RoundStats> rounds;

  MatchResult({
    required this.roundsPlayed,
    required this.scores,
    required this.winners,
    required this.bonusActivationCounts,
    required this.rounds,
  });
}

/// Per-round statistics
class RoundStats {
  final int roundIndex;
  final int moveCount; // How many of the 3 players moved
  final List<int> bonusActivatedPlayers;

  RoundStats({
    required this.roundIndex,
    required this.moveCount,
    required this.bonusActivatedPlayers,
  });
}

/// Bonus activation analysis
class BonusActivationStats {
  final int totalActivations;
  final double avgActivationsPerMatch;
  final Map<int, double> matchesWithBonusByPlayer; // Fraction of matches where player activated
  final Map<int, double> avgActivationsPerPlayerPerMatch;

  BonusActivationStats({
    required this.totalActivations,
    required this.avgActivationsPerMatch,
    required this.matchesWithBonusByPlayer,
    required this.avgActivationsPerPlayerPerMatch,
  });
}

/// Severity level for balance issues
enum IssueSeverity {
  high,
  medium,
  low,
}

/// Detected balance issue
class BalanceIssue {
  final IssueSeverity severity;
  final String category;
  final String description;
  final String recommendation;

  BalanceIssue({
    required this.severity,
    required this.category,
    required this.description,
    required this.recommendation,
  });

  @override
  String toString() => '[$severity] $category: $description\n  → $recommendation';
}

/// Overall simulation report
class SimulationReport {
  final int totalMatches;
  final double avgRoundsPerMatch;
  final Map<int, double> winRateByPlayer;
  final BonusActivationStats bonusActivationStats;
  final List<BalanceIssue> gameBalanceIssues;

  SimulationReport({
    required this.totalMatches,
    required this.avgRoundsPerMatch,
    required this.winRateByPlayer,
    required this.bonusActivationStats,
    required this.gameBalanceIssues,
  });

  /// Print human-readable summary
  void printSummary() {
    print('\n=== BALANCE SIMULATION REPORT ===');
    print('Total Matches: $totalMatches');
    print('Average Rounds per Match: ${avgRoundsPerMatch.toStringAsFixed(1)}');
    print('\nWin Rates:');
    for (int i = 0; i < 3; i++) {
      print('  Player $i: ${(winRateByPlayer[i]! * 100).toStringAsFixed(1)}%');
    }
    print('\nBonus Activation:');
    print('  Total Activations: ${bonusActivationStats.totalActivations}');
    print('  Avg per Match: ${bonusActivationStats.avgActivationsPerMatch.toStringAsFixed(2)}');
    for (int i = 0; i < 3; i++) {
      final matchFrac = (bonusActivationStats.matchesWithBonusByPlayer[i]! * 100).toStringAsFixed(1);
      final avgPer = bonusActivationStats.avgActivationsPerPlayerPerMatch[i]!.toStringAsFixed(2);
      print('  Player $i: $matchFrac% of matches, avg $avgPer/match');
    }

    if (gameBalanceIssues.isEmpty) {
      print('\n✅ No balance issues detected');
    } else {
      print('\n⚠️  Issues Detected:');
      for (final issue in gameBalanceIssues) {
        print('  - $issue');
      }
    }
  }
}
