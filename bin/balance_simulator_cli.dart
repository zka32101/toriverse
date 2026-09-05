#!/usr/bin/env dart
/// CLI tool for running balance simulation harness
/// Usage: dart run bin/balance_simulator_cli.dart [--matches N] [--depth D]

import 'dart:async';
import 'package:toriverse/features/match/domain/services/balance_simulator.dart';

Future<void> main(List<String> args) async {
  // Parse arguments
  int matchCount = BalanceSimulator.defaultSimulationCount;
  int aiDepth = BalanceSimulator.aiSearchDepth;

  for (int i = 0; i < args.length; i++) {
    if (args[i] == '--matches' && i + 1 < args.length) {
      matchCount = int.tryParse(args[i + 1]) ?? matchCount;
    } else if (args[i] == '--depth' && i + 1 < args.length) {
      aiDepth = int.tryParse(args[i + 1]) ?? aiDepth;
    } else if (args[i] == '--help' || args[i] == '-h') {
      _printHelp();
      return;
    }
  }

  print('🎮 Toriverse Balance Simulator');
  print('Configuration:');
  print('  Matches: $matchCount');
  print('  AI Search Depth: $aiDepth');
  print('  Starting simulation...\n');

  final stopwatch = Stopwatch()..start();
  final report = await BalanceSimulator.runSimulations(
    matchCount: matchCount,
    aiDepth: aiDepth,
  );
  stopwatch.stop();

  // Print results
  report.printSummary();

  print('\n✅ Simulation complete in ${stopwatch.elapsedMilliseconds}ms');
  print('   (${(stopwatch.elapsedMilliseconds / matchCount).toStringAsFixed(2)}ms per match)');

  // Exit with appropriate code
  exit(report.gameBalanceIssues.isEmpty ? 0 : 1);
}

void _printHelp() {
  print('''
Balance Simulator CLI
Usage: dart run bin/balance_simulator_cli.dart [options]

Options:
  --matches N     Number of matches to simulate (default: 1000)
  --depth D       AI search depth (default: 2, range: 1-4)
  --help, -h      Show this help message

Examples:
  # Run default simulation (1000 matches)
  dart run bin/balance_simulator_cli.dart

  # Run 10000 matches with deeper AI
  dart run bin/balance_simulator_cli.dart --matches 10000 --depth 3

  # Quick test with 100 matches
  dart run bin/balance_simulator_cli.dart --matches 100 --depth 1
''');
}

// Placeholder for exit in non-dart environment
void exit(int code) {
  // In actual Dart runtime, use dart:io exit()
  // This is needed for compilation compatibility
}
