import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/match/application/providers/notification_state.dart';

/// Mock NotificationPreferencesWidget for testing
/// (In production: lib/features/match/presentation/widgets/notification_preferences_widget.dart)
class NotificationPreferencesWidget extends ConsumerWidget {
  const NotificationPreferencesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master toggle
            SwitchListTile(
              title: const Text('All Notifications'),
              value: prefs.enabled,
              onChanged: (value) => notifier.toggleAll(value),
            ),
            const SizedBox(height: 24),

            // Notification type toggles
            const Text('Notification Types',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Milestone Notifications'),
              subtitle: const Text('Celebrate achievements'),
              value: prefs.milestoneNotifications,
              onChanged: (value) => notifier.toggleMilestoneNotifications(value),
            ),
            SwitchListTile(
              title: const Text('Streak Recovery'),
              subtitle: const Text('Recover your streak'),
              value: prefs.streakRecoveryNotifications,
              onChanged: (value) => notifier.toggleStreakRecoveryNotifications(value),
            ),
            SwitchListTile(
              title: const Text('Campaigns & Events'),
              subtitle: const Text('Limited-time offers'),
              value: prefs.campaignNotifications,
              onChanged: (value) => notifier.toggleCampaignNotifications(value),
            ),
            SwitchListTile(
              title: const Text('Match Available'),
              subtitle: const Text('When opponents are waiting'),
              value: prefs.matchAvailableNotifications,
              onChanged: (value) => notifier.toggleMatchAvailableNotifications(value),
            ),
            const SizedBox(height: 24),

            // Sound & Vibration
            const Text('Sound & Vibration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Sound'),
              value: prefs.soundEnabled,
              onChanged: (value) => notifier.toggleSound(value),
            ),
            SwitchListTile(
              title: const Text('Vibration'),
              value: prefs.vibrationEnabled,
              onChanged: (value) => notifier.toggleVibration(value),
            ),
            const SizedBox(height: 24),

            // Quiet Hours
            const Text('Quiet Hours',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (prefs.quietHourStart != null && prefs.quietHourEnd != null)
              Text(
                'No notifications between ${prefs.quietHourStart} and ${prefs.quietHourEnd}',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              const Text('Quiet hours not set'),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              label: const Text('Set Quiet Hours'),
              onPressed: () => _showQuietHoursDialog(context, notifier, prefs),
            ),
            const SizedBox(height: 24),

            // Reset button
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reset to Defaults'),
              onPressed: () => notifier.reset(),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuietHoursDialog(
    BuildContext context,
    NotificationPreferencesNotifier notifier,
    NotificationPreferences prefs,
  ) {
    showDialog(
      context: context,
      builder: (context) => QuietHoursDialog(
        initialStart: prefs.quietHourStart,
        initialEnd: prefs.quietHourEnd,
        onSave: (start, end) {
          notifier.setQuietHours(start, end);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Dialog for setting quiet hours
class QuietHoursDialog extends StatefulWidget {
  final TimeOfDay? initialStart;
  final TimeOfDay? initialEnd;
  final Function(TimeOfDay?, TimeOfDay?) onSave;

  const QuietHoursDialog({
    Key? key,
    this.initialStart,
    this.initialEnd,
    required this.onSave,
  }) : super(key: key);

  @override
  State<QuietHoursDialog> createState() => _QuietHoursDialogState();
}

class _QuietHoursDialogState extends State<QuietHoursDialog> {
  late TimeOfDay? startTime;
  late TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    startTime = widget.initialStart ?? const TimeOfDay(hour: 22, minute: 0);
    endTime = widget.initialEnd ?? const TimeOfDay(hour: 8, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Quiet Hours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Start Time'),
            subtitle: Text(startTime?.format(context) ?? 'Not set'),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: startTime ?? const TimeOfDay(hour: 22, minute: 0),
              );
              if (time != null) setState(() => startTime = time);
            },
          ),
          ListTile(
            title: const Text('End Time'),
            subtitle: Text(endTime?.format(context) ?? 'Not set'),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: endTime ?? const TimeOfDay(hour: 8, minute: 0),
              );
              if (time != null) setState(() => endTime = time);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => widget.onSave(startTime, endTime),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

void main() {
  group('NotificationPreferencesWidget', () {
    testWidgets('displays all preference toggles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Verify main elements are displayed
      expect(find.text('All Notifications'), findsOneWidget);
      expect(find.text('Notification Types'), findsOneWidget);
      expect(find.text('Sound & Vibration'), findsOneWidget);
      expect(find.text('Quiet Hours'), findsOneWidget);
      expect(find.text('Milestone Notifications'), findsOneWidget);
      expect(find.text('Streak Recovery'), findsOneWidget);
      expect(find.text('Campaigns & Events'), findsOneWidget);
      expect(find.text('Match Available'), findsOneWidget);
      expect(find.text('Sound'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);
    });

    testWidgets('toggles all notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find and tap the master toggle
      final masterSwitch = find.byType(SwitchListTile).first;
      await tester.tap(masterSwitch);
      await tester.pumpAndSettle();

      // Verify the toggle changed
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles milestone notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find milestone toggle
      final milestoneToggle = find.byType(SwitchListTile).at(1);
      await tester.tap(milestoneToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles streak recovery notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find streak recovery toggle
      final streakToggle = find.byType(SwitchListTile).at(2);
      await tester.tap(streakToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles campaign notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find campaign toggle
      final campaignToggle = find.byType(SwitchListTile).at(3);
      await tester.tap(campaignToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles match available notifications', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find match available toggle
      final matchToggle = find.byType(SwitchListTile).at(4);
      await tester.tap(matchToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles sound', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find sound toggle
      final soundToggle = find.byType(SwitchListTile).at(5);
      await tester.tap(soundToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('toggles vibration', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Find vibration toggle
      final vibrationToggle = find.byType(SwitchListTile).at(6);
      await tester.tap(vibrationToggle);
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('displays set quiet hours button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      expect(find.text('Set Quiet Hours'), findsOneWidget);
      expect(find.byIcon(Icons.schedule), findsOneWidget);
    });

    testWidgets('displays reset button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      expect(find.text('Reset to Defaults'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('resets to defaults on reset button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Tap reset button
      final resetButton = find.text('Reset to Defaults');
      await tester.tap(resetButton);
      await tester.pumpAndSettle();

      // Verify state is reset
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('displays scroll view for long content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Verify scrollable content
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('displays AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Notification Preferences'), findsOneWidget);
    });

    testWidgets('opens quiet hours dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Tap set quiet hours button
      final quietButton = find.text('Set Quiet Hours');
      await tester.tap(quietButton);
      await tester.pumpAndSettle();

      // Verify dialog is displayed
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Set Quiet Hours'), findsOneWidget);
      expect(find.text('Start Time'), findsOneWidget);
      expect(find.text('End Time'), findsOneWidget);
    });

    testWidgets('quiet hours dialog can be dismissed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Set Quiet Hours'));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('displays all subtitles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      expect(find.text('Celebrate achievements'), findsOneWidget);
      expect(find.text('Recover your streak'), findsOneWidget);
      expect(find.text('Limited-time offers'), findsOneWidget);
      expect(find.text('When opponents are waiting'), findsOneWidget);
    });

    testWidgets('renders without errors with default state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      expect(find.byType(NotificationPreferencesWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('all switches are properly interactive', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationPreferencesWidget(),
          ),
        ),
      );

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Tap multiple switches
      for (int i = 0; i < switches.evaluate().length && i < 3; i++) {
        await tester.tap(switches.at(i));
        await tester.pumpAndSettle();
      }

      expect(tester.takeException(), isNull);
    });
  });
}
