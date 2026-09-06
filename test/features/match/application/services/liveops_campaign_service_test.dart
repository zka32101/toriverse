import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:toriverse/features/match/application/services/liveops_campaign_service.dart';
import 'package:toriverse/shared/services/remote_config_service.dart';

// Mock classes
class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('LiveOpsCampaignService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockRemoteConfigService mockRemoteConfig;
    late LiveOpsCampaignService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockRemoteConfig = MockRemoteConfigService();

      service = LiveOpsCampaignService(
        firestore: fakeFirestore,
        remoteConfig: mockRemoteConfig,
      );
    });

    group('campaign fetching', () {
      test('fetchActiveCampaigns returns live campaigns', () async {
        // Add test data
        await fakeFirestore.collection('campaigns').add({
          'name': 'Summer Festival',
          'description': 'Join our summer celebration!',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
          'campaign_type': 'seasonal',
        });

        await fakeFirestore.collection('campaigns').add({
          'name': 'Winter Sale',
          'description': 'Winter discount event',
          'currently_live': false,
          'start_time': DateTime.now().subtract(Duration(days: 30)),
          'end_time': DateTime.now().subtract(Duration(days: 10)),
          'is_featured': false,
          'priority': 10,
          'campaign_type': 'promotional',
        });

        final campaigns = await service.fetchActiveCampaigns();

        // Should only return currently_live campaigns
        expect(campaigns.length, equals(1));
        expect(campaigns[0].name, equals('Summer Festival'));
        expect(campaigns[0].currentlyLive, isTrue);
      });

      test('fetchActiveCampaigns returns empty on no live campaigns', () async {
        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns, isEmpty);
      });

      test('fetchActiveCampaigns handles network error', () async {
        // Network errors are caught silently
        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns, isEmpty);
      });

      test('fetchFeaturedCampaign returns highest priority featured campaign', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': 'Featured Summer',
          'description': 'Featured summer event',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': true,
          'priority': 1,
          'campaign_type': 'seasonal',
          'banner_image_url': 'https://example.com/summer.jpg',
        });

        await fakeFirestore.collection('campaigns').add({
          'name': 'Regular Campaign',
          'description': 'Regular campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
          'campaign_type': 'promotional',
        });

        final featured = await service.fetchFeaturedCampaign();

        expect(featured, isNotNull);
        expect(featured!.name, equals('Featured Summer'));
        expect(featured.isFeatured, isTrue);
      });

      test('fetchFeaturedCampaign returns null when no featured campaign', () async {
        final featured = await service.fetchFeaturedCampaign();

        expect(featured, isNull);
      });
    });

    group('campaign streaming', () {
      test('streamActiveCampaigns returns live campaigns as stream', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': 'Active Campaign',
          'description': 'Active campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
          'campaign_type': 'seasonal',
        });

        final stream = service.streamActiveCampaigns();
        final campaigns = await stream.first;

        expect(campaigns.length, greaterThanOrEqualTo(1));
      });

      test('streamActiveCampaigns handles error gracefully', () async {
        // Even with errors, stream should emit empty list
        final stream = service.streamActiveCampaigns();
        final campaigns = await stream.first;

        expect(campaigns, isA<List<Campaign>>());
      });
    });

    group('campaign rewards', () {
      test('fetchCampaignRewards returns rewards for campaign', () async {
        // Create campaign
        final campaignDoc = await fakeFirestore.collection('campaigns').add({
          'name': 'Test Campaign',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now(),
          'end_time': DateTime.now().add(Duration(days: 1)),
          'is_featured': false,
          'priority': 5,
        });

        // Add rewards
        await campaignDoc.collection('rewards').add({
          'campaign_id': campaignDoc.id,
          'reward_type': 'cosmetic',
          'reward_id': 'stone_gold',
          'description': 'Gold Stone cosmetic',
          'quantity': 1,
        });

        final rewards = await service.fetchCampaignRewards(campaignDoc.id);

        expect(rewards.length, equals(1));
        expect(rewards[0].rewardType, equals('cosmetic'));
        expect(rewards[0].rewardId, equals('stone_gold'));
      });

      test('fetchCampaignRewards returns empty when no rewards', () async {
        final campaignDoc = await fakeFirestore.collection('campaigns').add({
          'name': 'No Rewards Campaign',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now(),
          'end_time': DateTime.now().add(Duration(days: 1)),
          'is_featured': false,
          'priority': 5,
        });

        final rewards = await service.fetchCampaignRewards(campaignDoc.id);

        expect(rewards, isEmpty);
      });

      test('fetchCampaignRewards handles network error', () async {
        final rewards = await service.fetchCampaignRewards('nonexistent_id');

        expect(rewards, isEmpty);
      });
    });

    group('campaign participation tracking', () {
      test('trackCampaignParticipation records participation event', () async {
        await service.trackCampaignParticipation(
          userId: 'user_123',
          campaignId: 'campaign_001',
          eventType: 'viewed',
        );

        // Verify document was created
        final participationRef = await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_participation')
            .get();

        expect(participationRef.docs, isNotEmpty);
      });

      test('trackCampaignParticipation handles different event types', () async {
        const eventTypes = ['viewed', 'claimed_reward', 'completed_challenge'];

        for (final eventType in eventTypes) {
          await service.trackCampaignParticipation(
            userId: 'user_123',
            campaignId: 'campaign_001',
            eventType: eventType,
          );
        }

        final participation = await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_participation')
            .get();

        expect(participation.docs.length, equals(3));
      });

      test('trackCampaignParticipation handles error silently', () async {
        // Should not throw
        await service.trackCampaignParticipation(
          userId: 'user_123',
          campaignId: 'campaign_001',
          eventType: 'viewed',
        );
      });
    });

    group('user campaign progress', () {
      test('getUserCampaignProgress returns progress when exists', () async {
        await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_progress')
            .doc('campaign_001')
            .set({
          'campaign_id': 'campaign_001',
          'claimed_rewards': ['reward_1', 'reward_2'],
          'reward_claimed_at': DateTime.now().toIso8601String(),
          'challenges_completed': 3,
          'challenges_required': 5,
        });

        final progress = await service.getUserCampaignProgress(
          userId: 'user_123',
          campaignId: 'campaign_001',
        );

        expect(progress, isNotNull);
        expect(progress!.challengesCompleted, equals(3));
        expect(progress.claimedRewards.length, equals(2));
      });

      test('getUserCampaignProgress returns null when not exists', () async {
        final progress = await service.getUserCampaignProgress(
          userId: 'user_123',
          campaignId: 'nonexistent_campaign',
        );

        expect(progress, isNull);
      });

      test('getUserCampaignProgress handles error', () async {
        final progress = await service.getUserCampaignProgress(
          userId: 'user_123',
          campaignId: 'campaign_001',
        );

        expect(progress, isNull);
      });
    });

    group('reward claiming', () {
      test('claimCampaignReward updates progress successfully', () async {
        await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_progress')
            .doc('campaign_001')
            .set({
          'campaign_id': 'campaign_001',
          'claimed_rewards': [],
          'challenges_completed': 0,
          'challenges_required': 1,
        });

        final success = await service.claimCampaignReward(
          userId: 'user_123',
          campaignId: 'campaign_001',
          rewardId: 'reward_123',
        );

        expect(success, isTrue);

        // Verify reward was added
        final doc = await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_progress')
            .doc('campaign_001')
            .get();

        final data = doc.data() as Map<String, dynamic>;
        expect(data['claimed_rewards'], contains('reward_123'));
      });

      test('claimCampaignReward handles non-existent progress', () async {
        final success = await service.claimCampaignReward(
          userId: 'user_123',
          campaignId: 'nonexistent',
          rewardId: 'reward_123',
        );

        expect(success, isFalse);
      });

      test('claimCampaignReward can be called multiple times', () async {
        await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_progress')
            .doc('campaign_001')
            .set({
          'campaign_id': 'campaign_001',
          'claimed_rewards': [],
          'challenges_completed': 0,
          'challenges_required': 1,
        });

        await service.claimCampaignReward(
          userId: 'user_123',
          campaignId: 'campaign_001',
          rewardId: 'reward_1',
        );

        final success = await service.claimCampaignReward(
          userId: 'user_123',
          campaignId: 'campaign_001',
          rewardId: 'reward_2',
        );

        expect(success, isTrue);

        final doc = await fakeFirestore
            .collection('users')
            .doc('user_123')
            .collection('campaign_progress')
            .doc('campaign_001')
            .get();

        final data = doc.data() as Map<String, dynamic>;
        expect((data['claimed_rewards'] as List).length, equals(2));
      });
    });

    group('special event bonuses', () {
      test('getSpecialEventBonuses returns bonuses from Remote Config', () async {
        when(mockRemoteConfig.getString('weekend_streak_multiplier')).thenReturn('2.0');
        when(mockRemoteConfig.getString('special_event_cosmetic_drop_rate')).thenReturn('0.1');
        when(mockRemoteConfig.getString('holiday_bonus_match_rewards')).thenReturn('1.5');

        final bonuses = await service.getSpecialEventBonuses();

        expect(bonuses.streakMultiplier, equals(2.0));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.1));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(1.5));
        expect(bonuses.isActive, isTrue);
      });

      test('getSpecialEventBonuses returns defaults on error', () async {
        when(mockRemoteConfig.getString('weekend_streak_multiplier')).thenThrow(Exception());
        when(mockRemoteConfig.getString('special_event_cosmetic_drop_rate')).thenThrow(Exception());
        when(mockRemoteConfig.getString('holiday_bonus_match_rewards')).thenThrow(Exception());

        final bonuses = await service.getSpecialEventBonuses();

        expect(bonuses.streakMultiplier, equals(1.0));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.0));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(1.0));
        expect(bonuses.isActive, isFalse);
      });

      test('getSpecialEventBonuses parses numeric strings correctly', () async {
        when(mockRemoteConfig.getString('weekend_streak_multiplier')).thenReturn('3.5');
        when(mockRemoteConfig.getString('special_event_cosmetic_drop_rate')).thenReturn('0.25');
        when(mockRemoteConfig.getString('holiday_bonus_match_rewards')).thenReturn('2.0');

        final bonuses = await service.getSpecialEventBonuses();

        expect(bonuses.streakMultiplier, equals(3.5));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.25));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(2.0));
      });

      test('getSpecialEventBonuses handles invalid numeric strings', () async {
        when(mockRemoteConfig.getString('weekend_streak_multiplier')).thenReturn('invalid');
        when(mockRemoteConfig.getString('special_event_cosmetic_drop_rate')).thenReturn('also_invalid');
        when(mockRemoteConfig.getString('holiday_bonus_match_rewards')).thenReturn('not_a_number');

        final bonuses = await service.getSpecialEventBonuses();

        expect(bonuses.streakMultiplier, equals(1.0));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.0));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(1.0));
      });
    });

    group('campaign models', () {
      test('Campaign.isActive returns correct status', () {
        final activeCampaign = Campaign(
          id: 'campaign_1',
          name: 'Active',
          description: 'Active campaign',
          startTime: DateTime.now().subtract(Duration(days: 1)),
          endTime: DateTime.now().add(Duration(days: 1)),
          currentlyLive: true,
          isFeatured: false,
          priority: 5,
        );

        expect(activeCampaign.isActive, isTrue);
      });

      test('Campaign.isActive returns false when not currentlyLive', () {
        final inactiveCampaign = Campaign(
          id: 'campaign_1',
          name: 'Inactive',
          description: 'Inactive campaign',
          startTime: DateTime.now().subtract(Duration(days: 1)),
          endTime: DateTime.now().add(Duration(days: 1)),
          currentlyLive: false,
          isFeatured: false,
          priority: 5,
        );

        expect(inactiveCampaign.isActive, isFalse);
      });

      test('Campaign.isActive returns false when ended', () {
        final endedCampaign = Campaign(
          id: 'campaign_1',
          name: 'Ended',
          description: 'Ended campaign',
          startTime: DateTime.now().subtract(Duration(days: 2)),
          endTime: DateTime.now().subtract(Duration(days: 1)),
          currentlyLive: true,
          isFeatured: false,
          priority: 5,
        );

        expect(endedCampaign.isActive, isFalse);
      });

      test('CampaignProgress.hasClaimedReward returns true when rewards claimed', () {
        final progress = CampaignProgress(
          campaignId: 'campaign_1',
          claimedRewards: ['reward_1'],
          challengesCompleted: 1,
          challengesRequired: 1,
        );

        expect(progress.hasClaimedReward, isTrue);
      });

      test('CampaignProgress.hasClaimedReward returns false when no rewards', () {
        final progress = CampaignProgress(
          campaignId: 'campaign_1',
          claimedRewards: [],
          challengesCompleted: 0,
          challengesRequired: 1,
        );

        expect(progress.hasClaimedReward, isFalse);
      });
    });

    group('edge cases', () {
      test('handles empty campaign name', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': '',
          'description': 'No name campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
        });

        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns.length, equals(1));
        expect(campaigns[0].name, equals(''));
      });

      test('handles special characters in campaign name', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': '🎉 スペシャル キャンペーン 🎊',
          'description': 'Special event',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
        });

        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns.length, equals(1));
        expect(campaigns[0].name, contains('スペシャル'));
      });

      test('handles very large priority numbers', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': 'High Priority',
          'description': 'High priority campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 999999,
        });

        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns.length, equals(1));
      });

      test('handles campaigns with null optional fields', () async {
        await fakeFirestore.collection('campaigns').add({
          'name': 'Minimal Campaign',
          'description': 'Minimal data',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
          // banner_image_url and campaign_type are null
        });

        final campaigns = await service.fetchActiveCampaigns();

        expect(campaigns.length, equals(1));
        expect(campaigns[0].bannerImageUrl, isNull);
        expect(campaigns[0].campaignType, isNull);
      });
    });
  });
}
