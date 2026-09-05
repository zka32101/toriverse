import 'package:firebase_analytics/firebase_analytics.dart';

/// Type-safe analytics event tracking
///
/// Wraps Firebase Analytics with strongly-typed events and parameters.
/// All events include timestamp and session context automatically.
class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Log a match completion event
  ///
  /// Called after match concludes (win/loss/draw).
  /// Includes player rank and streak context for retention analysis.
  Future<void> logMatchCompleted({
    required String matchId,
    required String result, // 'win', 'loss', 'draw'
    required int currentStreak,
    required int matchDurationSeconds,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'match_completed',
        parameters: {
          'match_id': matchId,
          'result': result,
          'current_streak': currentStreak,
          'duration_seconds': matchDurationSeconds,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail — analytics should never break game flow
    }
  }

  /// Log milestone achievement
  ///
  /// Fired when player reaches a streak milestone (3, 5, 10, 25, 50, 100).
  /// Used to identify key retention inflection points.
  Future<void> logMilestoneReached({
    required int milestone,
    required String? cosmeticRewardId,
    required String cosmeticRarity,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'milestone_reached',
        parameters: {
          'milestone_level': milestone,
          'reward_cosmetic_id': cosmeticRewardId ?? 'none',
          'reward_rarity': cosmeticRarity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetic activation
  ///
  /// Called when player activates a cosmetic (board or stone set).
  /// Tracks which cosmetics drive engagement.
  Future<void> logCosmeticActivated({
    required String cosmeticId,
    required String cosmeticType, // 'board' or 'stone'
    required String rarity,
    required String source, // 'starter_kit', 'match_reward', 'milestone_reward', 'shop_purchase'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetic_activated',
        parameters: {
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'rarity': rarity,
          'source': source,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetic purchase
  ///
  /// Called when player completes a shop purchase.
  /// Used to track monetization and cosmetic appeal.
  Future<void> logCosmeticPurchased({
    required String cosmeticId,
    required String cosmeticType,
    required String rarity,
    required int priceYen,
    required String paymentMethod, // 'credit_card', 'apple_pay', 'google_pay'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetic_purchased',
        parameters: {
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'rarity': rarity,
          'price_yen': priceYen,
          'payment_method': paymentMethod,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log streak reset / loss
  ///
  /// Called when player's streak is broken (loss, timeout, manual quit).
  /// Tracks frustration points and helps identify retention risks.
  Future<void> logStreakReset({
    required int lostStreakCount,
    required String reason, // 'manual_quit', 'connection_timeout', 'match_loss'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'streak_reset',
        parameters: {
          'lost_streak': lostStreakCount,
          'reason': reason,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log rank pass (season pass) purchase
  ///
  /// Called when player converts from free to paid.
  /// Critical KPI for revenue tracking.
  Future<void> logRankPassPurchased({
    required int priceYen,
    required String seasonId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'rankpass_purchased',
        parameters: {
          'price_yen': priceYen,
          'season_id': seasonId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log clip shared to social media
  ///
  /// Called when player shares match replay clip.
  /// Used to measure viral coefficient and organic acquisition.
  Future<void> logClipShared({
    required String clipId,
    required String platform, // 'twitter', 'tiktok', 'instagram', 'line'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'clip_shared',
        parameters: {
          'clip_id': clipId,
          'platform': platform,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log bonus feature activation
  ///
  /// Called when weak bonus or rescue card is activated in game.
  /// Tracks game balance and feature effectiveness.
  Future<void> logBonusActivated({
    required String bonusType, // 'weak_bonus', 'rescue_card', 'special_event'
    required int effectValue,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'bonus_activated',
        parameters: {
          'bonus_type': bonusType,
          'effect_value': effectValue,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetics shop opened
  ///
  /// Called when user navigates to the cosmetics shop screen.
  /// Tracks shop engagement and visit frequency.
  Future<void> logCosmeticsShopOpened() async {
    try {
      await _analytics.logEvent(
        name: 'cosmetics_shop_opened',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetics shop filter applied
  ///
  /// Called when user filters cosmetics by type.
  /// Tracks which cosmetic types are most viewed.
  Future<void> logCosmeticsShopFiltered({
    required String filterType, // 'board', 'stoneBlack', 'stoneWhite', 'stoneRed'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetics_shop_filtered_by_type',
        parameters: {
          'filter_type': filterType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetic item preview
  ///
  /// Called when user opens detail dialog for a cosmetic.
  /// Tracks cosmetic interest and engagement.
  Future<void> logCosmeticItemPreviewed({
    required String cosmeticId,
    required String cosmeticType,
    required String rarity,
    required int priceYen,
    required bool isOwned,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetic_item_previewed',
        parameters: {
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'rarity': rarity,
          'price_yen': priceYen,
          'is_owned': isOwned,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetic purchase failure
  ///
  /// Called when a purchase attempt fails.
  /// Used to track payment issues and revenue blockers.
  Future<void> logCosmeticPurchaseFailed({
    required String cosmeticId,
    required String cosmeticType,
    required String failureReason, // 'insufficient_balance', 'payment_failed', 'network_error', 'unknown'
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetic_purchased_failed',
        parameters: {
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'failure_reason': failureReason,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log cosmetic applied to match
  ///
  /// Called when user sets a cosmetic as active for use in matches.
  /// Tracks cosmetic usage and engagement.
  Future<void> logCosmeticAppliedToMatch({
    required String cosmeticId,
    required String cosmeticType,
    required String rarity,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'cosmetic_applied_to_match',
        parameters: {
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'rarity': rarity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log match completed with cosmetic
  ///
  /// Called after match concludes when player had a cosmetic active.
  /// Tracks cosmetic usage in actual gameplay.
  Future<void> logMatchCompletedWithCosmetic({
    required String matchId,
    required String result, // 'win', 'loss', 'draw'
    required int currentStreak,
    required int matchDurationSeconds,
    required String cosmeticId,
    required String cosmeticType,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'match_completed_with_cosmetic',
        parameters: {
          'match_id': matchId,
          'result': result,
          'current_streak': currentStreak,
          'duration_seconds': matchDurationSeconds,
          'cosmetic_id': cosmeticId,
          'cosmetic_type': cosmeticType,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Set user properties for cohort analysis
  ///
  /// Called once at user creation and periodically for updates.
  Future<void> setUserProperties({
    required String userId,
    required int accountAgeMinutes,
    required int totalMatchesPlayed,
    required bool isPaidSubscriber,
  }) async {
    try {
      await _analytics.setUserId(userId);
      await _analytics.setUserProperty(
        name: 'account_age_minutes',
        value: accountAgeMinutes.toString(),
      );
      await _analytics.setUserProperty(
        name: 'total_matches',
        value: totalMatchesPlayed.toString(),
      );
      await _analytics.setUserProperty(
        name: 'paid_subscriber',
        value: isPaidSubscriber ? 'true' : 'false',
      );
    } catch (e) {
      // Silent fail
    }
  }
}
