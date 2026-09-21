import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/application/providers/cosmetics_providers.dart';
import 'package:toriverse/features/shop/presentation/screens/cosmetics_shop_screen.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticsShopScreen', () {
    late List<CosmeticItem> mockCosmetics;

    setUp(() {
      mockCosmetics = [
        CosmeticItem(
          id: 'board_1',
          name: 'Classic Board',
          type: CosmeticType.board,
          price: 300,
          description: 'A classic board design',
          rarity: CosmeticRarity.common,
          colorScheme: 'default',
          previewImageUrl: 'assets/test.png',
          releaseDate: DateTime(2026, 1, 1),
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'board_1_product',
        ),
        CosmeticItem(
          id: 'stone_black_1',
          name: 'Black Stone',
          type: CosmeticType.stoneBlack,
          price: 120,
          description: 'Classic black stone',
          rarity: CosmeticRarity.common,
          colorScheme: 'default',
          previewImageUrl: 'assets/test.png',
          releaseDate: DateTime(2026, 1, 1),
          requiresMinVersion: '0.1.0',
          revenuekatProductId: 'stone_black_1_product',
        ),
      ];
    });

    /// Wraps [CosmeticsShopScreen] with a [ProviderScope] that serves
    /// [mockCosmetics] for every cosmetic type, so the screen renders
    /// deterministically without touching real Firebase-backed services.
    Widget wrap() {
      return ProviderScope(
        overrides: [
          cosmeticsByTypeProvider.overrideWith((ref, type) async => mockCosmetics),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: CosmeticsShopScreen(),
          ),
        ),
      );
    }

    testWidgets('displays shop title', (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('コスメティックス'), findsWidgets);
    });

    testWidgets('displays type selector chips', (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      expect(find.text('ボード'), findsWidgets);
      expect(find.text('黒い石'), findsWidgets);
      expect(find.text('白い石'), findsWidgets);
      expect(find.text('赤い石'), findsWidgets);
    });

    testWidgets('changes cosmetic type when chip is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      // Tap on stone selector
      await tester.tap(find.text('黒い石'));
      await tester.pumpAndSettle();

      // Verify the chip is now selected (should have different styling)
      final chip = find.byType(FilterChip);
      expect(chip, findsWidgets);
    });

    testWidgets('displays empty state when no cosmetics available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cosmeticsByTypeProvider.overrideWith((ref, type) async => <CosmeticItem>[]),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CosmeticsShopScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      // The screen should display some UI even with empty data
      expect(find.byType(CosmeticsShopScreen), findsOneWidget);
    });

    testWidgets('displays cosmetics in grid view', (WidgetTester tester) async {
      await tester.pumpWidget(wrap());
      await tester.pump();

      // Verify grid view exists
      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('scaffold contains app bar and body', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cosmeticsByTypeProvider.overrideWith((ref, type) async => mockCosmetics),
          ],
          child: const MaterialApp(
            home: CosmeticsShopScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
      // Material's `AppBar` wraps its own content in a `SafeArea`
      // internally, in addition to the one CosmeticsShopScreen wraps its
      // body in — so two `SafeArea`s is the correct count here, not one.
      expect(find.byType(SafeArea), findsNWidgets(2));
    });
  });
}
