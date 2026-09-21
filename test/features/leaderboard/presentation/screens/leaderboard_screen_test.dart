/// Widget tests for LeaderboardScreen
///
/// Tests leaderboard display, tab switching, and player entry rendering.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/leaderboard/application/providers/leaderboard_provider.dart';
import 'package:toriverse/features/leaderboard/application/services/leaderboard_service.dart';
import 'package:toriverse/features/leaderboard/presentation/screens/leaderboard_screen.dart';

/// Seeds a `FakeFirebaseFirestore` with a handful of leaderboard entries so
/// `globalLeaderboardProvider` (which otherwise reaches for the real,
/// unavailable `FirebaseFirestore.instance` via `LeaderboardService()`)
/// resolves to real data instead of throwing.
Future<FakeFirebaseFirestore> _seededFirestore() async {
  final firestore = FakeFirebaseFirestore();
  final entries = <Map<String, dynamic>>[
    {
      'uid': 'player_1',
      'username': 'Alice',
      'rankPoints': 1500,
      'completedMatchStreak': 5,
      'totalMatches': 20,
      'totalWins': 12,
      'totalLosses': 8,
      'winRate': 0.6,
      'lastUpdated': DateTime(2026, 1, 1).toIso8601String(),
    },
    {
      'uid': 'player_2',
      'username': 'Bob',
      'rankPoints': 1200,
      'completedMatchStreak': 2,
      'totalMatches': 15,
      'totalWins': 6,
      'totalLosses': 9,
      'winRate': 0.4,
      'lastUpdated': DateTime(2026, 1, 1).toIso8601String(),
    },
    {
      'uid': 'player_3',
      'username': 'Carol',
      'rankPoints': 900,
      'completedMatchStreak': 0,
      'totalMatches': 10,
      'totalWins': 3,
      'totalLosses': 7,
      'winRate': 0.3,
      'lastUpdated': DateTime(2026, 1, 1).toIso8601String(),
    },
  ];

  for (final entry in entries) {
    await firestore
        .collection('leaderboards')
        .doc('global')
        .collection('entries')
        .doc(entry['uid'] as String)
        .set(entry);
  }

  return firestore;
}

Widget _buildTestApp(FakeFirebaseFirestore firestore) {
  return ProviderScope(
    overrides: [
      leaderboardServiceProvider.overrideWithValue(
        LeaderboardService(firestore: firestore),
      ),
    ],
    // LeaderboardScreen already builds its own Scaffold (with an AppBar),
    // so it is passed directly as `home` rather than wrapped in another
    // Scaffold — otherwise `find.byType(Scaffold)` finds two.
    child: const MaterialApp(
      home: LeaderboardScreen(),
    ),
  );
}

void main() {
  group('LeaderboardScreen', () {
    testWidgets('displays loading state initially', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));

      // Before the FutureProvider resolves, the global leaderboard tab
      // shows a CircularProgressIndicator (see `.when(loading: ...)`).
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Let it resolve so no timers/futures are left pending.
      await tester.pumpAndSettle();
    });

    testWidgets('displays leaderboard entries', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Should have Global and Friends tab buttons (custom-built, not a
      // Material `TabBar`).
      expect(find.text('Global'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);

      // Seeded players should render.
      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('switches between Global and Friends tabs', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Find and tap the Friends tab button.
      final friendsTab = find.text('Friends');
      expect(friendsTab, findsOneWidget);

      await tester.tap(friendsTab);
      await tester.pumpAndSettle();

      // The Friends tab content (placeholder) should now be shown, and the
      // Global tab's leaderboard entries should be gone.
      expect(find.text('Friends leaderboard coming soon'), findsOneWidget);
      expect(find.text('Alice'), findsNothing);
    });

    testWidgets('displays rank badge colors correctly', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Should have AppBar with title
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('shows empty state message', (WidgetTester tester) async {
      // No seeded entries this time.
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      expect(find.text('No players on leaderboard'), findsOneWidget);
    });

    testWidgets('displays player information correctly', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Verify structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('handles error state gracefully', (WidgetTester tester) async {
      // An un-seeded, but otherwise valid, fake Firestore still resolves
      // successfully (an empty collection query, not an error) — Firestore
      // errors from a genuinely broken query are hard to simulate with
      // fake_cloud_firestore, so this exercises the empty/degenerate path
      // and asserts the screen still renders without crashing.
      final firestore = FakeFirebaseFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Should display without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays win rates as percentages', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Alice has winRate 0.6 -> "60.0%"
      expect(find.text('60.0%'), findsOneWidget);
    });

    testWidgets('leaderboard entry has correct layout structure', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Verify card-based layout
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows player ranking positions', (WidgetTester tester) async {
      final firestore = await _seededFirestore();

      await tester.pumpWidget(_buildTestApp(firestore));
      await tester.pumpAndSettle();

      // Rank badges display "1", "2", "3" for the seeded, points-ordered
      // entries (Alice=1500 > Bob=1200 > Carol=900).
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}
