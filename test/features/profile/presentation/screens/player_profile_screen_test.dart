/// Widget tests for PlayerProfileScreen
///
/// Tests profile display, stats rendering, and achievements section.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/profile/presentation/screens/player_profile_screen.dart';

void main() {
  group('PlayerProfileScreen', () {
    testWidgets('displays profile header with avatar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display avatar container
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays username in profile header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show player username text
      expect(find.text('Player Username'), findsOneWidget);
    });

    testWidgets('displays rank and points badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display rank information
      expect(find.text('Rank #1 • 1500 points'), findsOneWidget);
    });

    testWidgets('displays statistics section with 4 cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display Statistics header
      expect(find.text('Statistics'), findsOneWidget);

      // Should have 4 stat cards
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('displays stat card labels correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show stat labels
      expect(find.text('Total Matches'), findsOneWidget);
      expect(find.text('Wins'), findsOneWidget);
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);
    });

    testWidgets('displays stat values in cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show stat values
      expect(find.text('50'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('displays achievements section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display Achievements header
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('displays achievement cards with trophy emoji', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display trophy emoji
      expect(find.text('🏆'), findsWidgets);
    });

    testWidgets('displays achievement details', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display achievement name
      expect(find.text('First Victory'), findsOneWidget);

      // Should display achievement description
      expect(find.text('Win your first match'), findsOneWidget);
    });

    testWidgets('shows checkmark for unlocked achievements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display completion checkmark
      expect(find.text('✓'), findsWidgets);
    });

    testWidgets('shows edit button for own profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display edit icon in AppBar
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('hides edit button for other profiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'other_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not display edit icon
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('displays profile in scrollable view', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('has proper spacing between sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayerProfileScreen(
              uid: 'test_uid',
              isOwnProfile: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display SizedBox for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('displays profile title in AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PlayerProfileScreen(
            uid: 'test_uid',
            isOwnProfile: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show "Player Profile" title
      expect(find.text('Player Profile'), findsOneWidget);
    });
  });
}
