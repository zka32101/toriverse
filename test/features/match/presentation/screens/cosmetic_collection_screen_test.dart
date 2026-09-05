import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/cosmetic_state.dart';
import 'package:toriverse/features/match/presentation/screens/cosmetic_collection_screen.dart';

void main() {
  group('CosmeticCollectionScreen', () {
    late List<CosmeticItem> testCatalog;
    late List<OwnedCosmetic> testOwnedCosmetics;

    setUp(() {
      testCatalog = [
        const CosmeticItem(
          id: 'board_wood_dark',
          type: 'board',
          name: 'Dark Wood Board',
          rarity: 'common',
          price: 120,
        ),
        const CosmeticItem(
          id: 'board_marble',
          type: 'board',
          name: 'Marble Board',
          rarity: 'rare',
          price: 250,
        ),
        const CosmeticItem(
          id: 'stone_golden',
          type: 'stone',
          name: 'Golden Stones',
          rarity: 'legendary',
          price: 300,
        ),
      ];

      testOwnedCosmetics = [
        OwnedCosmetic(
          itemId: 'board_wood_dark',
          source: 'starter_kit',
          acquiredAt: DateTime.now(),
          isActive: true,
        ),
        OwnedCosmetic(
          itemId: 'board_marble',
          source: 'milestone_reward',
          acquiredAt: DateTime.now().subtract(const Duration(days: 1)),
          isActive: false,
        ),
      ];
    });

    Widget createTestScreen({
      List<CosmeticItem>? catalog,
      List<OwnedCosmetic>? ownedCosmetics,
    }) {
      return ProviderContainer(
        child: MaterialApp(
          home: ProviderScope(
            overrides: [
              cosmeticProvider.overrideWithValue(
                CosmeticState(
                  ownedCosmetics: ownedCosmetics ?? testOwnedCosmetics,
                  activeBoardId: 'board_wood_dark',
                  catalogItems: catalog ?? testCatalog,
                ),
              ),
            ],
            child: const CosmeticCollectionScreen(),
          ),
        ),
      );
    }

    testWidgets('Displays three tabs: Owned, Shop, Boards',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Owned'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Boards'), findsOneWidget);
    });

    testWidgets('Owned tab shows list of owned cosmetics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Owned tab
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('Dark Wood Board'), findsOneWidget);
      expect(find.text('Marble Board'), findsOneWidget);
      expect(find.text('COMMON'), findsOneWidget);
      expect(find.text('RARE'), findsOneWidget);
    });

    testWidgets('Shows active cosmetic with checkmark',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Owned tab
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('✓ Active'), findsOneWidget);
    });

    testWidgets('Shows inactive cosmetic with Activate button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Owned tab
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('Activate'), findsWidgets);
    });

    testWidgets('Shop tab shows available cosmetics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Shop tab
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();

      // Golden Stones is available (not owned yet)
      expect(find.text('Golden Stones'), findsOneWidget);
      expect(find.text('¥300'), findsOneWidget);
    });

    testWidgets('Shop tab shows Buy buttons for each cosmetic',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Shop tab
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();

      expect(find.text('Buy'), findsWidgets);
    });

    testWidgets('Boards tab shows grid of board cosmetics',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Boards tab
      await tester.tap(find.text('Boards'));
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('Dark Wood Board'), findsOneWidget);
      expect(find.text('Marble Board'), findsOneWidget);
    });

    testWidgets('Active board shows gold border on Boards tab',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Boards tab
      await tester.tap(find.text('Boards'));
      await tester.pumpAndSettle();

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('Owned tab shows source label', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Owned tab
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('From: starter_kit'), findsOneWidget);
      expect(find.text('From: milestone_reward'), findsOneWidget);
    });

    testWidgets('Empty owned state shows helpful message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestScreen(ownedCosmetics: []),
      );

      expect(find.text('No cosmetics yet'), findsOneWidget);
      expect(find.text('Complete matches to earn cosmetics'),
        findsOneWidget);
    });

    testWidgets('Empty shop shows helpful message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestScreen(catalog: []),
      );

      // Tap on Shop tab
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing new right now'), findsOneWidget);
      expect(find.text('Check back later for seasonal items'), findsOneWidget);
    });

    testWidgets('Cosmetics display rarity badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Owned tab
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('COMMON'), findsOneWidget);
      expect(find.text('RARE'), findsOneWidget);
    });

    testWidgets('Tapping board activates it', (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Tap on Boards tab
      await tester.tap(find.text('Boards'));
      await tester.pumpAndSettle();

      // Tap on an inactive board
      final marblebid = find.byWidgetPredicate((widget) =>
          widget is Text && widget.data == 'Marble Board');
      expect(marblebid, findsOneWidget);

      // Get parent gesture detector and tap it
      final gestureDetector = find.ancestor(
        of: marblebid,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(gestureDetector.first);
      await tester.pumpAndSettle();
    });

    testWidgets('All rarity types display correctly',
        (WidgetTester tester) async {
      final rarities = ['common', 'uncommon', 'rare', 'legendary'];
      final cosmetics = rarities
          .asMap()
          .entries
          .map((entry) => CosmeticItem(
                id: 'test_${entry.key}',
                type: 'board',
                name: '${entry.value.toUpperCase()} Board',
                rarity: entry.value,
              ))
          .toList();

      await tester.pumpWidget(createTestScreen(
        catalog: cosmetics,
        ownedCosmetics: cosmetics
            .map((c) => OwnedCosmetic(
                  itemId: c.id,
                  source: 'test',
                  acquiredAt: DateTime.now(),
                  isActive: c.id == 'test_0',
                ))
            .toList(),
      ));

      // Tap on Owned tab to see owned cosmetics with rarities
      await tester.tap(find.text('Owned'));
      await tester.pumpAndSettle();

      expect(find.text('COMMON'), findsOneWidget);
      expect(find.text('UNCOMMON'), findsOneWidget);
      expect(find.text('RARE'), findsOneWidget);
      expect(find.text('LEGENDARY'), findsOneWidget);
    });

    testWidgets('Screen responds to tab changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestScreen());

      // Start on Owned tab
      expect(find.text('Dark Wood Board'), findsOneWidget);

      // Switch to Shop tab
      await tester.tap(find.text('Shop'));
      await tester.pumpAndSettle();
      expect(find.text('Golden Stones'), findsOneWidget);

      // Switch to Boards tab
      await tester.tap(find.text('Boards'));
      await tester.pumpAndSettle();
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
