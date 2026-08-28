import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/analytics_and_moderation_providers.dart';
import '../../domain/models/analytics_and_moderation.dart';

class PushNotificationSettingsWidget extends ConsumerStatefulWidget {
  final String userId;

  const PushNotificationSettingsWidget({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  ConsumerState<PushNotificationSettingsWidget> createState() =>
      _PushNotificationSettingsWidgetState();
}

class _PushNotificationSettingsWidgetState
    extends ConsumerState<PushNotificationSettingsWidget> {
  final Map<NotificationType, bool> _preferences = {
    for (final type in NotificationType.values) type: true,
  };

  Future<void> _updatePreference(NotificationType type, bool enabled) async {
    setState(() => _preferences[type] = enabled);
    final repo = ref.read(analyticsAndModerationRepositoryProvider);
    await repo.updateNotificationPreferences(
      widget.userId,
      _preferences.map((key, value) => MapEntry(key.name, value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...NotificationType.values.map(
          (type) => SwitchListTile(
            title: Text(_notificationLabel(type)),
            value: _preferences[type] ?? true,
            onChanged: (value) => _updatePreference(type, value),
          ),
        ),
      ],
    );
  }

  String _notificationLabel(NotificationType type) {
    switch (type) {
      case NotificationType.matchResult:
        return 'Match Results';
      case NotificationType.friendRequest:
        return 'Friend Requests';
      case NotificationType.followerActivity:
        return 'Follower Activity';
      case NotificationType.newClip:
        return 'New Clips';
      case NotificationType.liveStream:
        return 'Live Streams';
    }
  }
}
