import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

/// Service for managing Firebase Cloud Messaging and local notifications
///
/// Handles:
/// - FCM token registration and refresh
/// - Remote message reception
/// - Local notification display
/// - Notification routing based on event type
class FirebaseMessagingService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;

  /// Callbacks for different notification types
  final void Function(Map<String, dynamic>)? onMilestoneNotification;
  final void Function(Map<String, dynamic>)? onStreakResetNotification;
  final void Function(Map<String, dynamic>)? onCampaignNotification;
  final void Function(Map<String, dynamic>)? onMatchAvailableNotification;

  FirebaseMessagingService({
    FirebaseMessaging? fcm,
    FlutterLocalNotificationsPlugin? localNotifications,
    this.onMilestoneNotification,
    this.onStreakResetNotification,
    this.onCampaignNotification,
    this.onMatchAvailableNotification,
  })  : _fcm = fcm ?? FirebaseMessaging.instance,
        _localNotifications = localNotifications ?? FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging and local notifications
  ///
  /// Must be called on app startup before any notifications can be received.
  Future<void> initialize() async {
    try {
      // Request permission (iOS only, Android handles via manifest)
      if (Platform.isIOS) {
        await _fcm.requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carefullyChoosedOption: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Handle foreground messages (app open)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message (app in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification when app terminated
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      // Subscribe to default topics
      await _subscribeToTopics();
    } catch (e) {
      // Silently fail — app continues without notifications
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    try {
      const initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettingsIOS = DarwinInitializationSettings();

      const initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          final payload = details.payload;
          if (payload != null) {
            _routeNotification(Map.from(jsonDecode(payload)));
          }
        },
      );

      // Create notification channels for Android
      await _createNotificationChannels();
    } catch (e) {
      // Silent fail
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    try {
      const androidPlugin = AndroidFlutterLocalNotificationsPlugin();

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          id: 'milestone_channel',
          name: 'Milestone Notifications',
          description: 'Notifications for streak milestones',
          importance: Importance.high,
          enableSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          id: 'streak_reset_channel',
          name: 'Streak Recovery',
          description: 'Notifications to help recover streaks',
          importance: Importance.high,
          enableSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          id: 'campaign_channel',
          name: 'Campaigns & Events',
          description: 'Notifications for seasonal events and campaigns',
          importance: Importance.default_,
          enableSound: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          id: 'match_channel',
          name: 'Match Updates',
          description: 'Notifications for match availability',
          importance: Importance.default_,
          enableSound: false,
        ),
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Subscribe to default FCM topics
  Future<void> _subscribeToTopics() async {
    try {
      // Subscribe to universal topic for app-wide announcements
      await _fcm.subscribeToTopic('all_players');

      // Subscribe to locale-specific topic (if needed)
      await _fcm.subscribeToTopic('locale_japan');
    } catch (e) {
      // Silent fail
    }
  }

  /// Handle message when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final data = message.data;
      final notification = message.notification;

      // Show local notification
      if (notification != null) {
        await _showLocalNotification(
          title: notification.title ?? 'Toriverse',
          body: notification.body ?? '',
          payload: jsonEncode(data),
          channelId: _getChannelIdFromType(data['type']),
        );
      }

      // Route to appropriate handler
      _routeNotification(data);
    } catch (e) {
      // Silent fail
    }
  }

  /// Handle notification tap (app in background or terminated)
  Future<void> _handleNotificationTap(RemoteMessage message) async {
    try {
      _routeNotification(message.data);
    } catch (e) {
      // Silent fail
    }
  }

  /// Route notification to appropriate handler based on type
  void _routeNotification(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String? ?? '';

      switch (type) {
        case 'milestone_reached':
          onMilestoneNotification?.call(data);
          break;
        case 'streak_reset_recovery':
          onStreakResetNotification?.call(data);
          break;
        case 'campaign':
        case 'seasonal_event':
          onCampaignNotification?.call(data);
          break;
        case 'match_available':
          onMatchAvailableNotification?.call(data);
          break;
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Get Android notification channel ID for notification type
  String _getChannelIdFromType(String? type) {
    return switch (type) {
      'milestone_reached' => 'milestone_channel',
      'streak_reset_recovery' => 'streak_reset_channel',
      'campaign' || 'seasonal_event' => 'campaign_channel',
      'match_available' => 'match_channel',
      _ => 'default_channel',
    };
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String payload,
    required String channelId,
  }) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Toriverse Notifications',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            enableSound: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Get FCM token for this device
  ///
  /// Used to send personalized notifications from backend.
  Future<String?> getFcmToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Listen to FCM token refresh
  ///
  /// Call this to persist new tokens to backend when they refresh.
  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  /// Subscribe to a specific FCM topic
  ///
  /// Topics allow broadcasting notifications to groups of users.
  /// Example: "regional_jp", "loyal_players", "new_users_cohort"
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
    } catch (e) {
      // Silent fail
    }
  }

  /// Unsubscribe from a specific FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
    } catch (e) {
      // Silent fail
    }
  }

  /// Unsubscribe from all notifications
  ///
  /// Used when user opts out of notifications in settings.
  Future<void> unsubscribeFromAll() async {
    try {
      await _fcm.unsubscribeFromTopic('all_players');
      await _fcm.unsubscribeFromTopic('locale_japan');
    } catch (e) {
      // Silent fail
    }
  }
}

/// Import for jsonEncode/jsonDecode
import 'dart:convert';
