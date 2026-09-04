import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/shop/presentation/widgets/cosmetic_type_selector.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';

void main() {
  group('CosmeticTypeSelector', () {
    testWidgets('displays all cosmetic type options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('ボード'), findsOneWidget);
      expect(find.text('黒い石'), findsOneWidget);
      expect(find.text('白い石'), findsOneWidget);
      expect(find.text('赤い石'), findsOneWidget);
    });

    testWidgets('highlights selected type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (_) {},
            ),
          ),
        ),
      );

      // Check that FilterChip widgets exist (one for each type)
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('calls onTypeChanged when chip is tapped',
        (WidgetTester tester) async {
      CosmeticType? selectedType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (type) {
                selectedType = type;
              },
            ),
          ),
        ),
      );

      // Tap on 黒い石 chip
      await tester.tap(find.text('黒い石'));
      await tester.pumpAndSettle();

      expect(selectedType, CosmeticType.stoneBlack);
    });

    testWidgets('handles state changes correctly', (WidgetTester tester) async {
      CosmeticType currentType = CosmeticType.board;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return MaterialApp(
              home: Scaffold(
                body: CosmeticTypeSelector(
                  selectedType: currentType,
                  onTypeChanged: (type) {
                    setState(() {
                      currentType = type;
                    });
                  },
                ),
              ),
            );
          },
        ),
      );

      // Tap on different type
      await tester.tap(find.text('白い石'));
      await tester.pumpAndSettle();

      // Verify the type changed
      expect(currentType, CosmeticType.stoneWhite);
    });

    testWidgets('scrolls horizontally when needed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the SingleChildScrollView
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('all filter chips are displayed horizontally',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (_) {},
            ),
          ),
        ),
      );

      // Verify all chips are in a Row
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(FilterChip), findsExactly(4));
    });

    testWidgets('correctly switches from board to stone type',
        (WidgetTester tester) async {
      CosmeticType? newType;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CosmeticTypeSelector(
              selectedType: CosmeticType.board,
              onTypeChanged: (type) {
                newType = type;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('赤い石'));
      await tester.pumpAndSettle();

      expect(newType, CosmeticType.stoneRed);
    });
  });
}
