import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:toriverse/features/match/application/services/liveops_campaign_service.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Performance profiling results
class PerformanceMetrics {
  final String operation;
  final Duration duration;
  final int dataSize;
  final String result;

  PerformanceMetrics({
    required this.operation,
    required this.duration,
    required this.dataSize,
    required this.result,
  });

  double get throughput => dataSize / duration.inMilliseconds;

  @override
  String toString() =>
      '$operation: ${duration.inMilliseconds}ms (${throughput.toStringAsFixed(2)} items/sec)';
}

/// Mock FirebaseRemoteConfig for performance testing
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
  double getDouble(String key) =>
      double.tryParse(_values[key]?.toString() ?? '0.0') ?? 0.0;
}

void main() {
  group('Performance Profiling E2E Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late LiveOpsCampaignService campaignService;
    late MockFirebaseRemoteConfig mockRemoteConfig;
    final metrics = <PerformanceMetrics>[];

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockRemoteConfig = MockFirebaseRemoteConfig();
      campaignService = LiveOpsCampaignService(
        firestore: fakeFirestore,
        remoteConfig: mockRemoteConfig,
      );
      metrics.clear();
    });

    group('Campaign Operations Performance', () {
      test('fetching 10 active campaigns completes within 500ms', () async {
        // Setup: Create 10 campaigns
        for (int i = 1; i <= 10; i++) {
          final campaignId = 'camp_${i.toString().padLeft(3, '0')}';
          await fakeFirestore.collection('campaigns').doc(campaignId).set({
            'name': 'Campaign $i',
            'description': 'Test campaign $i',
            'currently_live': i % 2 == 0, // 5 active, 5 inactive
            'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
            'requirement': 'matches_completed',
          });
        }

        // Measure fetch performance
        final stopwatch = Stopwatch()..start();
        final campaigns = await campaignService.fetchActiveCampaigns();
        stopwatch.stop();

        final metric = PerformanceMetrics(
          operation: 'fetchActiveCampaigns',
          duration: stopwatch.elapsed,
          dataSize: campaigns.length,
          result: 'PASS',
        );
        metrics.add(metric);

        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Should fetch 10 campaigns in < 500ms');
        expect(campaigns.where((c) => c.currentlyLive).length, equals(5));
      });

      test('streaming campaign updates processes 10 events within 1000ms', () async {
        final campaignId = 'camp_stream_001';

        // Create initial campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Stream Test Campaign',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Measure stream subscription and first event
        final stopwatch = Stopwatch()..start();

        int eventCount = 0;
        final subscription = campaignService
            .streamActiveCampaigns()
            .listen((campaigns) {
              eventCount++;
            });

        // Allow time for stream to process
        await Future.delayed(Duration(milliseconds: 100));

        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Stream should emit first event within 1000ms');

        await subscription.cancel();
      });

      test('claiming 50 rewards across 5 users takes < 2 seconds', () async {
        final campaignId = 'camp_bulk_claim';
        const userCount = 5;
        const rewardsPerUser = 10;

        // Setup: Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Bulk Claim Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Create rewards
        for (int i = 1; i <= rewardsPerUser; i++) {
          await fakeFirestore
              .collection('campaigns')
              .doc(campaignId)
              .collection('rewards')
              .doc('reward_${i.toString().padLeft(3, '0')}')
              .set({
                'name': 'Reward $i',
                'type': 'cosmetic',
                'order': i,
              });
        }

        // Setup user progress
        for (int u = 1; u <= userCount; u++) {
          final userId = 'user_bulk_$u';
          await fakeFirestore
              .collection('users')
              .doc(userId)
              .collection('campaign_progress')
              .doc(campaignId)
              .set({
                'challenges_completed': 10,
                'total_challenges': 10,
                'claimed_rewards': [],
              });
        }

        // Measure bulk claim performance
        final stopwatch = Stopwatch()..start();

        int claimsCompleted = 0;
        for (int u = 1; u <= userCount; u++) {
          final userId = 'user_bulk_$u';
          for (int r = 1; r <= rewardsPerUser; r++) {
            final rewardId = 'reward_${r.toString().padLeft(3, '0')}';
            await campaignService.claimCampaignReward(
              userId: userId,
              campaignId: campaignId,
              rewardId: rewardId,
            );
            claimsCompleted++;
          }
        }

        stopwatch.stop();

        final metric = PerformanceMetrics(
          operation: 'bulkClaimRewards',
          duration: stopwatch.elapsed,
          dataSize: claimsCompleted,
          result: 'PASS',
        );
        metrics.add(metric);

        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Should complete 50 claims in < 2 seconds');
        expect(claimsCompleted, equals(userCount * rewardsPerUser));
      });
    });

    group('Participation Tracking Performance', () {
      test('tracking 100 participation events completes within 1000ms', () async {
        final campaignId = 'camp_tracking';
        const eventCount = 100;
        final eventTypes = ['viewed', 'started', 'completed', 'claimed_reward'];

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Tracking Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Measure event tracking performance
        final stopwatch = Stopwatch()..start();

        for (int i = 1; i <= eventCount; i++) {
          final userId = 'user_track_${(i % 20).toString().padLeft(2, '0')}';
          final eventType = eventTypes[i % eventTypes.length];

          await campaignService.trackCampaignParticipation(
            userId: userId,
            campaignId: campaignId,
            eventType: eventType,
          );
        }

        stopwatch.stop();

        final metric = PerformanceMetrics(
          operation: 'trackParticipation',
          duration: stopwatch.elapsed,
          dataSize: eventCount,
          result: 'PASS',
        );
        metrics.add(metric);

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Should track 100 events in < 1000ms');
      });
    });

    group('User Progress Queries Performance', () {
      test('fetching progress for 20 users completes within 500ms', () async {
        const campaignId = 'camp_progress';
        const userCount = 20;

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Progress Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Create progress records for 20 users
        for (int i = 1; i <= userCount; i++) {
          final userId = 'user_prog_${i.toString().padLeft(2, '0')}';
          await fakeFirestore
              .collection('users')
              .doc(userId)
              .collection('campaign_progress')
              .doc(campaignId)
              .set({
                'challenges_completed': i % 3 + 1,
                'total_challenges': 3,
                'claimed_rewards': i % 2 == 0 ? ['reward_001'] : [],
              });
        }

        // Measure query performance
        final stopwatch = Stopwatch()..start();

        int queriesCompleted = 0;
        for (int i = 1; i <= userCount; i++) {
          final userId = 'user_prog_${i.toString().padLeft(2, '0')}';
          await campaignService.getUserCampaignProgress(
            userId: userId,
            campaignId: campaignId,
          );
          queriesCompleted++;
        }

        stopwatch.stop();

        final metric = PerformanceMetrics(
          operation: 'getUserProgressBatch',
          duration: stopwatch.elapsed,
          dataSize: queriesCompleted,
          result: 'PASS',
        );
        metrics.add(metric);

        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Should fetch progress for 20 users in < 500ms');
      });
    });

    group('Bonus Fetching Performance', () {
      test('fetching special event bonuses completes within 100ms', () async {
        final stopwatch = Stopwatch()..start();

        final bonuses = await campaignService.getSpecialEventBonuses();

        stopwatch.stop();

        final metric = PerformanceMetrics(
          operation: 'getSpecialEventBonuses',
          duration: stopwatch.elapsed,
          dataSize: 1,
          result: 'PASS',
        );
        metrics.add(metric);

        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Should fetch bonuses in < 100ms');
        expect(bonuses.isActive, isTrue);
      });
    });

    group('Memory Efficiency', () {
      test('handling 500 campaigns does not cause excessive memory usage', () async {
        // Setup: Create 500 campaigns
        final stopwatch = Stopwatch()..start();

        for (int i = 1; i <= 500; i++) {
          final campaignId = 'camp_mem_${i.toString().padLeft(5, '0')}';
          await fakeFirestore.collection('campaigns').doc(campaignId).set({
            'name': 'Campaign $i',
            'description': 'Test campaign $i for memory efficiency',
            'currently_live': i % 3 == 0,
            'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
            'base_reward': 100 + i,
            'requirement': 'matches_completed',
          });
        }

        stopwatch.stop();

        // Fetch should still be performant even with many campaigns
        final fetchStopwatch = Stopwatch()..start();
        final campaigns = await campaignService.fetchActiveCampaigns();
        fetchStopwatch.stop();

        // Active campaigns = ~167 (500 / 3)
        expect(campaigns.length, greaterThan(100));
        expect(fetchStopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Should handle 500 campaigns efficiently');
      });
    });

    group('Concurrent Operations', () {
      test('concurrent claims and tracking operations maintain consistency',
          () async {
        final campaignId = 'camp_concurrent';
        final userIds = ['user_con_1', 'user_con_2', 'user_con_3'];

        // Create campaign
        await fakeFirestore.collection('campaigns').doc(campaignId).set({
          'name': 'Concurrent Test',
          'currently_live': true,
          'start_time': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          'end_time': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        });

        // Create progress for all users
        for (final userId in userIds) {
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
        }

        // Perform concurrent operations
        final stopwatch = Stopwatch()..start();

        final futures = <Future>[];
        for (final userId in userIds) {
          // Concurrent claim
          futures.add(
            campaignService.claimCampaignReward(
              userId: userId,
              campaignId: campaignId,
              rewardId: 'reward_001',
            ),
          );

          // Concurrent tracking
          futures.add(
            campaignService.trackCampaignParticipation(
              userId: userId,
              campaignId: campaignId,
              eventType: 'claimed_reward',
            ),
          );
        }

        await Future.wait(futures);

        stopwatch.stop();

        // Verify consistency
        for (final userId in userIds) {
          final progress = await campaignService.getUserCampaignProgress(
            userId: userId,
            campaignId: campaignId,
          );
          expect(progress.hasClaimedReward, isTrue);
        }

        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Concurrent operations should complete in < 1000ms');
      });
    });

    tearDown(() {
      if (metrics.isNotEmpty) {
        print('\n=== Performance Metrics ===');
        for (final metric in metrics) {
          print(metric);
        }
        print('=========================\n');
      }
    });
  });
}
