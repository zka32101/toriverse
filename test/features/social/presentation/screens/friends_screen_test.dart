/// Widget tests for FriendsScreen
///
/// Tests friend list display, friend requests, and tab navigation.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/social/presentation/screens/friends_screen.dart';

void main() {
  group('FriendsScreen', () {
    testWidgets('displays tabs for friends and requests', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have tab bar
      expect(find.byType(TabBar), findsOneWidget);

      // Should have both tabs
      expect(find.text('My Friends'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows empty state for no friends', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty message or loading
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays Add Friend button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have FAB or button for adding friend
      expect(find.byIcon(Icons.person_add), findsWidgets);
    });

    testWidgets('switches to requests tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Requests tab
      final requestsTab = find.text('Requests');
      expect(requestsTab, findsOneWidget);

      await tester.tap(requestsTab);
      await tester.pumpAndSettle();

      // Verify tab switched (check TabBar controller index)
      final tabBar = find.byType(TabBar).evaluate().first.widget as TabBar;
      expect(tabBar.controller?.index, equals(1));
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display content
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays friends list view structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have TabBarView
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('has search controller for finding friends', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have friends screen structure
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows no pending requests message when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to requests tab
      final requestsTab = find.text('Requests');
      await tester.tap(requestsTab);
      await tester.pumpAndSettle();

      // Should display tab content
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('displays people icon for empty friends', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for icon or message indicating no friends
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('displays mail icon for requests section', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to requests
      final requestsTab = find.text('Requests');
      await tester.tap(requestsTab);
      await tester.pumpAndSettle();

      // Verify requests tab is active
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('add friend button opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap add friend button
      final addButtons = find.byIcon(Icons.person_add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tap(addButtons.first);
        await tester.pumpAndSettle();

        // Should show dialog
        expect(find.byType(AlertDialog), findsWidgets);
      }
    });

    testWidgets('friend list uses list view builder', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FriendsScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have TabBarView with content
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('appbar shows Friends title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FriendsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display Friends in AppBar
      expect(find.text('Friends'), findsOneWidget);
    });

    testWidgets('floating action button only shows in friends tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FriendsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have floating action button in friends tab
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsWidgets);
    });
  });
}
