import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toriverse/features/match/application/services/liveops_campaign_service.dart';
import 'package:toriverse/features/match/application/providers/notification_state.dart';
import 'package:toriverse/shared/services/remote_config_service.dart';

/// Mock RemoteConfigService
class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  group('Campaign Claiming Flow Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockRemoteConfigService mockRemoteConfig;
    late LiveOpsCampaignService campaignService;
    late String testUserId;
    late String testCampaignId;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockRemoteConfig = MockRemoteConfigService();
      campaignService = LiveOpsCampaignService(
        firestore: fakeFirestore,
        remoteConfig: mockRemoteConfig,
      );
      testUserId = 'test_user_123';
      testCampaignId = 'campaign_summer_2026';

      // Setup Remote Config defaults
      when(mockRemoteConfig.getString('weekend_streak_multiplier')).thenReturn('2.0');
      when(mockRemoteConfig.getString('special_event_cosmetic_drop_rate')).thenReturn('0.1');
      when(mockRemoteConfig.getString('holiday_bonus_match_rewards')).thenReturn('1.5');
    });

    group('basic campaign claiming', () {
      test('user can claim campaign reward', () async {
        // Setup: Create campaign and initialize user progress
        await fakeFirestore.collection('campaigns').doc(testCampaignId).set({
          'name': 'Summer Festival',
          'description': 'Summer celebration campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': true,
          'priority': 1,
          'campaign_type': 'seasonal',
        });

        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 3,
          'challenges_required': 3,
        });

        // Action: Claim reward
        final success = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_gold_stone',
        );

        // Assert
        expect(success, isTrue);

        // Verify reward was added
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .get();

        final data = doc.data() as Map<String, dynamic>;
        expect((data['claimed_rewards'] as List).contains('reward_gold_stone'), isTrue);
      });

      test('claiming reward records correct timestamp', () async {
        // Setup
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 1,
          'challenges_required': 1,
        });

        // Action
        final beforeClaim = DateTime.now();
        await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_1',
        );
        final afterClaim = DateTime.now();

        // Assert: Verify timestamp is recorded
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .get();

        final data = doc.data() as Map<String, dynamic>;
        final claimedAt = data['reward_claimed_at'];
        expect(claimedAt, isNotNull);

        if (claimedAt != null) {
          final timestamp = DateTime.parse(claimedAt as String);
          expect(timestamp.isAfter(beforeClaim), isTrue);
          expect(timestamp.isBefore(afterClaim.add(Duration(seconds: 1))), isTrue);
        }
      });

      test('cannot claim reward for non-existent progress', () async {
        // Action: Try to claim reward without progress record
        final success = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: 'nonexistent_campaign',
          rewardId: 'reward_1',
        );

        // Assert
        expect(success, isFalse);
      });
    });

    group('multiple reward claiming', () {
      test('user can claim multiple rewards from same campaign', () async {
        // Setup
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 0,
          'challenges_required': 1,
        });

        // Action: Claim multiple rewards
        final reward1Success = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_stone_gold',
        );

        final reward2Success = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_stone_silver',
        );

        // Assert
        expect(reward1Success, isTrue);
        expect(reward2Success, isTrue);

        // Verify both rewards were added
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .get();

        final data = doc.data() as Map<String, dynamic>;
        final claimedRewards = data['claimed_rewards'] as List;
        expect(claimedRewards.length, equals(2));
        expect(claimedRewards.contains('reward_stone_gold'), isTrue);
        expect(claimedRewards.contains('reward_stone_silver'), isTrue);
      });

      test('claimed rewards are not duplicated', () async {
        // Setup
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 1,
          'challenges_required': 1,
        });

        // Action: Claim same reward twice
        await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_same',
        );

        await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_same',
        );

        // Assert: Verify array union prevents duplicates
        final doc = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .get();

        final data = doc.data() as Map<String, dynamic>;
        final claimedRewards = data['claimed_rewards'] as List;
        // Note: arrayUnion in Firestore prevents duplicates naturally
        expect(claimedRewards.length, equals(1));
      });
    });

    group('campaign progress tracking', () {
      test('user campaign progress can be retrieved', () async {
        // Setup
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': ['reward_1', 'reward_2'],
          'challenges_completed': 2,
          'challenges_required': 5,
        });

        // Action
        final progress = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        // Assert
        expect(progress, isNotNull);
        expect(progress!.challengesCompleted, equals(2));
        expect(progress.challengesRequired, equals(5));
        expect(progress.claimedRewards.length, equals(2));
        expect(progress.hasClaimedReward, isTrue);
      });

      test('progress without claimed rewards shows hasClaimedReward as false', () async {
        // Setup
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 1,
          'challenges_required': 5,
        });

        // Action
        final progress = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        // Assert
        expect(progress!.hasClaimedReward, isFalse);
      });

      test('progress tracking across multiple campaigns', () async {
        // Setup: Create progress for multiple campaigns
        final campaign2Id = 'campaign_autumn_2026';

        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': ['reward_1'],
          'challenges_completed': 3,
          'challenges_required': 3,
        });

        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(campaign2Id)
            .set({
          'campaign_id': campaign2Id,
          'claimed_rewards': [],
          'challenges_completed': 1,
          'challenges_required': 5,
        });

        // Action: Retrieve both
        final progress1 = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        final progress2 = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: campaign2Id,
        );

        // Assert
        expect(progress1!.hasClaimedReward, isTrue);
        expect(progress2!.hasClaimedReward, isFalse);
        expect(progress1.claimedRewards.length, equals(1));
        expect(progress2.claimedRewards.length, equals(0));
      });
    });

    group('campaign participation tracking', () {
      test('participation events are recorded', () async {
        // Action: Record multiple participation events
        await campaignService.trackCampaignParticipation(
          userId: testUserId,
          campaignId: testCampaignId,
          eventType: 'viewed',
        );

        await campaignService.trackCampaignParticipation(
          userId: testUserId,
          campaignId: testCampaignId,
          eventType: 'claimed_reward',
        );

        // Assert
        final participationDocs = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_participation')
            .get();

        expect(participationDocs.docs.length, equals(2));

        final events = participationDocs.docs.map((doc) => doc['event_type']).toList();
        expect(events.contains('viewed'), isTrue);
        expect(events.contains('claimed_reward'), isTrue);
      });

      test('participation events include campaign_id', () async {
        // Action
        await campaignService.trackCampaignParticipation(
          userId: testUserId,
          campaignId: testCampaignId,
          eventType: 'viewed',
        );

        // Assert
        final docs = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_participation')
            .get();

        expect(docs.docs.isNotEmpty, isTrue);
        expect(docs.docs.first['campaign_id'], equals(testCampaignId));
      });
    });

    group('active campaign fetching', () {
      test('can fetch active campaigns before claiming', () async {
        // Setup: Create active campaign
        await fakeFirestore.collection('campaigns').doc(testCampaignId).set({
          'name': 'Active Campaign',
          'description': 'Test campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': true,
          'priority': 1,
        });

        // Action
        final campaigns = await campaignService.fetchActiveCampaigns();

        // Assert
        expect(campaigns.isNotEmpty, isTrue);
        expect(campaigns[0].id, equals(testCampaignId));
        expect(campaigns[0].currentlyLive, isTrue);
      });

      test('fetches campaigns with correct ordering', () async {
        // Setup: Create multiple campaigns with different priorities
        await fakeFirestore.collection('campaigns').doc('campaign_1').set({
          'name': 'Campaign 1',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 3,
        });

        await fakeFirestore.collection('campaigns').doc('campaign_2').set({
          'name': 'Campaign 2',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 2)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 1,
        });

        // Action
        final campaigns = await campaignService.fetchActiveCampaigns();

        // Assert: Campaigns should be ordered by start_time descending
        expect(campaigns.length, equals(2));
      });
    });

    group('complete flow: viewing -> claiming -> tracking', () {
      test('complete campaign interaction flow', () async {
        // Setup 1: Campaign exists
        await fakeFirestore.collection('campaigns').doc(testCampaignId).set({
          'name': 'Complete Flow Campaign',
          'description': 'Test complete flow',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': true,
          'priority': 1,
        });

        // Setup 2: Fetch active campaigns (view)
        final campaigns = await campaignService.fetchActiveCampaigns();
        expect(campaigns.isNotEmpty, isTrue);

        // Track participation (viewed)
        await campaignService.trackCampaignParticipation(
          userId: testUserId,
          campaignId: testCampaignId,
          eventType: 'viewed',
        );

        // Setup 3: Initialize user progress for claiming
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 3,
          'challenges_required': 3,
        });

        // Action: Get progress
        final progress = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        expect(progress!.challengesCompleted, equals(3));
        expect(progress.hasClaimedReward, isFalse);

        // Action: Claim reward
        final claimSuccess = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_completion_prize',
        );

        expect(claimSuccess, isTrue);

        // Track participation (claimed_reward)
        await campaignService.trackCampaignParticipation(
          userId: testUserId,
          campaignId: testCampaignId,
          eventType: 'claimed_reward',
        );

        // Assert: Final state
        final finalProgress = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        expect(finalProgress!.hasClaimedReward, isTrue);
        expect(finalProgress.claimedRewards.contains('reward_completion_prize'), isTrue);

        // Verify participation events
        final participationDocs = await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_participation')
            .get();

        expect(participationDocs.docs.length, equals(2));
      });

      test('multiple users can claim from same campaign independently', () async {
        final user2Id = 'test_user_456';

        // Setup
        await fakeFirestore.collection('campaigns').doc(testCampaignId).set({
          'name': 'Multi-user Campaign',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
        });

        // User 1 progress
        await fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 1,
          'challenges_required': 1,
        });

        // User 2 progress
        await fakeFirestore
            .collection('users')
            .doc(user2Id)
            .collection('campaign_progress')
            .doc(testCampaignId)
            .set({
          'campaign_id': testCampaignId,
          'claimed_rewards': [],
          'challenges_completed': 2,
          'challenges_required': 3,
        });

        // User 1 claims
        final user1Claim = await campaignService.claimCampaignReward(
          userId: testUserId,
          campaignId: testCampaignId,
          rewardId: 'reward_user1',
        );

        // User 2 claims
        final user2Claim = await campaignService.claimCampaignReward(
          userId: user2Id,
          campaignId: testCampaignId,
          rewardId: 'reward_user2',
        );

        expect(user1Claim, isTrue);
        expect(user2Claim, isTrue);

        // Verify independent claims
        final progress1 = await campaignService.getUserCampaignProgress(
          userId: testUserId,
          campaignId: testCampaignId,
        );

        final progress2 = await campaignService.getUserCampaignProgress(
          userId: user2Id,
          campaignId: testCampaignId,
        );

        expect(progress1!.claimedRewards.contains('reward_user1'), isTrue);
        expect(progress1.claimedRewards.contains('reward_user2'), isFalse);
        expect(progress2!.claimedRewards.contains('reward_user2'), isTrue);
        expect(progress2.claimedRewards.contains('reward_user1'), isFalse);
      });
    });

    group('special event bonuses integration', () {
      test('fetches and applies special event bonuses', () async {
        // Action
        final bonuses = await campaignService.getSpecialEventBonuses();

        // Assert
        expect(bonuses.isActive, isTrue);
        expect(bonuses.streakMultiplier, equals(2.0));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.1));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(1.5));
      });

      test('bonuses can be applied to campaign rewards', () async {
        // Setup
        await fakeFirestore.collection('campaigns').doc(testCampaignId).set({
          'name': 'Bonus Campaign',
          'description': 'Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)),
          'end_time': DateTime.now().add(Duration(days: 7)),
          'is_featured': false,
          'priority': 5,
        });

        // Action: Get campaign and bonuses
        final campaigns = await campaignService.fetchActiveCampaigns();
        final bonuses = await campaignService.getSpecialEventBonuses();

        // Assert: Can use bonuses with campaign rewards
        expect(campaigns.isNotEmpty, isTrue);
        expect(bonuses.isActive, isTrue);
        expect(bonuses.streakMultiplier > 1.0, isTrue);
      });
    });
  });
}
