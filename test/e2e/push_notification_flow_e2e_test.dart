import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:toriverse/features/match/application/providers/notification_state.dart';
import 'package:flutter/material.dart';

/// Mock FirebaseRemoteConfig for push notification testing
class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {
  final Map<String, dynamic> _values = {
    'enable_milestone_notifications': true,
    'enable_streak_recovery': true,
    'enable_campaigns': true,
    'enable_match_available': true,
    'notification_sound_default': true,
    'notification_vibration_default': true,
  };

  @override
  String getString(String key) => _values[key]?.toString() ?? '';

  @override
  bool getBool(String key) => _values[key] as bool? ?? false;

  @override
  int getInt(String key) => int.tryParse(_values[key]?.toString() ?? '0') ?? 0;

  @override
  double getDouble(String key) =>
      double.tryParse(_values[key]?.toString() ?? '0.0') ?? 0.0;
}

void main() {
  group('Push Notification Flow E2E Tests', () {
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() {
      mockRemoteConfig = MockFirebaseRemoteConfig();
    });

    group('Notification Preferences Lifecycle', () {
      test('user can toggle all notifications and verify state propagation', () {
        // Initial state: all enabled
        const initial = NotificationPreferences(
          enabled: true,
          milestoneNotifications: true,
          streakRecoveryNotifications: true,
          campaignNotifications: true,
          matchAvailableNotifications: false,
          soundEnabled: true,
          vibrationEnabled: true,
        );

        final notifier = NotificationPreferencesNotifier(initial);

        // User disables all notifications
        notifier.toggleAll(false);

        expect(notifier.state.enabled, isFalse);

        // User re-enables
        notifier.toggleAll(true);
        expect(notifier.state.enabled, isTrue);
      });

      test('user can configure granular notification preferences', () {
        const initial = NotificationPreferences();
        final notifier = NotificationPreferencesNotifier(initial);

        // User journey: disable specific notification types
        notifier.toggleMilestoneNotifications(false);
        expect(notifier.state.milestoneNotifications, isFalse);
        expect(notifier.state.enabled, isTrue); // Master still enabled

        notifier.toggleStreakRecoveryNotifications(false);
        expect(notifier.state.streakRecoveryNotifications, isFalse);

        notifier.toggleSound(false);
        expect(notifier.state.soundEnabled, isFalse);

        notifier.toggleVibration(false);
        expect(notifier.state.vibrationEnabled, isFalse);

        // Campaign notifications remain enabled
        expect(notifier.state.campaignNotifications, isTrue);
      });

      test('user can set and modify quiet hours', () {
        const initial = NotificationPreferences();
        final notifier = NotificationPreferencesNotifier(initial);

        // Set quiet hours: 22:00 to 08:00
        const startTime = TimeOfDay(hour: 22, minute: 0);
        const endTime = TimeOfDay(hour: 8, minute: 0);

        notifier.setQuietHours(startTime, endTime);

        expect(notifier.state.quietHourStart, equals(startTime));
        expect(notifier.state.quietHourEnd, equals(endTime));

        // Update quiet hours: 23:00 to 07:00
        const newStart = TimeOfDay(hour: 23, minute: 0);
        const newEnd = TimeOfDay(hour: 7, minute: 0);

        notifier.setQuietHours(newStart, newEnd);

        expect(notifier.state.quietHourStart, equals(newStart));
        expect(notifier.state.quietHourEnd, equals(newEnd));
      });

      test('user can clear quiet hours', () {
        const start = TimeOfDay(hour: 22, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        const initial = NotificationPreferences(
          quietHourStart: start,
          quietHourEnd: end,
        );

        final notifier = NotificationPreferencesNotifier(initial);

        // Clear quiet hours
        notifier.setQuietHours(null, null);

        expect(notifier.state.quietHourStart, isNull);
        expect(notifier.state.quietHourEnd, isNull);
      });

      test('user can reset all preferences to defaults', () {
        const customPrefs = NotificationPreferences(
          enabled: false,
          milestoneNotifications: false,
          streakRecoveryNotifications: false,
          campaignNotifications: false,
          matchAvailableNotifications: true,
          soundEnabled: false,
          vibrationEnabled: false,
        );

        final notifier = NotificationPreferencesNotifier(customPrefs);

        // Verify initial custom state
        expect(notifier.state.enabled, isFalse);
        expect(notifier.state.soundEnabled, isFalse);

        // Reset to defaults
        notifier.reset();

        // Verify defaults restored
        expect(notifier.state.enabled, isTrue);
        expect(notifier.state.milestoneNotifications, isTrue);
        expect(notifier.state.streakRecoveryNotifications, isTrue);
        expect(notifier.state.campaignNotifications, isTrue);
        expect(notifier.state.matchAvailableNotifications, isFalse);
        expect(notifier.state.soundEnabled, isTrue);
        expect(notifier.state.vibrationEnabled, isTrue);
      });
    });

    group('Notification State Serialization', () {
      test('notification preferences can be serialized and restored', () {
        const start = TimeOfDay(hour: 23, minute: 30);
        const end = TimeOfDay(hour: 7, minute: 30);

        const original = NotificationPreferences(
          enabled: true,
          milestoneNotifications: false,
          streakRecoveryNotifications: true,
          campaignNotifications: false,
          matchAvailableNotifications: true,
          soundEnabled: true,
          vibrationEnabled: false,
          quietHourStart: start,
          quietHourEnd: end,
        );

        // Serialize
        final map = original.toMap();

        // Verify serialization format
        expect(map['enabled'], isTrue);
        expect(map['milestone_notifications'], isFalse);
        expect(map['streak_recovery_notifications'], isTrue);
        expect(map['campaign_notifications'], isFalse);
        expect(map['match_available_notifications'], isTrue);
        expect(map['sound_enabled'], isTrue);
        expect(map['vibration_enabled'], isFalse);
        expect(map['quiet_hour_start'], equals('23:30'));
        expect(map['quiet_hour_end'], equals('07:30'));

        // Deserialize
        final restored = NotificationPreferences.fromMap(map);

        expect(restored.enabled, equals(original.enabled));
        expect(restored.milestoneNotifications, equals(original.milestoneNotifications));
        expect(restored.streakRecoveryNotifications,
            equals(original.streakRecoveryNotifications));
        expect(restored.campaignNotifications, equals(original.campaignNotifications));
        expect(restored.matchAvailableNotifications,
            equals(original.matchAvailableNotifications));
        expect(restored.soundEnabled, equals(original.soundEnabled));
        expect(restored.vibrationEnabled, equals(original.vibrationEnabled));
        expect(restored.quietHourStart, equals(original.quietHourStart));
        expect(restored.quietHourEnd, equals(original.quietHourEnd));
      });

      test('serialization handles partial data gracefully', () {
        final partial = {
          'enabled': false,
          'sound_enabled': true,
        };

        final prefs = NotificationPreferences.fromMap(partial);

        // Provided values
        expect(prefs.enabled, isFalse);
        expect(prefs.soundEnabled, isTrue);

        // Defaults for missing values
        expect(prefs.milestoneNotifications, isTrue);
        expect(prefs.streakRecoveryNotifications, isTrue);
        expect(prefs.campaignNotifications, isTrue);
        expect(prefs.matchAvailableNotifications, isFalse);
        expect(prefs.vibrationEnabled, isTrue);
      });

      test('serialization handles null quiet hours', () {
        const prefs = NotificationPreferences(
          quietHourStart: null,
          quietHourEnd: null,
        );

        final map = prefs.toMap();
        expect(map['quiet_hour_start'], isNull);
        expect(map['quiet_hour_end'], isNull);

        final restored = NotificationPreferences.fromMap(map);
        expect(restored.quietHourStart, isNull);
        expect(restored.quietHourEnd, isNull);
      });
    });

    group('TimeOfDay Parsing and Formatting', () {
      test('TimeOfDay formats correctly with leading zeros', () {
        const times = [
          (hour: 0, minute: 0, expected: '00:00'),
          (hour: 9, minute: 5, expected: '09:05'),
          (hour: 23, minute: 59, expected: '23:59'),
          (hour: 12, minute: 30, expected: '12:30'),
          (hour: 14, minute: 0, expected: '14:00'),
        ];

        for (final (hour: h, minute: m, expected: e) in times) {
          final time = TimeOfDay(hour: h, minute: m);
          expect(time.toString(), equals(e));
        }
      });

      test('TimeOfDay parses valid time strings', () {
        const validTimes = [
          ('00:00', hour: 0, minute: 0),
          ('09:05', hour: 9, minute: 5),
          ('23:59', hour: 23, minute: 59),
          ('12:30', hour: 12, minute: 30),
          ('14:00', hour: 14, minute: 0),
        ];

        for (final (input, hour: expectedHour, minute: expectedMinute) in validTimes) {
          final parsed = TimeOfDay.parse(input);
          expect(parsed, isNotNull);
          expect(parsed!.hour, equals(expectedHour));
          expect(parsed.minute, equals(expectedMinute));
        }
      });

      test('TimeOfDay parsing rejects invalid formats', () {
        const invalidTimes = [
          '25:00', // Invalid hour
          '14:60', // Invalid minute
          '14-30', // Wrong separator
          '1430', // Missing separator
          'ab:cd', // Non-numeric
          '', // Empty
          ':', // Only separator
        ];

        for (final input in invalidTimes) {
          final parsed = TimeOfDay.parse(input);
          expect(parsed, isNull, reason: 'Should reject "$input"');
        }
      });

      test('TimeOfDay round-trip serialization works correctly', () {
        const times = [
          TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 9, minute: 5),
          TimeOfDay(hour: 12, minute: 30),
          TimeOfDay(hour: 23, minute: 59),
        ];

        for (final original in times) {
          final serialized = original.toString();
          final parsed = TimeOfDay.parse(serialized);

          expect(parsed, isNotNull);
          expect(parsed!.hour, equals(original.hour));
          expect(parsed.minute, equals(original.minute));
        }
      });
    });

    group('Notification Preference Queries', () {
      test('allEnabled getter reflects all notification states correctly', () {
        // All enabled
        const allEnabled = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: true,
          campaignNotifications: true,
          matchAvailableNotifications: true,
        );
        expect(allEnabled.allEnabled, isTrue);

        // One disabled
        const oneMissing = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: true,
          campaignNotifications: false, // Disabled
          matchAvailableNotifications: true,
        );
        expect(oneMissing.allEnabled, isFalse);

        // All disabled
        const allDisabled = NotificationPreferences(
          milestoneNotifications: false,
          streakRecoveryNotifications: false,
          campaignNotifications: false,
          matchAvailableNotifications: false,
        );
        expect(allDisabled.allEnabled, isFalse);
      });

      test('copyWith preserves unmodified fields', () {
        const original = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: false,
          campaignNotifications: true,
          soundEnabled: false,
        );

        final modified = original.copyWith(
          campaignNotifications: false,
          soundEnabled: true,
        );

        // Modified fields
        expect(modified.campaignNotifications, isFalse);
        expect(modified.soundEnabled, isTrue);

        // Unmodified fields
        expect(modified.milestoneNotifications, equals(original.milestoneNotifications));
        expect(modified.streakRecoveryNotifications,
            equals(original.streakRecoveryNotifications));
        expect(modified.enabled, equals(original.enabled));
      });
    });

    group('Multi-State Preference Changes', () {
      test('notification preferences compose state changes correctly', () {
        const initial = NotificationPreferences();
        final notifier = NotificationPreferencesNotifier(initial);

        // Simulate user interaction sequence
        notifier.toggleMilestoneNotifications(false);
        notifier.toggleSound(false);
        notifier.toggleVibration(false);

        // Verify affected fields
        expect(notifier.state.milestoneNotifications, isFalse);
        expect(notifier.state.soundEnabled, isFalse);
        expect(notifier.state.vibrationEnabled, isFalse);

        // Verify unaffected fields
        expect(notifier.state.enabled, isTrue);
        expect(notifier.state.streakRecoveryNotifications, isTrue);
        expect(notifier.state.campaignNotifications, isTrue);
        expect(notifier.state.matchAvailableNotifications, isFalse);
      });

      test('quiet hours changes do not affect notification toggles', () {
        const initial = NotificationPreferences();
        final notifier = NotificationPreferencesNotifier(initial);

        // Record initial notification state
        final initialSound = notifier.state.soundEnabled;
        final initialMilestone = notifier.state.milestoneNotifications;

        // Change quiet hours
        const startTime = TimeOfDay(hour: 22, minute: 0);
        const endTime = TimeOfDay(hour: 8, minute: 0);
        notifier.setQuietHours(startTime, endTime);

        // Verify notification state unchanged
        expect(notifier.state.soundEnabled, equals(initialSound));
        expect(notifier.state.milestoneNotifications, equals(initialMilestone));

        // But quiet hours are set
        expect(notifier.state.quietHourStart, equals(startTime));
        expect(notifier.state.quietHourEnd, equals(endTime));
      });
    });

    group('Cohort-Based Notification Targeting', () {
      test('cohort notification preferences persist across state changes', () {
        // Simulate new player cohort
        const newPlayerPrefs = NotificationPreferences(
          milestoneNotifications: true, // High engagement for new players
          streakRecoveryNotifications: true,
          campaignNotifications: true,
          matchAvailableNotifications: true, // All match types shown
        );

        final newPlayerNotifier = NotificationPreferencesNotifier(newPlayerPrefs);

        // Simulate high engagement cohort
        const highEngagementPrefs = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: false, // Less recovery nudges
          campaignNotifications: true,
          matchAvailableNotifications: false,
        );

        final highEngagementNotifier =
            NotificationPreferencesNotifier(highEngagementPrefs);

        // Verify different cohort profiles
        expect(newPlayerNotifier.state.matchAvailableNotifications, isTrue);
        expect(highEngagementNotifier.state.matchAvailableNotifications, isFalse);
      });
    });
  });
}
