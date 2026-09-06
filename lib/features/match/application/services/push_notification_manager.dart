import '../../../shared/services/firebase_messaging_service.dart';
import '../../../shared/services/remote_config_service.dart';
import 'dart:async';

/// Service for managing game-specific push notifications
///
/// Handles:
/// - Milestone achievement celebrations
/// - Streak reset recovery prompts
/// - Match available notifications
/// - Campaign promotions
class PushNotificationManager {
  final FirebaseMessagingService _messaging;
  final RemoteConfigService _remoteConfig;

  PushNotificationManager({
    required FirebaseMessagingService messaging,
    required RemoteConfigService remoteConfig,
  })  : _messaging = messaging,
        _remoteConfig = remoteConfig;

  /// Initialize push notification handling
  ///
  /// Must be called once on app startup.
  Future<void> initialize() async {
    try {
      await _messaging.initialize();
      _setupNotificationCallbacks();
    } catch (e) {
      // Silent fail
    }
  }

  /// Setup callbacks for different notification types
  void _setupNotificationCallbacks() {
    _messaging.onMilestoneNotification = _handleMilestoneNotification;
    _messaging.onStreakResetNotification = _handleStreakResetNotification;
    _messaging.onCampaignNotification = _handleCampaignNotification;
    _messaging.onMatchAvailableNotification = _handleMatchAvailableNotification;
  }

  /// Handle milestone achievement notification tap
  void _handleMilestoneNotification(Map<String, dynamic> data) {
    try {
      final milestone = int.tryParse(data['milestone'] ?? '');
      if (milestone != null) {
        // Navigate to match result screen with celebration
        // In real implementation, would use navigation context
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Handle streak reset recovery notification tap
  void _handleStreakResetNotification(Map<String, dynamic> data) {
    try {
      final streakLost = int.tryParse(data['streak_lost'] ?? '');
      if (streakLost != null) {
        // Show recovery prompt or navigate to home
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Handle campaign/seasonal event notification tap
  void _handleCampaignNotification(Map<String, dynamic> data) {
    try {
      final campaignId = data['campaign_id'] as String?;
      if (campaignId != null) {
        // Navigate to campaign details screen
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Handle match available notification tap
  void _handleMatchAvailableNotification(Map<String, dynamic> data) {
    try {
      // Navigate to matchmaking screen
    } catch (e) {
      // Silent fail
    }
  }

  /// Send milestone achievement notification
  ///
  /// Called server-side after milestone is confirmed.
  /// This is for reference — actual sending happens on backend via FCM API.
  Future<void> sendMilestoneNotification({
    required String deviceToken,
    required int milestone,
    required String rewardName,
    required String rewardRarity,
  }) async {
    try {
      // Server-side only: This would be called via backend Cloud Function
      // For reference: POST to Firebase Messaging API with payload:
      // {
      //   "to": deviceToken,
      //   "notification": {
      //     "title": "🎉 Milestone $milestone!",
      //     "body": "You earned: $rewardName ($rewardRarity)"
      //   },
      //   "data": {
      //     "type": "milestone_reached",
      //     "milestone": "$milestone",
      //     "reward_id": rewardId
      //   }
      // }
    } catch (e) {
      // Silent fail
    }
  }

  /// Send streak recovery notification
  ///
  /// Sent when player's streak is broken, offering encouragement to play again.
  /// Timing: 2-4 hours after streak loss (tuned via Remote Config)
  Future<void> sendStreakRecoveryNotification({
    required String deviceToken,
    required int streakLost,
  }) async {
    try {
      // Only send if push notifications enabled (Remote Config)
      if (!_remoteConfig.isFeatureEnabled('push_notifications')) {
        return;
      }

      // Server-side: Firebase Messaging API call
      // {
      //   "to": deviceToken,
      //   "notification": {
      //     "title": "Come back to regain your streak",
      //     "body": "You were on a $streakLost-match winning streak! 💪"
      //   },
      //   "data": {
      //     "type": "streak_reset_recovery",
      //     "streak_lost": "$streakLost"
      //   }
      // }
    } catch (e) {
      // Silent fail
    }
  }

  /// Send match available notification
  ///
  /// Sent to idle players when opponents are waiting for match.
  /// Uses topic-based delivery for efficiency.
  Future<void> broadcastMatchAvailableNotification({
    required int waitingPlayers,
    required String estimatedMatchTime,
  }) async {
    try {
      // Server-side: Firebase Messaging API to topic "all_players"
      // {
      //   "topic": "all_players",
      //   "notification": {
      //     "title": "Match waiting!",
      //     "body": "$waitingPlayers players ready. Start in ~$estimatedMatchTime"
      //   },
      //   "data": {
      //     "type": "match_available"
      //   }
      // }
    } catch (e) {
      // Silent fail
    }
  }

  /// Send campaign/seasonal event notification
  ///
  /// Sent to announce new campaigns or seasonal events.
  /// Includes campaign details and call-to-action.
  Future<void> sendCampaignNotification({
    required String deviceToken,
    required String campaignId,
    required String campaignName,
    required String description,
    required String imageUrl,
  }) async {
    try {
      // Server-side: Firebase Messaging API with rich notification
      // {
      //   "to": deviceToken,
      //   "notification": {
      //     "title": "🎊 $campaignName",
      //     "body": description
      //   },
      //   "data": {
      //     "type": "campaign",
      //     "campaign_id": campaignId,
      //     "image_url": imageUrl
      //   }
      // }
    } catch (e) {
      // Silent fail
    }
  }

  /// Subscribe to specific user cohort topic
  ///
  /// Examples:
  /// - "new_players_day_1" → 24h after signup
  /// - "high_engagement" → Daily active users
  /// - "at_risk_churn" → Inactive 7+ days
  /// - "vip_subscribers" → Paid users
  Future<void> subscribeToCohortTopic(String cohort) async {
    try {
      await _messaging.subscribeToTopic(cohort);
    } catch (e) {
      // Silent fail
    }
  }

  /// Unsubscribe from cohort topic
  Future<void> unsubscribeFromCohortTopic(String cohort) async {
    try {
      await _messaging.unsubscribeFromTopic(cohort);
    } catch (e) {
      // Silent fail
    }
  }

  /// Get current FCM device token
  ///
  /// Use to register this device for personalized notifications.
  Future<String?> getDeviceToken() async {
    try {
      return await _messaging.getFcmToken();
    } catch (e) {
      return null;
    }
  }

  /// Listen to FCM token refresh
  ///
  /// When Firebase refreshes the device token, update the backend.
  /// Example usage:
  /// ```dart
  /// _manager.onTokenRefresh.listen((newToken) {
  ///   // POST to backend: /users/{userId}/fcm-token
  ///   updateBackendFcmToken(newToken);
  /// });
  /// ```
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Disable all push notifications
  ///
  /// Called when user opts out of notifications in app settings.
  Future<void> disableAllNotifications() async {
    try {
      await _messaging.unsubscribeFromAll();
    } catch (e) {
      // Silent fail
    }
  }

  /// Enable all push notifications
  ///
  /// Called when user opts in to notifications.
  Future<void> enableAllNotifications() async {
    try {
      // Re-subscribe to default topics
      await _messaging.subscribeToTopic('all_players');
      await _messaging.subscribeToTopic('locale_japan');
    } catch (e) {
      // Silent fail
    }
  }
}

/// Notification payload models for type safety

class MilestoneNotificationPayload {
  final int milestone;
  final String rewardId;
  final String rewardName;
  final String rewardRarity;

  MilestoneNotificationPayload({
    required this.milestone,
    required this.rewardId,
    required this.rewardName,
    required this.rewardRarity,
  });

  Map<String, String> toDataMap() => {
        'type': 'milestone_reached',
        'milestone': milestone.toString(),
        'reward_id': rewardId,
        'reward_name': rewardName,
        'reward_rarity': rewardRarity,
      };
}

class StreakResetNotificationPayload {
  final int streakLost;
  final String reason;

  StreakResetNotificationPayload({
    required this.streakLost,
    required this.reason,
  });

  Map<String, String> toDataMap() => {
        'type': 'streak_reset_recovery',
        'streak_lost': streakLost.toString(),
        'reason': reason,
      };
}

class CampaignNotificationPayload {
  final String campaignId;
  final String campaignName;
  final String description;
  final String imageUrl;
  final int? rewardValue;

  CampaignNotificationPayload({
    required this.campaignId,
    required this.campaignName,
    required this.description,
    required this.imageUrl,
    this.rewardValue,
  });

  Map<String, String> toDataMap() => {
        'type': 'campaign',
        'campaign_id': campaignId,
        'campaign_name': campaignName,
        'description': description,
        'image_url': imageUrl,
        if (rewardValue != null) 'reward_value': rewardValue.toString(),
      };
}
