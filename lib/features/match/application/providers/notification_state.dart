import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sentinel marking a copyWith parameter as "not passed", distinct from an
/// explicitly-passed null.
const Object _unset = Object();

/// Represents user's notification preferences
class NotificationPreferences {
  /// Enable/disable all notifications
  final bool enabled;

  /// Push notification for milestone achievement
  final bool milestoneNotifications;

  /// Push notification for streak reset recovery
  final bool streakRecoveryNotifications;

  /// Push notification for campaigns and seasonal events
  final bool campaignNotifications;

  /// Push notification when opponent available for match
  final bool matchAvailableNotifications;

  /// Enable sound/vibration
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// Daily quiet hours (no notifications between these times)
  final TimeOfDay? quietHourStart;
  final TimeOfDay? quietHourEnd;

  const NotificationPreferences({
    this.enabled = true,
    this.milestoneNotifications = true,
    this.streakRecoveryNotifications = true,
    this.campaignNotifications = true,
    this.matchAvailableNotifications = false, // Default off - less intrusive
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHourStart,
    this.quietHourEnd,
  });

  /// All notifications enabled
  bool get allEnabled =>
      milestoneNotifications &&
      streakRecoveryNotifications &&
      campaignNotifications &&
      matchAvailableNotifications;

  /// Create a copy with optional updates.
  ///
  /// quietHourStart/quietHourEnd are themselves nullable (clearing quiet
  /// hours is a real operation, see setQuietHours(null, null)), so a plain
  /// `x ?? this.x` fallback can't tell "not passed" apart from "explicitly
  /// cleared" — both look like a null argument. Use `_unset` as the default
  /// so only an actually-omitted argument falls back to the current value.
  NotificationPreferences copyWith({
    bool? enabled,
    bool? milestoneNotifications,
    bool? streakRecoveryNotifications,
    bool? campaignNotifications,
    bool? matchAvailableNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    Object? quietHourStart = _unset,
    Object? quietHourEnd = _unset,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      milestoneNotifications: milestoneNotifications ?? this.milestoneNotifications,
      streakRecoveryNotifications: streakRecoveryNotifications ?? this.streakRecoveryNotifications,
      campaignNotifications: campaignNotifications ?? this.campaignNotifications,
      matchAvailableNotifications: matchAvailableNotifications ?? this.matchAvailableNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      quietHourStart: identical(quietHourStart, _unset)
          ? this.quietHourStart
          : quietHourStart as TimeOfDay?,
      quietHourEnd: identical(quietHourEnd, _unset)
          ? this.quietHourEnd
          : quietHourEnd as TimeOfDay?,
    );
  }

  /// Convert to Map for persistence
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'milestone_notifications': milestoneNotifications,
      'streak_recovery_notifications': streakRecoveryNotifications,
      'campaign_notifications': campaignNotifications,
      'match_available_notifications': matchAvailableNotifications,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'quiet_hour_start': quietHourStart?.toString(),
      'quiet_hour_end': quietHourEnd?.toString(),
    };
  }

  /// Create from persisted Map
  static NotificationPreferences fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      enabled: map['enabled'] as bool? ?? true,
      milestoneNotifications: map['milestone_notifications'] as bool? ?? true,
      streakRecoveryNotifications: map['streak_recovery_notifications'] as bool? ?? true,
      campaignNotifications: map['campaign_notifications'] as bool? ?? true,
      matchAvailableNotifications: map['match_available_notifications'] as bool? ?? false,
      soundEnabled: map['sound_enabled'] as bool? ?? true,
      vibrationEnabled: map['vibration_enabled'] as bool? ?? true,
      quietHourStart: TimeOfDay.parse(map['quiet_hour_start'] as String?),
      quietHourEnd: TimeOfDay.parse(map['quiet_hour_end'] as String?),
    );
  }

  @override
  String toString() => 'NotificationPreferences(enabled=$enabled)';
}

/// Time of day for quiet hours
class TimeOfDay {
  final int hour; // 0-23
  final int minute; // 0-59

  const TimeOfDay({required this.hour, required this.minute});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeOfDay && other.hour == hour && other.minute == minute);

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  static TimeOfDay? parse(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

/// Notifier for notification preferences
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier(NotificationPreferences initial) : super(initial);

  /// Toggle all notifications
  void toggleAll(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  /// Toggle specific notification type
  void toggleMilestoneNotifications(bool enabled) {
    state = state.copyWith(milestoneNotifications: enabled);
  }

  void toggleStreakRecoveryNotifications(bool enabled) {
    state = state.copyWith(streakRecoveryNotifications: enabled);
  }

  void toggleCampaignNotifications(bool enabled) {
    state = state.copyWith(campaignNotifications: enabled);
  }

  void toggleMatchAvailableNotifications(bool enabled) {
    state = state.copyWith(matchAvailableNotifications: enabled);
  }

  /// Toggle sound/vibration
  void toggleSound(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
  }

  void toggleVibration(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
  }

  /// Set quiet hours
  void setQuietHours(TimeOfDay? start, TimeOfDay? end) {
    state = state.copyWith(quietHourStart: start, quietHourEnd: end);
  }

  /// Reset to defaults
  void reset() {
    state = const NotificationPreferences();
  }
}

/// Provider for notification preferences
final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>(
  (ref) {
    return NotificationPreferencesNotifier(
      const NotificationPreferences(),
    );
  },
);

/// Provider for milestone notifications setting (read-only)
final milestoneNotificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationPreferencesProvider).milestoneNotifications;
});

/// Provider for streak recovery notifications setting (read-only)
final streakRecoveryNotificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationPreferencesProvider).streakRecoveryNotifications;
});

/// Provider for campaign notifications setting (read-only)
final campaignNotificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationPreferencesProvider).campaignNotifications;
});
