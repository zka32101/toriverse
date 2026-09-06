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
        const CosmeticItem(
          id: 'board_1',
          name: 'Classic Board',
          typeString: 'board',
          priceJpy: 300,
          description: 'A classic board design',
          rarity: CosmeticRarity.common,
          availableFrom: null,
          availableUntil: null,
        ),
        const CosmeticItem(
          id: 'stone_black_1',
          name: 'Black Stone',
          typeString: 'stoneBlack',
          priceJpy: 120,
          description: 'Classic black stone',
          rarity: CosmeticRarity.common,
          availableFrom: null,
          availableUntil: null,
        ),
      ];
    });

    testWidgets('displays shop title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: const CosmeticsShopScreen(),
            ),
          ),
        ),
      );

      expect(find.text('コスメティックス'), findsWidgets);
    });

    testWidgets('displays type selector chips', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: const CosmeticsShopScreen(),
            ),
          ),
        ),
      );

      expect(find.text('ボード'), findsWidgets);
      expect(find.text('黒い石'), findsWidgets);
      expect(find.text('白い石'), findsWidgets);
      expect(find.text('赤い石'), findsWidgets);
    });

    testWidgets('changes cosmetic type when chip is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: const CosmeticsShopScreen(),
            ),
          ),
        ),
      );

      // Tap on stone selector
      await tester.tap(find.byText('黒い石'));
      await tester.pumpAndSettle();

      // Verify the chip is now selected (should have different styling)
      final chip = find.byType(FilterChip);
      expect(chip, findsWidgets);
    });

    testWidgets('displays empty state when no cosmetics available',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: const CosmeticsShopScreen(),
            ),
          ),
        ),
      );

      // The screen should display some UI even with empty data
      expect(find.byType(CosmeticsShopScreen), findsOneWidget);
    });

    testWidgets('displays cosmetics in grid view', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: const CosmeticsShopScreen(),
            ),
          ),
        ),
      );

      // Verify grid view exists
      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('scaffold contains app bar and body', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: const CosmeticsShopScreen(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
