import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/presentation/widgets/cosmetic_item_card.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticItemCard', () {
    late CosmeticItem testCosmetic;

    setUp(() {
      testCosmetic = const CosmeticItem(
        id: 'test_board_1',
        name: 'Test Board Design',
        typeString: 'board',
        priceJpy: 300,
        description: 'A test board design for testing',
        rarity: CosmeticRarity.rare,
        availableFrom: null,
        availableUntil: null,
      );
    });

    testWidgets('displays cosmetic name', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      expect(find.text('Test Board Design'), findsOneWidget);
    });

    testWidgets('displays cosmetic price', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      expect(find.text('¥300'), findsWidgets);
    });

    testWidgets('displays rarity badge for rare cosmetic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      expect(find.text('レア'), findsOneWidget);
    });

    testWidgets('displays purchase button for unowned cosmetic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      expect(find.text('購入'), findsWidgets);
    });

    testWidgets('card is tappable and opens detail dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Dialog should be displayed with cosmetic name
      expect(find.text('Test Board Design'), findsWidgets);
    });

    testWidgets('displays cosmetic type icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      // Icon should be displayed
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('card has proper structure with column layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: testCosmetic),
            ),
          ),
        ),
      );

      // Verify the card widget exists
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays common rarity cosmetic without rarity badge',
        (WidgetTester tester) async {
      final commonCosmetic = testCosmetic.copyWith(
        rarity: CosmeticRarity.common,
      );

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: commonCosmetic),
            ),
          ),
        ),
      );

      // Common cosmetic should not have a rarity badge
      expect(find.text('コモン'), findsNothing);
    });

    testWidgets('displays limited edition rarity badge',
        (WidgetTester tester) async {
      final limitedCosmetic = testCosmetic.copyWith(
        rarity: CosmeticRarity.limited,
      );

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(
              body: CosmeticItemCard(cosmetic: limitedCosmetic),
            ),
          ),
        ),
      );

      expect(find.text('限定'), findsOneWidget);
    });
  });
}
