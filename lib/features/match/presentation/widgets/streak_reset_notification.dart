import 'package:flutter/material.dart';

/// Notification widget warning about potential streak reset
///
/// Shown when:
/// - Player has active internet connection but connection is unstable
/// - Player is about to quit a match voluntarily
/// - System is about to reset streak due to error
///
/// Provides clear explanation of consequences and recovery options
class StreakResetNotification extends StatelessWidget {
  /// Reason for potential reset
  /// - 'manual_quit': Player voluntarily quit
  /// - 'connection_timeout': Connection lost
  /// - 'system_error': Unexpected error occurred
  final String reason;

  /// Current streak that would be lost
  final int currentStreak;

  /// Callback if user wants to continue anyway
  final VoidCallback? onConfirm;

  /// Callback if user wants to cancel/retry
  final VoidCallback? onCancel;

  /// Whether to show as persistent notification vs dialog
  final bool isPersistent;

  const StreakResetNotification({
    super.key,
    required this.reason,
    required this.currentStreak,
    this.onConfirm,
    this.onCancel,
    this.isPersistent = false,
  });

  @override
  Widget build(BuildContext context) {
    final message = _getResetMessage();
    final icon = _getIcon();
    final color = _getColor();

    if (isPersistent) {
      return _buildPersistentNotification(context, message, icon, color);
    }

    return _buildAlertDialog(context, message, icon, color);
  }

  /// Build persistent in-app notification
  Widget _buildPersistentNotification(
    BuildContext context,
    String message,
    String icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Streak at Risk',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build alert dialog with confirmation
  Widget _buildAlertDialog(
    BuildContext context,
    String message,
    String icon,
    Color color,
  ) {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      title: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Streak at Risk',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your $currentStreak-match streak will be lost if you confirm.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onCancel?.call();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm'),
        ),
      ],
    );
  }

  /// Get appropriate reset message based on reason
  String _getResetMessage() {
    switch (reason) {
      case 'manual_quit':
        return 'Leaving this match will reset your $currentStreak-match streak. Are you sure?';
      case 'connection_timeout':
        return 'Connection was lost during the match. Your streak has been reset to preserve game integrity.';
      case 'system_error':
        return 'An unexpected error occurred. Your streak has been temporarily paused. Contact support if this persists.';
      default:
        return 'Your match completion streak is at risk. Please take action to preserve it.';
    }
  }

  /// Get emoji icon for notification
  String _getIcon() {
    switch (reason) {
      case 'manual_quit':
        return '⚠️';
      case 'connection_timeout':
        return '📡';
      case 'system_error':
        return '⚙️';
      default:
        return '🔥';
    }
  }

  /// Get color based on severity
  Color _getColor() {
    switch (reason) {
      case 'manual_quit':
        return Colors.orange;
      case 'connection_timeout':
        return Colors.red;
      case 'system_error':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

/// Show streak reset confirmation dialog
Future<bool?> showStreakResetDialog(
  BuildContext context, {
  required String reason,
  required int currentStreak,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => StreakResetNotification(
      reason: reason,
      currentStreak: currentStreak,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    ),
  );
}

/// Show persistent notification banner for streak at risk
class StreakResetNotificationBanner extends StatelessWidget {
  final String reason;
  final int currentStreak;
  final VoidCallback? onDismiss;

  const StreakResetNotificationBanner({
    super.key,
    required this.reason,
    required this.currentStreak,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return StreakResetNotification(
      reason: reason,
      currentStreak: currentStreak,
      isPersistent: true,
      onDismiss: onDismiss,
    );
  }
}
