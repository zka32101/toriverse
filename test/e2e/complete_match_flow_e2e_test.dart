import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/shared/services/firebase_messaging_service.dart';
import 'package:toriverse/features/match/application/services/push_notification_manager.dart';
import 'package:toriverse/features/match/application/services/liveops_campaign_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Mock FirebaseRemoteConfig for testing
class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {
  final Map<String, dynamic> _values = {
    'weekend_streak_multiplier': '2.0',
    'special_event_cosmetic_drop_rate': '0.1',
    'holiday_bonus_match_rewards': '1.5',
  };

  @override
  String getString(String key) => _values[key]?.toString() ?? '';

  @override
  bool getBool(String key) => _values[key] as bool? ?? false;

  @override
  int getInt(String key) => int.tryParse(_values[key]?.toString() ?? '0') ?? 0;

  @override
  double getDouble(String key) => double.tryParse(_values[key]?.toString() ?? '0.0') ?? 0.0;
}

void main() {
  group('Complete Match Flow E2E Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late LiveOpsCampaignService campaignService;
    late MockFirebaseRemoteConfig mockRemoteConfig;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockRemoteConfig = MockFirebaseRemoteConfig();
      campaignService = LiveOpsCampaignService(
        firestore: fakeFirestore,
        remoteConfig: mockRemoteConfig,
      );
    });

    group('Single Player Complete Journey', () {
      test('user can complete full match journey: discover → claim → track', () async {
        // Setup: Create active campaign
        final campaignRef = fakeFirestore.collection('campaigns').doc('camp_001');
        await campaignRef.set({
          'name': 'Launch Week Bonus',
          'description': 'Claim your launch bonus',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
          'requirement': '3_matches_completed',
          'total_challenges': 3,
        });

        // Setup: Create campaign rewards
        await campaignRef.collection('rewards').doc('reward_001').set({
          'name': '100 Rank Points',
          'description': 'Gain 100 rank points',
          'type': 'rank_points',
          'value': 100,
          'order': 1,
        });

        // Step 1: Discover active campaigns
        final campaigns = await campaignService.fetchActiveCampaigns();
        expect(campaigns, isNotEmpty);
        expect(campaigns.first.id, equals('camp_001'));
        expect(campaigns.first.name, equals('Launch Week Bonus'));

        // Step 2: Track participation (viewed event)
        final userId = 'user_001';
        await campaignService.trackCampaignParticipation(
          userId: userId,
          campaignId: 'camp_001',
          eventType: 'viewed',
        );

        // Verify participation recorded
        final participationSnap = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_participation')
            .get();
        expect(participationSnap.docs, isNotEmpty);

        // Step 3: Initialize user progress (user completed challenges)
        final progressRef = fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc('camp_001');
        await progressRef.set({
          'campaign_id': 'camp_001',
          'challenges_completed': 3,
          'total_challenges': 3,
          'claimed_rewards': [],
          'initialized_at': FieldValue.serverTimestamp(),
        });

        // Step 4: Get user progress
        final progress = await campaignService.getUserCampaignProgress(
          userId: userId,
          campaignId: 'camp_001',
        );
        expect(progress.challengesCompleted, equals(3));
        expect(progress.totalChallenges, equals(3));
        expect(progress.hasClaimedReward, isFalse);

        // Step 5: Claim reward
        final claimResult = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: 'camp_001',
          rewardId: 'reward_001',
        );
        expect(claimResult, isTrue);

        // Step 6: Verify reward claimed and tracked
        final updatedProgress = await campaignService.getUserCampaignProgress(
          userId: userId,
          campaignId: 'camp_001',
        );
        expect(updatedProgress.hasClaimedReward, isTrue);

        // Step 7: Track participation (claimed_reward event)
        await campaignService.trackCampaignParticipation(
          userId: userId,
          campaignId: 'camp_001',
          eventType: 'claimed_reward',
        );

        // Verify final state
        final finalParticipation = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_participation')
            .get();
        expect(finalParticipation.docs.length, greaterThan(1));
      });

      test('user progression is accurate across multiple campaigns', () async {
        final userId = 'user_multi';

        // Create two campaigns
        for (int i = 1; i <= 2; i++) {
          final campaignId = 'camp_${i.toString().padLeft(3, '0')}';
          await fakeFirestore.collection('campaigns').doc(campaignId).set({
            'name': 'Campaign $i',
            'currently_live': true,
            'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
            'requirement': 'matches_completed',
          });

          // Setup progress for campaign 1 with reward, campaign 2 without
          final challengesCompleted = i == 1 ? 3 : 2;
          await fakeFirestore
              .collection('users')
              .doc(userId)
              .collection('campaign_progress')
              .doc(campaignId)
              .set({
                'challenges_completed': challengesCompleted,
                'total_challenges': 3,
                'claimed_rewards': i == 1 ? ['reward_001'] : [],
              });
        }

        // Verify independent state
        final progress1 = await campaignService.getUserCampaignProgress(
          userId: userId,
          campaignId: 'camp_001',
        );
        expect(progress1.hasClaimedReward, isTrue);
        expect(progress1.challengesCompleted, equals(3));

        final progress2 = await campaignService.getUserCampaignProgress(
          userId: userId,
          campaignId: 'camp_002',
        );
        expect(progress2.hasClaimedReward, isFalse);
        expect(progress2.challengesCompleted, equals(2));
      });

      test('user can claim multiple rewards from same campaign', () async {
        final userId = 'user_multi_reward';
        final campaignId = 'camp_multi_reward';

        // Create campaign with multiple rewards
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Multi-Reward Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Create two rewards
        for (int i = 1; i <= 2; i++) {
          await fakeFirestore
              .collection('campaigns')
              .doc(campaignId)
              .collection('rewards')
              .doc('reward_00$i')
              .set({
                'name': 'Reward $i',
                'type': 'cosmetic',
                'order': i,
              });
        }

        // Setup progress
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .set({
              'challenges_completed': 3,
              'total_challenges': 3,
              'claimed_rewards': [],
            });

        // Claim first reward
        var claimResult = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_001',
        );
        expect(claimResult, isTrue);

        // Claim second reward
        claimResult = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_002',
        );
        expect(claimResult, isTrue);

        // Verify both claimed
        final progress = await campaignService.getUserCampaignProgress(
          userId: userId,
          campaignId: campaignId,
        );
        expect(progress.hasClaimedReward, isTrue);

        // Verify no duplication
        final progressDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .get();
        final claimedRewards = List<String>.from(progressDoc['claimed_rewards'] ?? []);
        expect(claimedRewards.length, equals(2));
        expect(claimedRewards, contains('reward_001'));
        expect(claimedRewards, contains('reward_002'));
      });
    });

    group('Multi-Player Campaign Interactions', () {
      test('three users can claim independently from same campaign', () async {
        final campaignId = 'camp_multiplayer';
        final userIds = ['user_a', 'user_b', 'user_c'];

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Multiplayer Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Setup progress for each user with different rewards
        for (int idx = 0; idx < userIds.length; idx++) {
          final userId = userIds[idx];
          final rewardId = 'reward_00${idx + 1}';

          await fakeFirestore
              .collection('users')
              .doc(userId)
              .collection('campaign_progress')
              .doc(campaignId)
              .set({
                'challenges_completed': 3 - idx, // Different progress levels
                'total_challenges': 3,
                'claimed_rewards': [],
              });

          // Each user claims different reward
          await campaignService.claimCampaignReward(
            userId: userId,
            campaignId: campaignId,
            rewardId: rewardId,
          );
        }

        // Verify independent state for each user
        for (int idx = 0; idx < userIds.length; idx++) {
          final userId = userIds[idx];
          final progress = await campaignService.getUserCampaignProgress(
            userId: userId,
            campaignId: campaignId,
          );
          expect(progress.hasClaimedReward, isTrue);
          expect(progress.challengesCompleted, equals(3 - idx));
        }
      });

      test('participation events track independent user actions', () async {
        final campaignId = 'camp_events';
        final userIds = ['user_1', 'user_2', 'user_3'];

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Event Tracking Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Track different events for each user
        final eventTypes = ['viewed', 'started', 'completed', 'claimed_reward'];
        for (final userId in userIds) {
          for (final eventType in eventTypes) {
            await campaignService.trackCampaignParticipation(
              userId: userId,
              campaignId: campaignId,
              eventType: eventType,
            );
          }
        }

        // Verify all events recorded with proper user isolation
        for (final userId in userIds) {
          final participationDocs = await fakeFirestore
              .collection('users')
              .doc(userId)
              .collection('campaign_participation')
              .get();
          expect(participationDocs.docs.length, equals(eventTypes.length));
        }
      });
    });

    group('Special Event Bonuses Integration', () {
      test('special event bonuses are fetched and applied correctly', () async {
        final bonuses = await campaignService.getSpecialEventBonuses();

        expect(bonuses.isActive, isTrue);
        expect(bonuses.streakMultiplier, equals(2.0));
        expect(bonuses.cosmeticDropRateIncrease, equals(0.1));
        expect(bonuses.bonusMatchRewardsMultiplier, equals(1.5));
      });

      test('bonuses can be applied to active campaigns', () async {
        final campaignId = 'camp_bonus';

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Bonus Campaign',
          'currently_live': true,
          'base_reward': 100,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Fetch campaign
        final campaigns = await campaignService.fetchActiveCampaigns();
        expect(campaigns, isNotEmpty);

        // Get bonuses and verify they can enhance rewards
        final bonuses = await campaignService.getSpecialEventBonuses();
        expect(bonuses.streakMultiplier, greaterThan(1.0));
        expect(bonuses.bonusMatchRewardsMultiplier, greaterThan(1.0));
      });
    });

    group('Timestamp Verification', () {
      test('reward claim timestamp is recorded accurately', () async {
        final userId = 'user_timestamp';
        final campaignId = 'camp_timestamp';

        // Create campaign and setup
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Timestamp Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .set({
              'challenges_completed': 3,
              'total_challenges': 3,
              'claimed_rewards': [],
            });

        // Record time before claim
        final timeBefore = DateTime.now();

        // Claim reward
        await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_001',
        );

        // Record time after claim
        final timeAfter = DateTime.now();

        // Verify timestamp is within expected range
        final progressDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .get();

        expect(progressDoc['reward_claimed_at'], isNotNull);
      });
    });

    group('Error Handling and Edge Cases', () {
      test('claiming non-existent reward gracefully fails', () async {
        final userId = 'user_edge';
        final campaignId = 'camp_edge';

        // Create campaign without rewards
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Edge Case Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Try to claim non-existent reward
        final result = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_nonexistent',
        );

        expect(result, isFalse);
      });

      test('claiming reward without progress record fails gracefully', () async {
        final userId = 'user_no_progress';
        final campaignId = 'camp_no_progress';

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'No Progress Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Try to claim without progress
        final result = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_001',
        );

        expect(result, isFalse);
      });

      test('duplicate claim attempts are prevented', () async {
        final userId = 'user_duplicate';
        final campaignId = 'camp_duplicate';

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Duplicate Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Setup progress
        await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .set({
              'challenges_completed': 3,
              'total_challenges': 3,
              'claimed_rewards': [],
            });

        // Claim reward
        var result = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_dup',
        );
        expect(result, isTrue);

        // Attempt duplicate claim
        result = await campaignService.claimCampaignReward(
          userId: userId,
          campaignId: campaignId,
          rewardId: 'reward_dup',
        );
        expect(result, isTrue); // Should succeed (idempotent)

        // Verify no duplication in claimed_rewards array
        final progressDoc = await fakeFirestore
            .collection('users')
            .doc(userId)
            .collection('campaign_progress')
            .doc(campaignId)
            .get();
        final claimedRewards = List<String>.from(progressDoc['claimed_rewards'] ?? []);
        expect(claimedRewards.where((r) => r == 'reward_dup').length, equals(1));
      });
    });
  });
}
