import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/match/application/providers/notification_state.dart';

void main() {
  group('NotificationPreferences', () {
    group('construction', () {
      test('creates with default values', () {
        const prefs = NotificationPreferences();

        expect(prefs.enabled, isTrue);
        expect(prefs.milestoneNotifications, isTrue);
        expect(prefs.streakRecoveryNotifications, isTrue);
        expect(prefs.campaignNotifications, isTrue);
        expect(prefs.matchAvailableNotifications, isFalse);
        expect(prefs.soundEnabled, isTrue);
        expect(prefs.vibrationEnabled, isTrue);
        expect(prefs.quietHourStart, isNull);
        expect(prefs.quietHourEnd, isNull);
      });

      test('creates with custom values', () {
        const start = TimeOfDay(hour: 22, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        const prefs = NotificationPreferences(
          enabled: false,
          milestoneNotifications: false,
          streakRecoveryNotifications: false,
          campaignNotifications: false,
          matchAvailableNotifications: true,
          soundEnabled: false,
          vibrationEnabled: false,
          quietHourStart: start,
          quietHourEnd: end,
        );

        expect(prefs.enabled, isFalse);
        expect(prefs.milestoneNotifications, isFalse);
        expect(prefs.streakRecoveryNotifications, isFalse);
        expect(prefs.campaignNotifications, isFalse);
        expect(prefs.matchAvailableNotifications, isTrue);
        expect(prefs.soundEnabled, isFalse);
        expect(prefs.vibrationEnabled, isFalse);
        expect(prefs.quietHourStart, equals(start));
        expect(prefs.quietHourEnd, equals(end));
      });
    });

    group('allEnabled getter', () {
      test('returns true when all notifications enabled', () {
        const prefs = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: true,
          campaignNotifications: true,
          matchAvailableNotifications: true,
        );

        expect(prefs.allEnabled, isTrue);
      });

      test('returns false when any notification disabled', () {
        const prefs = NotificationPreferences(
          milestoneNotifications: true,
          streakRecoveryNotifications: true,
          campaignNotifications: false,
          matchAvailableNotifications: true,
        );

        expect(prefs.allEnabled, isFalse);
      });

      test('returns false when all notifications disabled', () {
        const prefs = NotificationPreferences(
          milestoneNotifications: false,
          streakRecoveryNotifications: false,
          campaignNotifications: false,
          matchAvailableNotifications: false,
        );

        expect(prefs.allEnabled, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with single field change', () {
        const original = NotificationPreferences();
        final updated = original.copyWith(enabled: false);

        expect(updated.enabled, isFalse);
        expect(updated.milestoneNotifications, original.milestoneNotifications);
        expect(updated.streakRecoveryNotifications, original.streakRecoveryNotifications);
      });

      test('copies with multiple field changes', () {
        const original = NotificationPreferences();
        final updated = original.copyWith(
          milestoneNotifications: false,
          campaignNotifications: false,
          soundEnabled: false,
        );

        expect(updated.milestoneNotifications, isFalse);
        expect(updated.campaignNotifications, isFalse);
        expect(updated.soundEnabled, isFalse);
        expect(updated.enabled, original.enabled);
        expect(updated.streakRecoveryNotifications, original.streakRecoveryNotifications);
      });

      test('copies with quiet hours', () {
        const original = NotificationPreferences();
        const start = TimeOfDay(hour: 22, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        final updated = original.copyWith(
          quietHourStart: start,
          quietHourEnd: end,
        );

        expect(updated.quietHourStart, equals(start));
        expect(updated.quietHourEnd, equals(end));
      });

      test('copies can reset quiet hours', () {
        const start = TimeOfDay(hour: 22, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        const original = NotificationPreferences(
          quietHourStart: start,
          quietHourEnd: end,
        );

        final updated = original.copyWith(
          quietHourStart: null,
          quietHourEnd: null,
        );

        expect(updated.quietHourStart, isNull);
        expect(updated.quietHourEnd, isNull);
      });
    });

    group('serialization', () {
      test('toMap converts to Map<String, dynamic>', () {
        const start = TimeOfDay(hour: 23, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        const prefs = NotificationPreferences(
          enabled: true,
          milestoneNotifications: true,
          streakRecoveryNotifications: false,
          campaignNotifications: true,
          matchAvailableNotifications: false,
          soundEnabled: true,
          vibrationEnabled: false,
          quietHourStart: start,
          quietHourEnd: end,
        );

        final map = prefs.toMap();

        expect(map['enabled'], isTrue);
        expect(map['milestone_notifications'], isTrue);
        expect(map['streak_recovery_notifications'], isFalse);
        expect(map['campaign_notifications'], isTrue);
        expect(map['match_available_notifications'], isFalse);
        expect(map['sound_enabled'], isTrue);
        expect(map['vibration_enabled'], isFalse);
        expect(map['quiet_hour_start'], equals('23:00'));
        expect(map['quiet_hour_end'], equals('08:00'));
      });

      test('toMap handles null quiet hours', () {
        const prefs = NotificationPreferences(
          quietHourStart: null,
          quietHourEnd: null,
        );

        final map = prefs.toMap();

        expect(map['quiet_hour_start'], isNull);
        expect(map['quiet_hour_end'], isNull);
      });

      test('fromMap reconstructs from Map', () {
        const start = TimeOfDay(hour: 23, minute: 0);
        const end = TimeOfDay(hour: 8, minute: 0);

        const original = NotificationPreferences(
          enabled: true,
          milestoneNotifications: false,
          streakRecoveryNotifications: true,
          campaignNotifications: false,
          matchAvailableNotifications: true,
          soundEnabled: false,
          vibrationEnabled: true,
          quietHourStart: start,
          quietHourEnd: end,
        );

        final map = original.toMap();
        final reconstructed = NotificationPreferences.fromMap(map);

        expect(reconstructed.enabled, equals(original.enabled));
        expect(reconstructed.milestoneNotifications, equals(original.milestoneNotifications));
        expect(reconstructed.streakRecoveryNotifications, equals(original.streakRecoveryNotifications));
        expect(reconstructed.campaignNotifications, equals(original.campaignNotifications));
        expect(reconstructed.matchAvailableNotifications, equals(original.matchAvailableNotifications));
        expect(reconstructed.soundEnabled, equals(original.soundEnabled));
        expect(reconstructed.vibrationEnabled, equals(original.vibrationEnabled));
      });

      test('fromMap uses defaults for missing fields', () {
        final map = {
          'enabled': false,
        };

        final prefs = NotificationPreferences.fromMap(map);

        expect(prefs.enabled, isFalse);
        expect(prefs.milestoneNotifications, isTrue);
        expect(prefs.streakRecoveryNotifications, isTrue);
        expect(prefs.campaignNotifications, isTrue);
        expect(prefs.matchAvailableNotifications, isFalse);
        expect(prefs.soundEnabled, isTrue);
        expect(prefs.vibrationEnabled, isTrue);
      });

      test('fromMap handles empty map', () {
        final map = <String, dynamic>{};

        final prefs = NotificationPreferences.fromMap(map);

        // Should return defaults
        expect(prefs.enabled, isTrue);
        expect(prefs.milestoneNotifications, isTrue);
      });
    });
  });

  group('TimeOfDay', () {
    group('construction', () {
      test('creates with valid values', () {
        const time = TimeOfDay(hour: 14, minute: 30);

        expect(time.hour, equals(14));
        expect(time.minute, equals(30));
      });

      test('creates with midnight', () {
        const time = TimeOfDay(hour: 0, minute: 0);

        expect(time.hour, equals(0));
        expect(time.minute, equals(0));
      });

      test('creates with end of day', () {
        const time = TimeOfDay(hour: 23, minute: 59);

        expect(time.hour, equals(23));
        expect(time.minute, equals(59));
      });
    });

    group('toString', () {
      test('formats time with leading zeros', () {
        const time = TimeOfDay(hour: 9, minute: 5);

        expect(time.toString(), equals('09:05'));
      });

      test('formats time without leading zeros needed', () {
        const time = TimeOfDay(hour: 14, minute: 30);

        expect(time.toString(), equals('14:30'));
      });

      test('formats midnight correctly', () {
        const time = TimeOfDay(hour: 0, minute: 0);

        expect(time.toString(), equals('00:00'));
      });

      test('formats end of day correctly', () {
        const time = TimeOfDay(hour: 23, minute: 59);

        expect(time.toString(), equals('23:59'));
      });
    });

    group('parse', () {
      test('parses valid time string', () {
        final time = TimeOfDay.parse('14:30');

        expect(time, isNotNull);
        expect(time!.hour, equals(14));
        expect(time.minute, equals(30));
      });

      test('parses time with leading zeros', () {
        final time = TimeOfDay.parse('09:05');

        expect(time, isNotNull);
        expect(time!.hour, equals(9));
        expect(time.minute, equals(5));
      });

      test('parses midnight', () {
        final time = TimeOfDay.parse('00:00');

        expect(time, isNotNull);
        expect(time!.hour, equals(0));
        expect(time.minute, equals(0));
      });

      test('parses end of day', () {
        final time = TimeOfDay.parse('23:59');

        expect(time, isNotNull);
        expect(time!.hour, equals(23));
        expect(time.minute, equals(59));
      });

      test('returns null for invalid format', () {
        final time = TimeOfDay.parse('14-30');

        expect(time, isNull);
      });

      test('returns null for missing colon', () {
        final time = TimeOfDay.parse('1430');

        expect(time, isNull);
      });

      test('returns null for invalid hour', () {
        final time = TimeOfDay.parse('25:00');

        expect(time, isNull);
      });

      test('returns null for invalid minute', () {
        final time = TimeOfDay.parse('14:60');

        expect(time, isNull);
      });

      test('returns null for empty string', () {
        final time = TimeOfDay.parse('');

        expect(time, isNull);
      });

      test('returns null for null input', () {
        final time = TimeOfDay.parse(null);

        expect(time, isNull);
      });

      test('returns null for non-numeric values', () {
        final time = TimeOfDay.parse('ab:cd');

        expect(time, isNull);
      });
    });

    group('round-trip serialization', () {
      test('parse(toString()) returns equivalent TimeOfDay', () {
        const original = TimeOfDay(hour: 14, minute: 30);
        final roundTrip = TimeOfDay.parse(original.toString());

        expect(roundTrip, isNotNull);
        expect(roundTrip!.hour, equals(original.hour));
        expect(roundTrip.minute, equals(original.minute));
      });

      test('round-trip works for various times', () {
        const times = [
          TimeOfDay(hour: 0, minute: 0),
          TimeOfDay(hour: 9, minute: 5),
          TimeOfDay(hour: 12, minute: 0),
          TimeOfDay(hour: 23, minute: 59),
        ];

        for (final original in times) {
          final roundTrip = TimeOfDay.parse(original.toString());
          expect(roundTrip!.hour, equals(original.hour));
          expect(roundTrip.minute, equals(original.minute));
        }
      });
    });
  });

  group('NotificationPreferencesNotifier', () {
    test('initializes with provided state', () {
      const initial = NotificationPreferences(enabled: false);
      final notifier = NotificationPreferencesNotifier(initial);

      expect(notifier.state.enabled, isFalse);
    });

    test('toggleAll changes enabled state', () {
      const initial = NotificationPreferences(enabled: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleAll(false);

      expect(notifier.state.enabled, isFalse);
    });

    test('toggleMilestoneNotifications changes state', () {
      const initial = NotificationPreferences(milestoneNotifications: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleMilestoneNotifications(false);

      expect(notifier.state.milestoneNotifications, isFalse);
    });

    test('toggleStreakRecoveryNotifications changes state', () {
      const initial = NotificationPreferences(streakRecoveryNotifications: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleStreakRecoveryNotifications(false);

      expect(notifier.state.streakRecoveryNotifications, isFalse);
    });

    test('toggleCampaignNotifications changes state', () {
      const initial = NotificationPreferences(campaignNotifications: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleCampaignNotifications(false);

      expect(notifier.state.campaignNotifications, isFalse);
    });

    test('toggleMatchAvailableNotifications changes state', () {
      const initial = NotificationPreferences(matchAvailableNotifications: false);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleMatchAvailableNotifications(true);

      expect(notifier.state.matchAvailableNotifications, isTrue);
    });

    test('toggleSound changes state', () {
      const initial = NotificationPreferences(soundEnabled: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleSound(false);

      expect(notifier.state.soundEnabled, isFalse);
    });

    test('toggleVibration changes state', () {
      const initial = NotificationPreferences(vibrationEnabled: true);
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleVibration(false);

      expect(notifier.state.vibrationEnabled, isFalse);
    });

    test('setQuietHours updates state', () {
      const initial = NotificationPreferences();
      final notifier = NotificationPreferencesNotifier(initial);

      const start = TimeOfDay(hour: 22, minute: 0);
      const end = TimeOfDay(hour: 8, minute: 0);

      notifier.setQuietHours(start, end);

      expect(notifier.state.quietHourStart, equals(start));
      expect(notifier.state.quietHourEnd, equals(end));
    });

    test('setQuietHours can clear quiet hours', () {
      const start = TimeOfDay(hour: 22, minute: 0);
      const end = TimeOfDay(hour: 8, minute: 0);

      const initial = NotificationPreferences(
        quietHourStart: start,
        quietHourEnd: end,
      );

      final notifier = NotificationPreferencesNotifier(initial);

      notifier.setQuietHours(null, null);

      expect(notifier.state.quietHourStart, isNull);
      expect(notifier.state.quietHourEnd, isNull);
    });

    test('reset returns to defaults', () {
      const customInitial = NotificationPreferences(
        enabled: false,
        milestoneNotifications: false,
        campaignNotifications: false,
        soundEnabled: false,
      );

      final notifier = NotificationPreferencesNotifier(customInitial);

      notifier.reset();

      expect(notifier.state.enabled, isTrue);
      expect(notifier.state.milestoneNotifications, isTrue);
      expect(notifier.state.campaignNotifications, isTrue);
      expect(notifier.state.soundEnabled, isTrue);
    });

    test('multiple state changes compose correctly', () {
      const initial = NotificationPreferences();
      final notifier = NotificationPreferencesNotifier(initial);

      notifier.toggleMilestoneNotifications(false);
      notifier.toggleSound(false);
      notifier.toggleVibration(false);

      expect(notifier.state.milestoneNotifications, isFalse);
      expect(notifier.state.soundEnabled, isFalse);
      expect(notifier.state.vibrationEnabled, isFalse);
      // Others should remain unchanged
      expect(notifier.state.enabled, isTrue);
      expect(notifier.state.campaignNotifications, isTrue);
    });
  });
}
