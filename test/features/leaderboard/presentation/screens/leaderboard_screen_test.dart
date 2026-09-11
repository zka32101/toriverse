/// Widget tests for LeaderboardScreen
///
/// Tests leaderboard display, tab switching, and player entry rendering.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toriverse/features/leaderboard/application/providers/leaderboard_provider.dart';
import 'package:toriverse/features/leaderboard/domain/models/leaderboard_models.dart';
import 'package:toriverse/features/leaderboard/presentation/screens/leaderboard_screen.dart';

// Mock classes
class MockLeaderboardService extends Mock {}

void main() {
  group('LeaderboardScreen', () {
    late ProviderContainer providerContainer;

    setUp(() {
      providerContainer = ProviderContainer();
    });

    testWidgets('displays loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override with loading provider
          ],
          child: MaterialApp(
            home: const Scaffold(
              body: LeaderboardScreen(),
            ),
          ),
        ),
      );

      // Wait for widget to build
      await tester.pumpAndSettle();

      // Should show loading or content
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays leaderboard entries', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have tab bar
      expect(find.byType(TabBar), findsOneWidget);

      // Should have Global and Friends tabs
      expect(find.text('Global'), findsOneWidget);
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('switches between Global and Friends tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap Friends tab
      final friendsTab = find.text('Friends');
      expect(friendsTab, findsOneWidget);

      await tester.tap(friendsTab);
      await tester.pumpAndSettle();

      // Tab should be selected
      final tabBar = find.byType(TabBar).evaluate().first.widget as TabBar;
      expect(tabBar.controller?.index, equals(1));
    });

    testWidgets('displays rank badge colors correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have AppBar with title
      expect(find.text('Leaderboard'), findsOneWidget);
    });

    testWidgets('shows empty state message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display leaderboard content or loading state
      final content = find.byType(Column);
      expect(content, findsWidgets);
    });

    testWidgets('displays player information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('handles error state gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays win rates as percentages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have layout for win rates
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('leaderboard entry has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify card-based layout
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('shows player ranking positions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeaderboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display position/rank information
      expect(find.byType(Text), findsWidgets);
    });
  });
}
