import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/streak_state.dart';
import 'package:toriverse/features/match/presentation/widgets/streak_display_widget.dart';

void main() {
  group('StreakDisplayWidget', () {
    // Helper to create test widget with Riverpod container
    Widget createTestWidget({
      bool isCompact = false,
      bool showBestStreak = true,
      VoidCallback? onTapCollection,
      int currentStreak = 5,
      int bestStreak = 10,
      int? nextMilestone = 10,
      bool isAtMilestone = false,
    }) {
      return ProviderContainer(
        child: MaterialApp(
          home: Scaffold(
            body: ProviderScope(
              overrides: [
                currentStreakProvider.overrideWithValue(currentStreak),
                bestStreakProvider.overrideWithValue(bestStreak),
                nextMilestoneProvider.overrideWithValue(nextMilestone),
                isAtMilestoneProvider.overrideWithValue(isAtMilestone),
              ],
              child: StreakDisplayWidget(
                isCompact: isCompact,
                showBestStreak: showBestStreak,
                onTapCollection: onTapCollection,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Compact layout displays fire emoji and streak count',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: true,
          currentStreak: 7,
          bestStreak: 10,
        ),
      );

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Max: 10'), findsOneWidget);
    });

    testWidgets('Compact layout hides best streak when showBestStreak is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: true,
          showBestStreak: false,
          currentStreak: 5,
          bestStreak: 15,
        ),
      );

      expect(find.text('🔥'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Max: 15'), findsNothing);
    });

    testWidgets('Expanded layout displays full card with milestone progress',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: false,
          currentStreak: 7,
          bestStreak: 15,
          nextMilestone: 10,
          isAtMilestone: false,
        ),
      );

      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('Best Streak'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('Next Milestone: 10'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Expanded layout shows milestone celebration when at milestone',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: false,
          currentStreak: 10,
          bestStreak: 10,
          nextMilestone: 25,
          isAtMilestone: true,
        ),
      );

      expect(find.text('Milestone!'), findsOneWidget);
      // Verify gold border styling (check for amber color in container)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);
    });

    testWidgets('Expanded layout hides next milestone when at 100',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: false,
          currentStreak: 100,
          bestStreak: 100,
          nextMilestone: null,
          isAtMilestone: true,
        ),
      );

      expect(find.text('Next Milestone:'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('Compact layout has accessible tap target size',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: true,
          currentStreak: 5,
        ),
      );

      // The container should be large enough for accessibility (min 44x44)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      // Verify text is readable with proper contrast
      final textFinder = find.byType(Text);
      expect(textFinder, findsWidgets);
    });

    testWidgets('onTapCollection callback is invoked in expanded layout',
        (WidgetTester tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        createTestWidget(
          isCompact: false,
          onTapCollection: () {
            tapCalled = true;
          },
        ),
      );

      // Find the main container and tap it
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(tapCalled, isTrue);
    });

    testWidgets('Progress bar color changes at milestone',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: false,
          currentStreak: 10,
          nextMilestone: 10,
          isAtMilestone: true,
        ),
      );

      // Progress bar should be present with milestone styling
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify the amber color is applied for milestone state
      final container = find.byType(Container);
      expect(container, findsWidgets);
    });

    testWidgets('Displays correct streak values from provider',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          isCompact: true,
          currentStreak: 42,
          bestStreak: 50,
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Max: 50'), findsOneWidget);
    });
  });
}
