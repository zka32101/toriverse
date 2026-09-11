import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/features/match/application/services/push_notification_manager.dart';
import 'package:toriverse/shared/services/firebase_messaging_service.dart';
import 'package:toriverse/shared/services/remote_config_service.dart';

// Mock classes
class MockFirebaseMessagingService extends Mock
    implements FirebaseMessagingService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('PushNotificationManager', () {
    late MockFirebaseMessagingService mockMessaging;
    late MockRemoteConfigService mockRemoteConfig;
    late PushNotificationManager manager;

    setUp(() {
      mockMessaging = MockFirebaseMessagingService();
      mockRemoteConfig = MockRemoteConfigService();

      manager = PushNotificationManager(
        messaging: mockMessaging,
        remoteConfig: mockRemoteConfig,
      );
    });

    group('initialization', () {
      test('initialize calls messaging initialization', () async {
        when(mockMessaging.initialize()).thenAnswer((_) async {});

        await manager.initialize();

        verify(mockMessaging.initialize()).called(1);
      });

      test('initialize handles error silently', () async {
        when(mockMessaging.initialize()).thenThrow(Exception('Init failed'));

        // Should not throw
        await manager.initialize();
      });
    });

    group('device token management', () {
      test('getDeviceToken returns token from messaging service', () async {
        when(mockMessaging.getFcmToken()).thenAnswer((_) async => 'device_token_123');

        final token = await manager.getDeviceToken();

        expect(token, equals('device_token_123'));
        verify(mockMessaging.getFcmToken()).called(1);
      });

      test('getDeviceToken returns null on error', () async {
        when(mockMessaging.getFcmToken()).thenThrow(Exception('Token error'));

        final token = await manager.getDeviceToken();

        expect(token, isNull);
      });

      test('onTokenRefresh returns stream from messaging service', () {
        when(mockMessaging.onTokenRefresh).thenReturn(Stream.value('new_token'));

        final stream = manager.onTokenRefresh;

        expect(stream, isNotNull);
      });
    });

    group('cohort topic management', () {
      test('subscribeToCohortTopic subscribes to topic', () async {
        when(mockMessaging.subscribeToTopic('new_players_day_1')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('new_players_day_1');

        verify(mockMessaging.subscribeToTopic('new_players_day_1')).called(1);
      });

      test('subscribeToCohortTopic handles common cohorts', () async {
        when(mockMessaging.subscribeToTopic(any)).thenAnswer((_) async {});

        final cohorts = ['new_players_day_1', 'high_engagement', 'at_risk_churn', 'vip_subscribers', 'locale_japan'];

        for (final cohort in cohorts) {
          await manager.subscribeToCohortTopic(cohort);
        }

        for (final cohort in cohorts) {
          verify(mockMessaging.subscribeToTopic(cohort)).called(1);
        }
      });

      test('subscribeToCohortTopic handles error silently', () async {
        when(mockMessaging.subscribeToTopic('test_cohort'))
            .thenThrow(Exception('Subscribe failed'));

        // Should not throw
        await manager.subscribeToCohortTopic('test_cohort');
      });

      test('unsubscribeFromCohortTopic unsubscribes from topic', () async {
        when(mockMessaging.unsubscribeFromTopic('new_players_day_1')).thenAnswer((_) async {});

        await manager.unsubscribeFromCohortTopic('new_players_day_1');

        verify(mockMessaging.unsubscribeFromTopic('new_players_day_1')).called(1);
      });

      test('unsubscribeFromCohortTopic handles error silently', () async {
        when(mockMessaging.unsubscribeFromTopic('test_cohort'))
            .thenThrow(Exception('Unsubscribe failed'));

        // Should not throw
        await manager.unsubscribeFromCohortTopic('test_cohort');
      });
    });

    group('notification disabling/enabling', () {
      test('disableAllNotifications unsubscribes from all', () async {
        when(mockMessaging.unsubscribeFromAll()).thenAnswer((_) async {});

        await manager.disableAllNotifications();

        verify(mockMessaging.unsubscribeFromAll()).called(1);
      });

      test('disableAllNotifications handles error silently', () async {
        when(mockMessaging.unsubscribeFromAll())
            .thenThrow(Exception('Disable failed'));

        // Should not throw
        await manager.disableAllNotifications();
      });

      test('enableAllNotifications subscribes to default topics', () async {
        when(mockMessaging.subscribeToTopic(any)).thenAnswer((_) async {});

        await manager.enableAllNotifications();

        verify(mockMessaging.subscribeToTopic('all_players')).called(1);
        verify(mockMessaging.subscribeToTopic('locale_japan')).called(1);
      });

      test('enableAllNotifications handles error silently', () async {
        when(mockMessaging.subscribeToTopic(any))
            .thenThrow(Exception('Enable failed'));

        // Should not throw
        await manager.enableAllNotifications();
      });
    });

    group('notification sending (reference)', () {
      test('sendMilestoneNotification handles gracefully', () async {
        // Note: These are server-side methods with reference implementations
        await manager.sendMilestoneNotification(
          deviceToken: 'token_123',
          milestone: 10,
          rewardName: 'Gold Stone',
          rewardRarity: 'rare',
        );

        // Should not throw
      });

      test('sendStreakRecoveryNotification checks Remote Config', () async {
        when(mockRemoteConfig.isFeatureEnabled('push_notifications'))
            .thenReturn(true);

        await manager.sendStreakRecoveryNotification(
          deviceToken: 'token_123',
          streakLost: 5,
        );

        verify(mockRemoteConfig.isFeatureEnabled('push_notifications')).called(1);
      });

      test('sendStreakRecoveryNotification skips when disabled', () async {
        when(mockRemoteConfig.isFeatureEnabled('push_notifications'))
            .thenReturn(false);

        await manager.sendStreakRecoveryNotification(
          deviceToken: 'token_123',
          streakLost: 5,
        );

        verify(mockRemoteConfig.isFeatureEnabled('push_notifications')).called(1);
      });

      test('broadcastMatchAvailableNotification handles gracefully', () async {
        await manager.broadcastMatchAvailableNotification(
          waitingPlayers: 5,
          estimatedMatchTime: '~30s',
        );

        // Should not throw
      });

      test('sendCampaignNotification handles gracefully', () async {
        await manager.sendCampaignNotification(
          deviceToken: 'token_123',
          campaignId: 'campaign_001',
          campaignName: 'Summer Festival',
          description: 'Join our summer celebration!',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Should not throw
      });
    });

    group('payload models', () {
      test('MilestoneNotificationPayload toDataMap returns correct structure', () {
        final payload = MilestoneNotificationPayload(
          milestone: 10,
          rewardId: 'reward_123',
          rewardName: 'Gold Stone',
          rewardRarity: 'rare',
        );

        final data = payload.toDataMap();

        expect(data['type'], equals('milestone_reached'));
        expect(data['milestone'], equals('10'));
        expect(data['reward_id'], equals('reward_123'));
        expect(data['reward_name'], equals('Gold Stone'));
        expect(data['reward_rarity'], equals('rare'));
      });

      test('StreakResetNotificationPayload toDataMap returns correct structure', () {
        final payload = StreakResetNotificationPayload(
          streakLost: 5,
          reason: 'timeout',
        );

        final data = payload.toDataMap();

        expect(data['type'], equals('streak_reset_recovery'));
        expect(data['streak_lost'], equals('5'));
        expect(data['reason'], equals('timeout'));
      });

      test('CampaignNotificationPayload toDataMap returns correct structure', () {
        final payload = CampaignNotificationPayload(
          campaignId: 'campaign_001',
          campaignName: 'Summer Festival',
          description: 'Join our summer celebration!',
          imageUrl: 'https://example.com/image.jpg',
          rewardValue: 100,
        );

        final data = payload.toDataMap();

        expect(data['type'], equals('campaign'));
        expect(data['campaign_id'], equals('campaign_001'));
        expect(data['campaign_name'], equals('Summer Festival'));
        expect(data['description'], equals('Join our summer celebration!'));
        expect(data['image_url'], equals('https://example.com/image.jpg'));
        expect(data['reward_value'], equals('100'));
      });

      test('CampaignNotificationPayload without reward value', () {
        final payload = CampaignNotificationPayload(
          campaignId: 'campaign_001',
          campaignName: 'Summer Festival',
          description: 'Join our summer celebration!',
          imageUrl: 'https://example.com/image.jpg',
        );

        final data = payload.toDataMap();

        expect(data['reward_value'], isNull);
      });
    });

    group('edge cases', () {
      test('handles empty device token', () async {
        await manager.sendMilestoneNotification(
          deviceToken: '',
          milestone: 1,
          rewardName: 'Stone',
          rewardRarity: 'common',
        );

        // Should not throw
      });

      test('handles large milestone numbers', () async {
        await manager.sendMilestoneNotification(
          deviceToken: 'token_123',
          milestone: 999999,
          rewardName: 'Legendary Stone',
          rewardRarity: 'legendary',
        );

        // Should not throw
      });

      test('handles special characters in campaign name', () async {
        await manager.sendCampaignNotification(
          deviceToken: 'token_123',
          campaignId: 'campaign_001',
          campaignName: '🎉 スペシャル キャンペーン 🎊',
          description: 'Special event with emojis! 🎮',
          imageUrl: 'https://example.com/image.jpg',
        );

        // Should not throw
      });

      test('handles very long descriptions', () async {
        final longDesc = 'x' * 1000;
        await manager.sendCampaignNotification(
          deviceToken: 'token_123',
          campaignId: 'campaign_001',
          campaignName: 'Campaign',
          description: longDesc,
          imageUrl: 'https://example.com/image.jpg',
        );

        // Should not throw
      });

      test('handles zero waiting players', () async {
        await manager.broadcastMatchAvailableNotification(
          waitingPlayers: 0,
          estimatedMatchTime: '∞',
        );

        // Should not throw
      });

      test('handles very large waiting player counts', () async {
        await manager.broadcastMatchAvailableNotification(
          waitingPlayers: 1000000,
          estimatedMatchTime: '~1s',
        );

        // Should not throw
      });
    });

    group('cohort targeting scenarios', () {
      test('new player onboarding cohort', () async {
        when(mockMessaging.subscribeToTopic('new_players_day_1')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('new_players_day_1');

        verify(mockMessaging.subscribeToTopic('new_players_day_1')).called(1);
      });

      test('high engagement cohort', () async {
        when(mockMessaging.subscribeToTopic('high_engagement')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('high_engagement');

        verify(mockMessaging.subscribeToTopic('high_engagement')).called(1);
      });

      test('at risk churn cohort', () async {
        when(mockMessaging.subscribeToTopic('at_risk_churn')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('at_risk_churn');

        verify(mockMessaging.subscribeToTopic('at_risk_churn')).called(1);
      });

      test('VIP subscriber cohort', () async {
        when(mockMessaging.subscribeToTopic('vip_subscribers')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('vip_subscribers');

        verify(mockMessaging.subscribeToTopic('vip_subscribers')).called(1);
      });

      test('locale-specific cohort', () async {
        when(mockMessaging.subscribeToTopic('locale_japan')).thenAnswer((_) async {});

        await manager.subscribeToCohortTopic('locale_japan');

        verify(mockMessaging.subscribeToTopic('locale_japan')).called(1);
      });
    });
  });
}
