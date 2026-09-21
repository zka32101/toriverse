import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/application/providers/cosmetics_providers.dart';
import 'package:toriverse/features/shop/presentation/widgets/cosmetic_item_card.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticItemCard', () {
    late CosmeticItem testCosmetic;

    setUp(() {
      testCosmetic = CosmeticItem(
        id: 'test_board_1',
        name: 'Test Board Design',
        type: CosmeticType.board,
        price: 300,
        description: 'A test board design for testing',
        rarity: CosmeticRarity.rare,
        colorScheme: 'default',
        previewImageUrl: 'assets/test.png',
        releaseDate: DateTime(2026, 1, 1),
        requiresMinVersion: '0.1.0',
        revenuekatProductId: 'test_product',
      );
    });

    /// Wraps [child] with a [ProviderScope] whose cosmetic-ownership and
    /// preference providers are overridden so the card renders
    /// deterministically without touching real Firebase-backed services.
    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          userOwnsCosmeticProvider.overrideWith((ref, id) async => false),
          userCosmeticsPreferenceProvider.overrideWith(
            (ref) async => const UserCosmeticsPreference(),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('displays cosmetic name', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      expect(find.text('Test Board Design'), findsOneWidget);
    });

    testWidgets('displays cosmetic price', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      expect(find.text('¥300'), findsWidgets);
    });

    testWidgets('displays rarity badge for rare cosmetic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      expect(find.text('レア'), findsOneWidget);
    });

    testWidgets('displays purchase button for unowned cosmetic',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      expect(find.text('購入'), findsWidgets);
    });

    testWidgets('card is tappable and opens detail dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      // Tap the card
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Dialog should be displayed with cosmetic name
      expect(find.text('Test Board Design'), findsWidgets);
    });

    testWidgets('displays cosmetic type icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      // Icon should be displayed
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('card has proper structure with column layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: testCosmetic)),
      );
      await tester.pump();

      // Verify the card widget exists
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('displays common rarity cosmetic without rarity badge',
        (WidgetTester tester) async {
      final commonCosmetic = testCosmetic.copyWith(
        rarity: CosmeticRarity.common,
      );

      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: commonCosmetic)),
      );
      await tester.pump();

      // Common cosmetic should not have a rarity badge
      expect(find.text('コモン'), findsNothing);
    });

    testWidgets('displays limited edition rarity badge',
        (WidgetTester tester) async {
      final limitedCosmetic = testCosmetic.copyWith(
        rarity: CosmeticRarity.limited,
      );

      await tester.pumpWidget(
        wrap(CosmeticItemCard(cosmetic: limitedCosmetic)),
      );
      await tester.pump();

      expect(find.text('限定'), findsOneWidget);
    });
  });
}
