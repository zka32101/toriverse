import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/shop/domain/services/battle_pass_service.dart';
import 'cosmetics_providers.dart';

/// Provider for BattlePassService
final battlePassServiceProvider = Provider<BattlePassService>((ref) {
  return BattlePassService();
});

/// Provider for user's battle pass progress
final userBattlePassProgressProvider =
    StreamProvider<UserBattlePassProgress?>((ref) {
  final userId = ref.watch(userIdProvider);
  final firestore = FirebaseFirestore.instance;
  final battlePassService = ref.watch(battlePassServiceProvider);

  return firestore
      .collection('users')
      .doc(userId)
      .collection('battlePass')
      .doc('progress')
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) {
          // Return default progress for new users
          return UserBattlePassProgress(
            userId: userId,
            season: BattlePassService.currentSeason,
            totalXP: 0,
            currentTier: 1,
            hasPremiumPass: false,
            claimedRewards: {},
            seasonStartDate: DateTime.now(),
          );
        }

        return UserBattlePassProgress.fromMap({
          ...snapshot.data()!,
          'user_id': userId,
        });
      });
});

/// Provider for getting tier info by tier number
final battlePassTierProvider =
    Provider.family<BattlePassTier?, int>((ref, tier) {
  final battlePassService = ref.watch(battlePassServiceProvider);
  return battlePassService.getTierReward(tier);
});

/// Provider for all tier milestones
final allBattlePassTiersProvider = Provider<List<BattlePassTier>>((ref) {
  final battlePassService = ref.watch(battlePassServiceProvider);
  final tiers = <BattlePassTier>[];

  for (int i = 1; i <= BattlePassService.maxTier; i++) {
    final tier = battlePassService.getTierReward(i);
    if (tier != null) {
      tiers.add(tier);
    }
  }

  return tiers;
});

/// Provider to check if user has premium pass
final hasPremiumPassProvider = FutureProvider<bool>((ref) async {
  final progress = await ref.watch(userBattlePassProgressProvider.future);
  return progress?.hasPremiumPass ?? false;
});

/// Provider for season end date
final seasonEndDateProvider = Provider<DateTime>((ref) {
  final battlePassService = ref.watch(battlePassServiceProvider);
  final now = DateTime.now();

  // Calculate season start date (1st of current month)
  final seasonStart = DateTime(now.year, now.month, 1);
  return battlePassService.getSeasonEndDate(seasonStart);
});

/// Provider for days remaining in season
final daysRemainingProvider = Provider<int>((ref) {
  final endDate = ref.watch(seasonEndDateProvider);
  final now = DateTime.now();
  final remaining = endDate.difference(now).inDays;
  return remaining.clamp(0, 30);
});

/// State notifier for battle pass operations
class BattlePassNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final String _userId;
  final BattlePassService _battlePassService;

  BattlePassNotifier({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
    required String userId,
    required BattlePassService battlePassService,
  })  : _firestore = firestore,
        _analytics = analytics,
        _userId = userId,
        _battlePassService = battlePassService,
        super(const AsyncValue.data(null));

  /// Add XP to user's battle pass
  Future<bool> addBattlePassXP({
    required int xpAmount,
    required String matchResult,
    bool isPremium = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final xp = _battlePassService.calculateMatchXP(
        result: matchResult,
        matchDurationSeconds: 300, // Default match duration
        isPremium: isPremium,
      );

      // Get current progress
      final progressDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('battlePass')
          .doc('progress')
          .get();

      int currentXP = 0;
      if (progressDoc.exists) {
        currentXP = (progressDoc['total_xp'] as int?) ?? 0;
      }

      final newXP = currentXP + xp;
      final tierInfo = _battlePassService.getTierFromXP(newXP);

      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('battlePass')
          .doc('progress')
          .set({
        'season': BattlePassService.currentSeason,
        'total_xp': newXP,
        'current_tier': tierInfo.tier,
        'has_premium_pass': isPremium,
        'claimed_rewards': progressDoc.exists
            ? progressDoc['claimed_rewards'] ?? []
            : [],
        'season_start_date':
            Timestamp.fromDate(DateTime(DateTime.now().year, DateTime.now().month, 1)),
      }, SetOptions(merge: true));

      // Log analytics
      await _analytics.logEvent(
        name: 'battle_pass_xp_earned',
        parameters: {
          'season': BattlePassService.currentSeason,
          'total_xp': newXP,
          'current_tier': tierInfo.tier,
          'xp_gained': xp,
          'match_result': matchResult,
        },
      );

      // Log tier reached event if tier changed
      if (tierInfo.tier > tierInfo.totalXpEarned ~/ BattlePassService.xpPerTier) {
        await _analytics.logEvent(
          name: 'tier_reached',
          parameters: {
            'season': BattlePassService.currentSeason,
            'tier': tierInfo.tier,
            'milestone': tierInfo.tier % 5 == 0,
          },
        );
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Claim reward at tier
  Future<bool> claimTierReward(int tier) async {
    state = const AsyncValue.loading();
    try {
      // Get current progress
      final progressDoc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('battlePass')
          .doc('progress')
          .get();

      if (!progressDoc.exists) {
        throw Exception('No battle pass progress found');
      }

      final data = progressDoc.data()!;
      final currentTier = data['current_tier'] as int;
      final claimedRewards = List<int>.from(data['claimed_rewards'] as List? ?? []);

      // Check if user can claim
      if (currentTier < tier) {
        throw Exception('Tier $tier not yet reached');
      }

      if (claimedRewards.contains(tier)) {
        throw Exception('Reward already claimed for tier $tier');
      }

      // Get reward info
      final tierInfo = _battlePassService.getTierReward(tier);
      if (tierInfo == null) {
        throw Exception('No reward for tier $tier');
      }

      // Update claimed rewards
      claimedRewards.add(tier);
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('battlePass')
          .doc('progress')
          .update({
        'claimed_rewards': claimedRewards,
      });

      // Log analytics
      await _analytics.logEvent(
        name: 'reward_claimed',
        parameters: {
          'season': BattlePassService.currentSeason,
          'tier': tier,
          'reward_type': (data['has_premium_pass'] as bool?) == true
              ? 'premium'
              : 'free',
          'cosmetic_id': (data['has_premium_pass'] as bool?) == true
              ? tierInfo.premiumReward
              : tierInfo.freeReward,
        },
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Purchase premium pass
  Future<bool> purchasePremiumPass() async {
    state = const AsyncValue.loading();
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('battlePass')
          .doc('progress')
          .update({
        'has_premium_pass': true,
      });

      // Log analytics
      await _analytics.logEvent(
        name: 'premium_pass_purchased',
        parameters: {
          'season': BattlePassService.currentSeason,
          'price_yen': 300,
        },
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for battle pass operations
final battlePassNotifierProvider =
    StateNotifierProvider<BattlePassNotifier, AsyncValue<void>>((ref) {
  return BattlePassNotifier(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
    userId: ref.watch(userIdProvider),
    battlePassService: ref.watch(battlePassServiceProvider),
  );
});
