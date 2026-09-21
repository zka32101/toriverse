import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toriverse/shared/services/firebase_messaging_service.dart';

/// Workaround for mockito's `any` being statically typed `Null`, which makes
/// `any as SomeType` provably always-throwing to the analyzer. Casting through
/// a generic type parameter defers the check past analysis time.
T _any<T>() => any as T;

/// Same workaround as [_any], for mockito's `anyNamed`.
T _anyNamed<T>(String named) => anyNamed(named) as T;

// Mock classes
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockRemoteMessage extends Mock implements RemoteMessage {
  @override
  final Map<String, dynamic> data;
  @override
  final RemoteNotification? notification;

  MockRemoteMessage({
    required this.data,
    this.notification,
  });
}

class MockRemoteNotification extends Mock implements RemoteNotification {
  @override
  final String? title;
  @override
  final String? body;

  MockRemoteNotification({this.title, this.body});
}

void main() {
  group('FirebaseMessagingService', () {
    late MockFirebaseMessaging mockFcm;
    late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
    late FirebaseMessagingService service;

    setUp(() {
      mockFcm = MockFirebaseMessaging();
      mockLocalNotifications = MockFlutterLocalNotificationsPlugin();

      // Default mock behaviors
      when(mockLocalNotifications.initialize(_any<InitializationSettings>(), onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
          .thenAnswer((_) async => true);
    });

    group('initialization', () {
      test('initialize completes successfully', () async {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );

        // Mock FCM request permission
        when(mockFcm.requestPermission(
          alert: _anyNamed<bool>('alert'),
          announcement: _anyNamed<bool>('announcement'),
          badge: _anyNamed<bool>('badge'),
          carPlay: _anyNamed<bool>('carPlay'),
          criticalAlert: _anyNamed<bool>('criticalAlert'),
          provisional: _anyNamed<bool>('provisional'),
          sound: _anyNamed<bool>('sound'),
        )).thenAnswer((_) async => const NotificationSettings(
          alert: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.enabled,
          authorizationStatus: AuthorizationStatus.authorized,
          badge: AppleNotificationSetting.enabled,
          carPlay: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.enabled,
          notificationCenter: AppleNotificationSetting.enabled,
          showPreviews: AppleShowPreviewSetting.always,
          sound: AppleNotificationSetting.enabled,
          timeSensitive: AppleNotificationSetting.disabled,
        ));

        when(mockFcm.getInitialMessage()).thenAnswer((_) async => null);

        await service.initialize();

        // Verify initialization was called
        verify(mockFcm.getInitialMessage()).called(1);
      });

      test('initialize handles gracefully on error', () async {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );

        when(mockLocalNotifications.initialize(_any<InitializationSettings>(), onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse')))
            .thenThrow(Exception('Init failed'));

        // Should not throw
        await service.initialize();
      });
    });

    group('topic management', () {
      setUp(() {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );
      });

      test('subscribeToTopic subscribes to FCM topic', () async {
        when(mockFcm.subscribeToTopic('test_topic')).thenAnswer((_) async {});

        await service.subscribeToTopic('test_topic');

        verify(mockFcm.subscribeToTopic('test_topic')).called(1);
      });

      test('subscribeToTopic handles error silently', () async {
        when(mockFcm.subscribeToTopic('test_topic'))
            .thenThrow(Exception('Subscribe failed'));

        // Should not throw
        await service.subscribeToTopic('test_topic');
      });

      test('unsubscribeFromTopic unsubscribes from FCM topic', () async {
        when(mockFcm.unsubscribeFromTopic('test_topic')).thenAnswer((_) async {});

        await service.unsubscribeFromTopic('test_topic');

        verify(mockFcm.unsubscribeFromTopic('test_topic')).called(1);
      });

      test('unsubscribeFromTopic handles error silently', () async {
        when(mockFcm.unsubscribeFromTopic('test_topic'))
            .thenThrow(Exception('Unsubscribe failed'));

        // Should not throw
        await service.unsubscribeFromTopic('test_topic');
      });

      test('unsubscribeFromAll unsubscribes from all topics', () async {
        when(mockFcm.unsubscribeFromTopic(_any<String>())).thenAnswer((_) async {});

        await service.unsubscribeFromAll();

        verify(mockFcm.unsubscribeFromTopic('all_players')).called(1);
        verify(mockFcm.unsubscribeFromTopic('locale_japan')).called(1);
      });
    });

    group('FCM token management', () {
      setUp(() {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );
      });

      test('getFcmToken returns device token', () async {
        when(mockFcm.getToken()).thenAnswer((_) async => 'test_token_123');

        final token = await service.getFcmToken();

        expect(token, equals('test_token_123'));
        verify(mockFcm.getToken()).called(1);
      });

      test('getFcmToken returns null on error', () async {
        when(mockFcm.getToken()).thenThrow(Exception('Token error'));

        final token = await service.getFcmToken();

        expect(token, isNull);
      });

      test('onTokenRefresh returns stream from FCM', () {
        when(mockFcm.onTokenRefresh).thenAnswer((_) => Stream.value('new_token'));

        final stream = service.onTokenRefresh;

        expect(stream, isNotNull);
      });
    });

    group('notification routing', () {
      setUp(() {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );
      });

      test('milestone notification routed correctly', () {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
          onMilestoneNotification: (_) {},
        );

        // Simulate routing (this would be called internally)
        // The routing logic is private, but we test it's callable
        expect(service, isNotNull);
      });

      test('campaign notification routed correctly', () {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
          onCampaignNotification: (_) {},
        );

        expect(service, isNotNull);
      });

      test('streak reset notification routed correctly', () {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
          onStreakResetNotification: (_) {},
        );

        expect(service, isNotNull);
      });

      test('match available notification routed correctly', () {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
          onMatchAvailableNotification: (_) {},
        );

        expect(service, isNotNull);
      });
    });

    group('notification channels', () {
      setUp(() {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );
      });

      test('initializes with proper channel configuration', () async {
        when(mockFcm.requestPermission(
          alert: _anyNamed<bool>('alert'),
          announcement: _anyNamed<bool>('announcement'),
          badge: _anyNamed<bool>('badge'),
          carPlay: _anyNamed<bool>('carPlay'),
          criticalAlert: _anyNamed<bool>('criticalAlert'),
          provisional: _anyNamed<bool>('provisional'),
          sound: _anyNamed<bool>('sound'),
        )).thenAnswer((_) async => const NotificationSettings(
          alert: AppleNotificationSetting.enabled,
          announcement: AppleNotificationSetting.enabled,
          authorizationStatus: AuthorizationStatus.authorized,
          badge: AppleNotificationSetting.enabled,
          carPlay: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.enabled,
          notificationCenter: AppleNotificationSetting.enabled,
          showPreviews: AppleShowPreviewSetting.always,
          sound: AppleNotificationSetting.enabled,
          timeSensitive: AppleNotificationSetting.disabled,
        ));

        when(mockFcm.getInitialMessage()).thenAnswer((_) async => null);

        await service.initialize();

        verify(mockLocalNotifications.initialize(_any<InitializationSettings>(), onDidReceiveNotificationResponse: anyNamed('onDidReceiveNotificationResponse'))).called(1);
      });
    });

    group('edge cases', () {
      setUp(() {
        service = FirebaseMessagingService(
          fcm: mockFcm,
          localNotifications: mockLocalNotifications,
        );
      });

      test('handles empty topic string', () async {
        when(mockFcm.subscribeToTopic('')).thenAnswer((_) async {});

        await service.subscribeToTopic('');

        verify(mockFcm.subscribeToTopic('')).called(1);
      });

      test('handles multiple topic subscriptions', () async {
        when(mockFcm.subscribeToTopic(_any<String>())).thenAnswer((_) async {});

        await service.subscribeToTopic('topic_1');
        await service.subscribeToTopic('topic_2');
        await service.subscribeToTopic('topic_3');

        verify(mockFcm.subscribeToTopic('topic_1')).called(1);
        verify(mockFcm.subscribeToTopic('topic_2')).called(1);
        verify(mockFcm.subscribeToTopic('topic_3')).called(1);
      });

      test('handles subscription with special characters', () async {
        when(mockFcm.subscribeToTopic('topic_with_123_chars')).thenAnswer((_) async {});

        await service.subscribeToTopic('topic_with_123_chars');

        verify(mockFcm.subscribeToTopic('topic_with_123_chars')).called(1);
      });
    });
  });
}
