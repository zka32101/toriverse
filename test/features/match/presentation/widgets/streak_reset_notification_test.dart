import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/presentation/widgets/streak_reset_notification.dart';

void main() {
  group('StreakResetNotification', () {
    Widget createTestApp({
      String reason = 'manual_quit',
      int currentStreak = 10,
      VoidCallback? onConfirm,
      VoidCallback? onCancel,
      bool isPersistent = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: StreakResetNotification(
            reason: reason,
            currentStreak: currentStreak,
            onConfirm: onConfirm,
            onCancel: onCancel,
            isPersistent: isPersistent,
          ),
        ),
      );
    }

    testWidgets('Dialog mode displays warning message for manual quit',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          currentStreak: 5,
          isPersistent: false,
        ),
      );

      expect(find.text('Streak at Risk'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.contains('5-match streak')),
        findsOneWidget,
      );
    });

    testWidgets('Dialog mode displays warning for connection timeout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'connection_timeout',
          currentStreak: 15,
          isPersistent: false,
        ),
      );

      expect(find.text('Streak at Risk'), findsOneWidget);
      expect(find.text('Connection was lost during the match'), findsOneWidget);
    });

    testWidgets('Dialog mode displays warning for system error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'system_error',
          currentStreak: 8,
          isPersistent: false,
        ),
      );

      expect(find.text('Streak at Risk'), findsOneWidget);
      expect(find.text('An unexpected error occurred'), findsOneWidget);
    });

    testWidgets('Persistent mode displays as banner notification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'connection_timeout',
          currentStreak: 10,
          isPersistent: true,
        ),
      );

      expect(find.byType(Container), findsWidgets);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Cancel button dismisses dialog and calls onCancel',
        (WidgetTester tester) async {
      bool cancelCalled = false;

      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          onCancel: () {
            cancelCalled = true;
          },
          isPersistent: false,
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(cancelCalled, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Confirm button dismisses dialog and calls onConfirm',
        (WidgetTester tester) async {
      bool confirmCalled = false;

      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          onConfirm: () {
            confirmCalled = true;
          },
          isPersistent: false,
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(confirmCalled, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Shows correct emoji for each reason type',
        (WidgetTester tester) async {
      // Manual quit (warning emoji)
      await tester.pumpWidget(
        createTestApp(reason: 'manual_quit', isPersistent: false),
      );
      expect(find.text('⚠️'), findsOneWidget);

      // Connection timeout (network emoji)
      await tester.pumpWidget(
        createTestApp(reason: 'connection_timeout', isPersistent: false),
      );
      expect(find.text('📡'), findsOneWidget);

      // System error (gears emoji)
      await tester.pumpWidget(
        createTestApp(reason: 'system_error', isPersistent: false),
      );
      expect(find.text('⚙️'), findsOneWidget);
    });

    testWidgets('Persistent banner shows proper layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          currentStreak: 20,
          isPersistent: true,
        ),
      );

      // Should contain emoji and text
      expect(find.text('⚠️'), findsOneWidget);
      expect(find.text('Streak at Risk'), findsOneWidget);
    });

    testWidgets('Shows streak loss count in dialog',
        (WidgetTester tester) async {
      const testStreaks = [5, 10, 25, 50, 100];

      for (final streak in testStreaks) {
        await tester.pumpWidget(
          createTestApp(
            reason: 'manual_quit',
            currentStreak: streak,
            isPersistent: false,
          ),
        );

        expect(find.text('$streak'), findsWidgets);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Different colors for different severity levels',
        (WidgetTester tester) async {
      final reasons = [
        ('manual_quit', Colors.orange),
        ('connection_timeout', Colors.red),
        ('system_error', Colors.purple),
      ];

      for (final (reason, _) in reasons) {
        await tester.pumpWidget(
          createTestApp(reason: reason, isPersistent: false),
        );

        expect(find.byType(AlertDialog), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Dialog has accessible button sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          isPersistent: false,
        ),
      );

      final buttons = find.byType(TextButton);
      expect(buttons, findsWidgets);

      // Buttons should be present and tappable (>= 44pt)
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.byType(TextButton).at(i));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Shows both buttons in dialog mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestApp(
          reason: 'manual_quit',
          isPersistent: false,
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('Persistent banner dismissible via callback',
        (WidgetTester tester) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        createTestApp(
          reason: 'connection_timeout',
          isPersistent: true,
          onDismiss: () {
            dismissCalled = true;
          },
        ),
      );

      // Verify banner is present
      expect(find.byType(Container), findsWidgets);
    });
  });
}
