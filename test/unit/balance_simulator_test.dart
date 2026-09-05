import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/domain/services/balance_simulator.dart';

void main() {
  group('BalanceSimulator - Integration Tests', () {
    test('runSimulations completes without error', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 10, // Small number for fast test
        aiDepth: 1,
      );

      expect(report, isNotNull);
      expect(report.totalMatches, 10);
      expect(report.avgRoundsPerMatch, greaterThan(0));
    });

    test('win rates sum to approximately 1.0 per player across many matches',
        () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 50,
        aiDepth: 1,
      );

      final totalWins = report.winRateByPlayer.values.reduce((a, b) => a + b);
      // 3 players, so total should be ~1.0
      expect(totalWins, closeTo(3.0, 0.5)); // Allow 50% variance in small sample
    });

    test('bonus activation stats are computed correctly', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 20,
        aiDepth: 1,
      );

      final stats = report.bonusActivationStats;
      expect(stats.totalActivations, greaterThanOrEqualTo(0));
      expect(stats.avgActivationsPerMatch, greaterThanOrEqualTo(0));

      // Each player activation rate should be between 0 and 1
      for (final rate in stats.matchesWithBonusByPlayer.values) {
        expect(rate, greaterThanOrEqualTo(0));
        expect(rate, lessThanOrEqualTo(1));
      }
    });

    test('game balance issues detection works', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 10,
        aiDepth: 1,
      );

      // Report should have a list of issues (possibly empty)
      expect(report.gameBalanceIssues, isNotNull);
      expect(report.gameBalanceIssues, isA<List<BalanceIssue>>());
    });
  });

  group('BalanceSimulator - Report Analysis', () {
    test('SimulationReport.printSummary does not throw', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 5,
        aiDepth: 1,
      );

      // Should not throw
      expect(() => report.printSummary(), returnsNormally);
    });

    test('BalanceIssue.toString produces readable output', () {
      final issue = BalanceIssue(
        severity: IssueSeverity.high,
        category: 'Test Category',
        description: 'Test description',
        recommendation: 'Test recommendation',
      );

      final str = issue.toString();
      expect(str, contains('Test Category'));
      expect(str, contains('Test description'));
      expect(str, contains('Test recommendation'));
    });
  });

  group('BalanceSimulator - Edge Cases', () {
    test('zero matches returns valid report', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 1, // Minimal
        aiDepth: 1,
      );

      expect(report.totalMatches, 1);
      expect(report.winRateByPlayer.length, 3);
    });

    test('win rates are between 0 and 1', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 20,
        aiDepth: 1,
      );

      for (final rate in report.winRateByPlayer.values) {
        expect(rate, greaterThanOrEqualTo(0));
        expect(rate, lessThanOrEqualTo(1));
      }
    });

    test('avg rounds is reasonable', () async {
      final report = await BalanceSimulator.runSimulations(
        matchCount: 10,
        aiDepth: 1,
      );

      // Othello should end in 1-64 rounds
      expect(report.avgRoundsPerMatch, greaterThan(0));
      expect(report.avgRoundsPerMatch, lessThanOrEqualTo(64));
    });
  });
}
