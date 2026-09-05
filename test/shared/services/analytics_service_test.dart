import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/shared/services/analytics_service.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  group('AnalyticsService', () {
    late AnalyticsService analytics;
    late MockFirebaseAnalytics mockFirebaseAnalytics;

    setUp(() {
      mockFirebaseAnalytics = MockFirebaseAnalytics();
      analytics = AnalyticsService(analytics: mockFirebaseAnalytics);
    });

    group('logMatchCompleted', () {
      test('Logs match completion with result and streak', () async {
        await analytics.logMatchCompleted(
          matchId: 'match_001',
          result: 'win',
          currentStreak: 5,
          matchDurationSeconds: 180,
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'match_completed',
          parameters: any,
        )).called(1);
      });

      test('Includes match ID in parameters', () async {
        await analytics.logMatchCompleted(
          matchId: 'match_test_123',
          result: 'loss',
          currentStreak: 3,
          matchDurationSeconds: 120,
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'match_completed',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        expect((captured[0] as Map)['match_id'], 'match_test_123');
      });

      test('Logs different results correctly', () async {
        for (final result in ['win', 'loss', 'draw']) {
          await analytics.logMatchCompleted(
            matchId: 'match_$result',
            result: result,
            currentStreak: 1,
            matchDurationSeconds: 60,
          );
        }

        verify(mockFirebaseAnalytics.logEvent(
          name: 'match_completed',
          parameters: any,
        )).called(3);
      });
    });

    group('logMilestoneReached', () {
      test('Fires event when milestone is reached', () async {
        await analytics.logMilestoneReached(
          milestone: 10,
          cosmeticRewardId: 'board_obsidian',
          cosmeticRarity: 'legendary',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'milestone_reached',
          parameters: any,
        )).called(1);
      });

      test('Includes milestone level in parameters', () async {
        await analytics.logMilestoneReached(
          milestone: 25,
          cosmeticRewardId: 'stone_golden',
          cosmeticRarity: 'rare',
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'milestone_reached',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        expect((captured[0] as Map)['milestone_level'], 25);
      });

      test('Logs major milestones correctly', () async {
        final milestones = [3, 5, 10, 25, 50, 100];

        for (final milestone in milestones) {
          await analytics.logMilestoneReached(
            milestone: milestone,
            cosmeticRewardId: 'reward_$milestone',
            cosmeticRarity: 'rare',
          );
        }

        verify(mockFirebaseAnalytics.logEvent(
          name: 'milestone_reached',
          parameters: any,
        )).called(milestones.length);
      });

      test('Handles null cosmetic reward', () async {
        await analytics.logMilestoneReached(
          milestone: 5,
          cosmeticRewardId: null,
          cosmeticRarity: 'none',
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'milestone_reached',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        expect((captured[0] as Map)['reward_cosmetic_id'], 'none');
      });
    });

    group('logCosmeticActivated', () {
      test('Logs when player activates cosmetic', () async {
        await analytics.logCosmeticActivated(
          cosmeticId: 'board_marble',
          cosmeticType: 'board',
          rarity: 'rare',
          source: 'shop_purchase',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'cosmetic_activated',
          parameters: any,
        )).called(1);
      });

      test('Includes cosmetic details in parameters', () async {
        await analytics.logCosmeticActivated(
          cosmeticId: 'stone_golden',
          cosmeticType: 'stone',
          rarity: 'legendary',
          source: 'milestone_reward',
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'cosmetic_activated',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        final params = captured[0] as Map;
        expect(params['cosmetic_id'], 'stone_golden');
        expect(params['cosmetic_type'], 'stone');
        expect(params['rarity'], 'legendary');
        expect(params['source'], 'milestone_reward');
      });
    });

    group('logCosmeticPurchased', () {
      test('Logs cosmetic purchase event', () async {
        await analytics.logCosmeticPurchased(
          cosmeticId: 'board_obsidian',
          cosmeticType: 'board',
          rarity: 'legendary',
          priceYen: 500,
          paymentMethod: 'credit_card',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'cosmetic_purchased',
          parameters: any,
        )).called(1);
      });

      test('Includes price and payment method', () async {
        await analytics.logCosmeticPurchased(
          cosmeticId: 'stone_crystal',
          cosmeticType: 'stone',
          rarity: 'uncommon',
          priceYen: 150,
          paymentMethod: 'apple_pay',
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'cosmetic_purchased',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        final params = captured[0] as Map;
        expect(params['price_yen'], 150);
        expect(params['payment_method'], 'apple_pay');
      });

      test('Logs different payment methods', () async {
        final methods = ['credit_card', 'apple_pay', 'google_pay'];

        for (final method in methods) {
          await analytics.logCosmeticPurchased(
            cosmeticId: 'test_$method',
            cosmeticType: 'board',
            rarity: 'common',
            priceYen: 100,
            paymentMethod: method,
          );
        }

        verify(mockFirebaseAnalytics.logEvent(
          name: 'cosmetic_purchased',
          parameters: any,
        )).called(methods.length);
      });
    });

    group('logStreakReset', () {
      test('Logs streak loss when streak breaks', () async {
        await analytics.logStreakReset(
          lostStreakCount: 10,
          reason: 'match_loss',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'streak_reset',
          parameters: any,
        )).called(1);
      });

      test('Includes lost streak count and reason', () async {
        await analytics.logStreakReset(
          lostStreakCount: 25,
          reason: 'connection_timeout',
        );

        final captured = verify(mockFirebaseAnalytics.logEvent(
          name: 'streak_reset',
          parameters: captureAnyNamed('parameters'),
        )).captured;

        final params = captured[0] as Map;
        expect(params['lost_streak'], 25);
        expect(params['reason'], 'connection_timeout');
      });

      test('Logs all reset reasons', () async {
        final reasons = ['manual_quit', 'connection_timeout', 'match_loss'];

        for (final reason in reasons) {
          await analytics.logStreakReset(
            lostStreakCount: 5,
            reason: reason,
          );
        }

        verify(mockFirebaseAnalytics.logEvent(
          name: 'streak_reset',
          parameters: any,
        )).called(reasons.length);
      });
    });

    group('logRankPassPurchased', () {
      test('Logs season pass purchase', () async {
        await analytics.logRankPassPurchased(
          priceYen: 300,
          seasonId: 'season_1',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'rankpass_purchased',
          parameters: any,
        )).called(1);
      });
    });

    group('logClipShared', () {
      test('Logs clip share to social platform', () async {
        await analytics.logClipShared(
          clipId: 'clip_abc123',
          platform: 'twitter',
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'clip_shared',
          parameters: any,
        )).called(1);
      });

      test('Logs different social platforms', () async {
        final platforms = ['twitter', 'tiktok', 'instagram', 'line'];

        for (final platform in platforms) {
          await analytics.logClipShared(
            clipId: 'clip_$platform',
            platform: platform,
          );
        }

        verify(mockFirebaseAnalytics.logEvent(
          name: 'clip_shared',
          parameters: any,
        )).called(platforms.length);
      });
    });

    group('logBonusActivated', () {
      test('Logs weak bonus activation', () async {
        await analytics.logBonusActivated(
          bonusType: 'weak_bonus',
          effectValue: 2,
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'bonus_activated',
          parameters: any,
        )).called(1);
      });

      test('Logs rescue card activation', () async {
        await analytics.logBonusActivated(
          bonusType: 'rescue_card',
          effectValue: 1,
        );

        verify(mockFirebaseAnalytics.logEvent(
          name: 'bonus_activated',
          parameters: any,
        )).called(1);
      });
    });

    group('setUserProperties', () {
      test('Sets user ID and properties', () async {
        await analytics.setUserProperties(
          userId: 'user_12345',
          accountAgeMinutes: 1440, // 1 day
          totalMatchesPlayed: 10,
          isPaidSubscriber: false,
        );

        verify(mockFirebaseAnalytics.setUserId('user_12345')).called(1);
      });

      test('Sets all user properties', () async {
        await analytics.setUserProperties(
          userId: 'user_abc',
          accountAgeMinutes: 7200,
          totalMatchesPlayed: 50,
          isPaidSubscriber: true,
        );

        verify(mockFirebaseAnalytics.setUserProperty(
          name: 'account_age_minutes',
          value: any,
        )).called(1);
        verify(mockFirebaseAnalytics.setUserProperty(
          name: 'total_matches',
          value: any,
        )).called(1);
        verify(mockFirebaseAnalytics.setUserProperty(
          name: 'paid_subscriber',
          value: 'true',
        )).called(1);
      });
    });

    group('Error handling', () {
      test('Silently handles event logging errors', () async {
        when(mockFirebaseAnalytics.logEvent(
          name: any,
          parameters: any,
        )).thenThrow(Exception('Firebase unavailable'));

        // Should not throw
        await analytics.logMilestoneReached(
          milestone: 10,
          cosmeticRewardId: 'reward',
          cosmeticRarity: 'rare',
        );

        expect(true, isTrue);
      });

      test('Silently handles user property errors', () async {
        when(mockFirebaseAnalytics.setUserId(any))
            .thenThrow(Exception('Firebase error'));

        // Should not throw
        await analytics.setUserProperties(
          userId: 'user',
          accountAgeMinutes: 100,
          totalMatchesPlayed: 5,
          isPaidSubscriber: false,
        );

        expect(true, isTrue);
      });
    });
  });
}
