import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Service for fetching and caching dynamic configuration from Firebase Remote Config
///
/// Handles milestone rewards, bonus thresholds, and UI timing parameters.
/// Falls back to defaults on any error — app always has valid values.
class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig;

  /// Default configuration values (used when Firebase unavailable)
  static const Map<String, dynamic> _defaults = {
    // Milestone thresholds for cosmetic rewards
    'milestone_cosmetic_thresholds': [3, 5, 10, 25, 50, 100],

    // Weak bonus configuration
    'weak_bonus_enabled': true,
    'weak_bonus_threshold_percentile': 20, // Bottom 20% of players
    'weak_bonus_max_activations': 2, // Per match

    // Rescue card configuration
    'rescue_card_enabled': true,
    'rescue_card_trigger_consecutive_attacks': 2,

    // UI timing
    'milestone_celebration_delay_ms': 800,
    'milestone_dialog_animation_duration_ms': 600,
    'streak_reset_notification_timeout_ms': 5000,

    // A/B testing: Celebration timing variants
    'celebration_timing_variant': 'default', // 'fast', 'default', 'slow'

    // Feature flags
    'push_notifications_enabled': true,
    'cosmetic_shop_enabled': true,
    'seasonal_events_enabled': false,

    // Pricing and monetization
    'rankpass_price_yen': 300,
    'free_matches_per_day': 1,

    // Analytics
    'min_match_duration_for_analytics_ms': 30000,
    'analytics_sampling_rate': 1.0, // 0.0-1.0

    // Minimum supported version (for forcing updates)
    'min_supported_version': '1.0.0',
  };

  RemoteConfigService({FirebaseRemoteConfig? remoteConfig})
      : _remoteConfig = remoteConfig ?? FirebaseRemoteConfig.instance;

  /// Initialize Remote Config and fetch values from server
  ///
  /// Sets cache expiration to 1 hour for prod, immediate for dev.
  /// Gracefully handles network failures by using defaults.
  Future<void> initialize({bool isDev = false}) async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration(hours: isDev ? 0 : 1),
        ),
      );

      // Set defaults
      await _remoteConfig.setDefaults(_defaults);

      // Fetch latest values
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Network error or timeout — defaults are already set
    }
  }

  /// Get milestone levels that grant cosmetic rewards
  ///
  /// Example: [3, 5, 10, 25, 50, 100]
  List<int> getMilestoneThresholds() {
    try {
      final value = _remoteConfig.getString('milestone_cosmetic_thresholds');
      if (value.isEmpty) return _defaults['milestone_cosmetic_thresholds'] ?? [];
      return value.split(',').map((s) => int.tryParse(s) ?? 0).toList();
    } catch (e) {
      return _defaults['milestone_cosmetic_thresholds'] ?? [];
    }
  }

  /// Get weak bonus configuration
  WeakBonusConfig getWeakBonusConfig() {
    try {
      return WeakBonusConfig(
        enabled: _remoteConfig.getBool('weak_bonus_enabled'),
        thresholdPercentile:
            _remoteConfig.getInt('weak_bonus_threshold_percentile'),
        maxActivationsPerMatch: _remoteConfig.getInt('weak_bonus_max_activations'),
      );
    } catch (e) {
      return WeakBonusConfig(
        enabled: _defaults['weak_bonus_enabled'] ?? true,
        thresholdPercentile:
            _defaults['weak_bonus_threshold_percentile'] ?? 20,
        maxActivationsPerMatch: _defaults['weak_bonus_max_activations'] ?? 2,
      );
    }
  }

  /// Get rescue card configuration
  RescueCardConfig getRescueCardConfig() {
    try {
      return RescueCardConfig(
        enabled: _remoteConfig.getBool('rescue_card_enabled'),
        triggerConsecutiveAttacks:
            _remoteConfig.getInt('rescue_card_trigger_consecutive_attacks'),
      );
    } catch (e) {
      return RescueCardConfig(
        enabled: _defaults['rescue_card_enabled'] ?? true,
        triggerConsecutiveAttacks:
            _defaults['rescue_card_trigger_consecutive_attacks'] ?? 2,
      );
    }
  }

  /// Get UI timing configuration
  UITimingConfig getUITimingConfig() {
    try {
      return UITimingConfig(
        milestoneDelayMs: _remoteConfig.getInt('milestone_celebration_delay_ms'),
        animationDurationMs:
            _remoteConfig.getInt('milestone_dialog_animation_duration_ms'),
        streakNotificationTimeoutMs:
            _remoteConfig.getInt('streak_reset_notification_timeout_ms'),
      );
    } catch (e) {
      return UITimingConfig(
        milestoneDelayMs: _defaults['milestone_celebration_delay_ms'] ?? 800,
        animationDurationMs:
            _defaults['milestone_dialog_animation_duration_ms'] ?? 600,
        streakNotificationTimeoutMs:
            _defaults['streak_reset_notification_timeout_ms'] ?? 5000,
      );
    }
  }

  /// Get A/B test variant for celebration timing
  CelebrationTimingVariant getCelebrationTimingVariant() {
    try {
      final variant = _remoteConfig.getString('celebration_timing_variant');
      return CelebrationTimingVariant.values.firstWhere(
        (v) => v.name == variant,
        orElse: () => CelebrationTimingVariant.defaultVariant,
      );
    } catch (e) {
      return CelebrationTimingVariant.defaultVariant;
    }
  }

  /// Check if feature is enabled
  bool isFeatureEnabled(String featureFlag) {
    try {
      return _remoteConfig.getBool('${featureFlag}_enabled');
    } catch (e) {
      return _defaults['${featureFlag}_enabled'] ?? false;
    }
  }

  /// Get rank pass (season pass) price in Japanese Yen
  int getRankPassPrice() {
    try {
      return _remoteConfig.getInt('rankpass_price_yen');
    } catch (e) {
      return _defaults['rankpass_price_yen'] ?? 300;
    }
  }

  /// Get free matches allowed per day
  int getFreeMatchesPerDay() {
    try {
      return _remoteConfig.getInt('free_matches_per_day');
    } catch (e) {
      return _defaults['free_matches_per_day'] ?? 1;
    }
  }

  /// Get minimum app version (for forced updates)
  String getMinSupportedVersion() {
    try {
      return _remoteConfig.getString('min_supported_version');
    } catch (e) {
      return _defaults['min_supported_version'] ?? '1.0.0';
    }
  }

  /// Manually refresh Remote Config values
  ///
  /// Call this periodically or on user request to update values.
  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Silently fail — continue with cached values
    }
  }
}

/// Weak bonus configuration model
class WeakBonusConfig {
  final bool enabled;
  final int thresholdPercentile; // Bottom X% of players can receive bonus
  final int maxActivationsPerMatch;

  const WeakBonusConfig({
    required this.enabled,
    required this.thresholdPercentile,
    required this.maxActivationsPerMatch,
  });
}

/// Rescue card configuration model
class RescueCardConfig {
  final bool enabled;
  final int triggerConsecutiveAttacks; // Grant card after N consecutive attacks

  const RescueCardConfig({
    required this.enabled,
    required this.triggerConsecutiveAttacks,
  });
}

/// UI timing configuration model
class UITimingConfig {
  final int milestoneDelayMs; // Delay before showing milestone dialog
  final int animationDurationMs; // Celebration dialog animation
  final int streakNotificationTimeoutMs; // Dismiss notification after X ms

  const UITimingConfig({
    required this.milestoneDelayMs,
    required this.animationDurationMs,
    required this.streakNotificationTimeoutMs,
  });
}

/// A/B test variants for celebration timing
enum CelebrationTimingVariant {
  fast(durationMs: 400),
  defaultVariant(durationMs: 600),
  slow(durationMs: 800);

  final int durationMs;
  const CelebrationTimingVariant({required this.durationMs});
}
