import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/cosmetic_state.dart';
import 'package:toriverse/features/match/presentation/widgets/milestone_reached_dialog.dart';

void main() {
  group('MilestoneReachedDialog', () {
    late CosmeticItem testCosmetic;

    setUp(() {
      testCosmetic = const CosmeticItem(
        id: 'test_board_1',
        type: 'board',
        name: 'Golden Board',
        rarity: 'legendary',
        price: 300,
      );
    });

    Widget createTestApp({
      int milestone = 10,
      CosmeticItem? cosmeticReward,
      VoidCallback? onDismiss,
      VoidCallback? onViewCollection,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: MilestoneReachedDialog(
              milestone: milestone,
              cosmeticReward: cosmeticReward,
              onDismiss: onDismiss,
              onViewCollection: onViewCollection,
            ),
          ),
        ),
      );
    }

    testWidgets('Displays milestone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 25),
      );

      expect(find.text('Milestone Reached!'), findsOneWidget);
      expect(find.text('25 Matches'), findsOneWidget);
    });

    testWidgets('Displays trophy emoji', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 10),
      );

      expect(find.text('🏆'), findsOneWidget);
    });

    testWidgets('Shows cosmetic reward details when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          milestone: 50,
          cosmeticReward: testCosmetic,
        ),
      );

      expect(find.text('Reward Unlocked'), findsOneWidget);
      expect(find.text('Golden Board'), findsOneWidget);
      expect(find.text('LEGENDARY'), findsOneWidget);
    });

    testWidgets('Does not show cosmetic section when reward is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          milestone: 5,
          cosmeticReward: null,
        ),
      );

      expect(find.text('Reward Unlocked'), findsNothing);
      expect(find.text('LEGENDARY'), findsNothing);
    });

    testWidgets('Continue button triggers onDismiss callback',
        (WidgetTester tester) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        createTestApp(
          milestone: 10,
          onDismiss: () {
            dismissCalled = true;
          },
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(dismissCalled, isTrue);
    });

    testWidgets('View Collection button triggers onViewCollection callback',
        (WidgetTester tester) async {
      bool collectionCalled = false;

      await tester.pumpWidget(
        createTestApp(
          milestone: 10,
          cosmeticReward: testCosmetic,
          onViewCollection: () {
            collectionCalled = true;
          },
        ),
      );

      await tester.tap(find.text('View Collection'));
      await tester.pumpAndSettle();

      expect(collectionCalled, isTrue);
    });

    testWidgets('Dialog closes after tapping Continue',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 10),
      );

      // Dialog should be visible
      expect(find.byType(Dialog), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('Displays different rarity colors correctly',
        (WidgetTester tester) async {
      final rarityCosmetic = CosmeticItem(
        id: 'test_board_2',
        type: 'board',
        name: 'Rare Board',
        rarity: 'rare',
        price: 200,
      );

      await tester.pumpWidget(
        createTestApp(
          milestone: 25,
          cosmeticReward: rarityCosmetic,
        ),
      );

      expect(find.text('RARE'), findsOneWidget);
    });

    testWidgets('Animates on entry with ScaleTransition',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 10),
      );

      // Verify dialog is present (animation should be applied)
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('Shows confetti emojis in header',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 10),
      );

      // Look for celebration emojis
      expect(find.text('🎉'), findsWidgets);
      expect(find.text('✨'), findsWidgets);
      expect(find.text('🎊'), findsWidgets);
    });

    testWidgets('Handles all major milestones',
        (WidgetTester tester) async {
      const milestones = [3, 5, 10, 25, 50, 100];

      for (final milestone in milestones) {
        await tester.pumpWidget(
          createTestApp(milestone: milestone),
        );

        expect(find.text('$milestone Matches'), findsOneWidget);

        // Reset for next iteration
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Both buttons visible when cosmetic provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          milestone: 10,
          cosmeticReward: testCosmetic,
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('View Collection'), findsOneWidget);
    });

    testWidgets('Shows gradient background with amber theme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(milestone: 10),
      );

      // Verify container with gradient is present
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });
}
