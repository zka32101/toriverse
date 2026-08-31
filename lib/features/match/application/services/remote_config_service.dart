import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Remote Config service for tuning game balance parameters
///
/// Enables operators to adjust thresholds and timeouts based on:
/// - Balance simulator results
/// - Player feedback
/// - A/B testing
///
/// All parameters cache locally and refresh on app startup + every 1 hour
class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();

  late final FirebaseRemoteConfig _remoteConfig;

  RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance;
  }

  /// Initialize Remote Config with defaults
  /// Call once during app startup
  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;

    // Set default values (fallback if Remote Config unavailable)
    await _remoteConfig.setDefaults({
      'weak_bonus_stone_diff_threshold': 8,
      'weak_bonus_round_threshold': 11,
      'weak_bonus_max_activations_per_match': 2,
      'rescue_card_consecutive_attacks': 2,
      'submission_window_timeout_ms': 30000,
      'daily_free_rank_matches': 1,
      'min_supported_version': '1.0.0',
    });

    // Fetch latest values from Remote Config
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      developer.log(
        'Failed to fetch Remote Config: $e',
        name: 'RemoteConfigService',
        level: 900, // WARNING level
      );
      // Gracefully fall back to defaults
    }
  }

  /// [弱者ボーナス] Stone difference threshold for bottom 20% detection
  /// Default: 8 stones
  /// Tuning: Increase to make bonus harder to trigger, decrease for easier
  int getWeakBonusStoneDiffThreshold() {
    return _remoteConfig.getInt('weak_bonus_stone_diff_threshold');
  }

  /// [弱者ボーナス] Remaining rounds threshold for bonus activation
  /// Default: 11 rounds (endgame only)
  /// Tuning: Increase to expand bonus window, decrease to limit to final rounds
  int getWeakBonusRoundThreshold() {
    return _remoteConfig.getInt('weak_bonus_round_threshold');
  }

  /// [弱者ボーナス] Maximum activations per match
  /// Default: 2
  /// Tuning: Increase to give weaker players more opportunities, decrease to limit snowballing
  int getWeakBonusMaxActivationsPerMatch() {
    return _remoteConfig.getInt('weak_bonus_max_activations_per_match');
  }

  /// [救済カード] Consecutive attacks threshold
  /// Default: 2 (attacked by same player 2 rounds straight)
  /// Tuning: Increase to make rescue card harder to earn, decrease for more frequent use
  int getRescueCardConsecutiveAttacksThreshold() {
    return _remoteConfig.getInt('rescue_card_consecutive_attacks');
  }

  /// Submission window timeout in milliseconds
  /// Default: 30000ms (30 seconds)
  /// Tuning: Increase for slower players, decrease for faster-paced games
  int getSubmissionWindowTimeoutMs() {
    return _remoteConfig.getInt('submission_window_timeout_ms');
  }

  /// Daily free rank match attempts
  /// Default: 1
  /// Tuning: Increase for player acquisition phase, decrease for monetization
  int getDailyFreeRankMatches() {
    return _remoteConfig.getInt('daily_free_rank_matches');
  }

  /// Minimum supported app version (for forcing updates)
  /// Default: '1.0.0'
  /// Format: 'major.minor.patch'
  String getMinSupportedVersion() {
    return _remoteConfig.getString('min_supported_version');
  }

  /// Refresh Remote Config values from server
  /// Call periodically (app creates background refresh every 1 hour)
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      developer.log(
        'Failed to refresh Remote Config: $e',
        name: 'RemoteConfigService',
        level: 900, // WARNING level
      );
    }
  }
}
