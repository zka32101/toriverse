import 'package:freezed_annotation/freezed_annotation.dart';

part 'influencer_program.freezed.dart';
part 'influencer_program.g.dart';

/// Streamer verification status and tier information
///
/// Tracks verification level, monetization tier, and program eligibility.
@freezed
class StreamerVerification with _$StreamerVerification {
  const factory StreamerVerification({
    required String userId,                    // Streamer's user ID
    required StreamerTier tier,                // Current monetization tier
    required bool isVerified,                  // Passed verification
    required int followerCount,                // Total followers
    required int totalStreams,                 // Lifetime stream count
    required double avgViewerCount,            // Average viewers per stream
    required double avgStreamDuration,         // Avg minutes per stream
    DateTime? verifiedAt,                      // When verified
    DateTime? tierUpgradedAt,                  // When tier last upgraded
    @Default([]) List<String> badges,         // Achievement badges
    @Default(false) bool isSuspended,         // Account suspended
    String? suspensionReason,                  // Reason for suspension
    DateTime? suspendedAt,                     // When suspended
    @Default({}) Map<String, dynamic> metadata, // Custom metadata
  }) = _StreamerVerification;

  factory StreamerVerification.fromJson(Map<String, dynamic> json) =>
      _$StreamerVerificationFromJson(json);
}

/// Monetization tier levels with revenue split
enum StreamerTier {
  unverified,    // Not yet verified (0% revenue share)
  affiliate,     // Entry level (20% revenue share)
  partner,       // Established (30% revenue share)
  premium,       // Elite (40% revenue share)
}

extension StreamerTierExt on StreamerTier {
  String get label {
    switch (this) {
      case StreamerTier.unverified:
        return 'Unverified';
      case StreamerTier.affiliate:
        return 'Affiliate';
      case StreamerTier.partner:
        return 'Partner';
      case StreamerTier.premium:
        return 'Premium';
    }
  }

  String get description {
    switch (this) {
      case StreamerTier.unverified:
        return 'Not yet verified - No revenue share';
      case StreamerTier.affiliate:
        return 'Entry level - 20% revenue share';
      case StreamerTier.partner:
        return 'Established - 30% revenue share';
      case StreamerTier.premium:
        return 'Elite - 40% revenue share';
    }
  }

  double get revenueShare {
    switch (this) {
      case StreamerTier.unverified:
        return 0.0;
      case StreamerTier.affiliate:
        return 0.2;
      case StreamerTier.partner:
        return 0.3;
      case StreamerTier.premium:
        return 0.4;
    }
  }

  String get icon {
    switch (this) {
      case StreamerTier.unverified:
        return '🔒';
      case StreamerTier.affiliate:
        return '⭐';
      case StreamerTier.partner:
        return '💫';
      case StreamerTier.premium:
        return '👑';
    }
  }

  bool get canMonetize {
    return this != StreamerTier.unverified;
  }

  bool get canEarnAffiliateCommission {
    return this == StreamerTier.affiliate || this == StreamerTier.partner || this == StreamerTier.premium;
  }

  bool get canEarnPartnerBonus {
    return this == StreamerTier.partner || this == StreamerTier.premium;
  }

  bool get canEarnPremiumBonus {
    return this == StreamerTier.premium;
  }
}

/// Verification requirements for tier eligibility
@freezed
class VerificationRequirements with _$VerificationRequirements {
  const factory VerificationRequirements({
    required StreamerTier tier,
    required int minFollowers,                 // Minimum follower count
    required int minTotalStreams,              // Minimum lifetime streams
    required double minAvgViewers,             // Minimum average viewers
    required int minStreakDays,                // Minimum streak days
    required bool requiresBankAccount,         // Must provide banking info
    required bool requiresIdentityVerification, // Photo ID verification
    @Default([]) List<String> restrictions,   // Content restrictions
  }) = _VerificationRequirements;

  factory VerificationRequirements.fromJson(Map<String, dynamic> json) =>
      _$VerificationRequirementsFromJson(json);
}

/// Referral tracking for viral growth
///
/// Tracks user-to-user referrals with revenue sharing.
@freezed
class ReferralRecord with _$ReferralRecord {
  const factory ReferralRecord({
    required String id,                        // Unique referral ID
    required String referrerId,                // Who referred
    required String referredUserId,            // Who was referred
    required DateTime referredAt,              // When referred
    required String referralCode,              // Unique code used
    required int referralBonus,                // One-time bonus (JPY)
    required double commissionRate,            // Ongoing commission %
    @Default(ReferralStatus.pending)
      ReferralStatus status,                   // pending, active, inactive
    DateTime? activatedAt,                     // When referred user started paying
    int? totalCommissionEarned,                // Total commission from this referral
    DateTime? lastCommissionAt,                // Last commission payment
    @Default(0) int referralCount,             // How many this user referred
  }) = _ReferralRecord;

  factory ReferralRecord.fromJson(Map<String, dynamic> json) =>
      _$ReferralRecordFromJson(json);
}

/// Status of a referral relationship
enum ReferralStatus {
  pending,       // Referral code generated but not yet used
  active,        // Referred user is active/paying
  inactive,      // Referred user stopped paying
  expired,       // Referral link expired
  claimed,       // Bonus already claimed
}

extension ReferralStatusExt on ReferralStatus {
  String get label {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.active:
        return 'Active';
      case ReferralStatus.inactive:
        return 'Inactive';
      case ReferralStatus.expired:
        return 'Expired';
      case ReferralStatus.claimed:
        return 'Bonus Claimed';
    }
  }

  bool get isEarning {
    return this == ReferralStatus.active;
  }
}

/// Streamer analytics and performance metrics
///
/// Aggregated statistics for streamer dashboard and program eligibility.
@freezed
class StreamerAnalytics with _$StreamerAnalytics {
  const factory StreamerAnalytics({
    required String userId,                    // Streamer ID
    required DateTime periodStart,             // Analytics period start
    required DateTime periodEnd,               // Analytics period end
    @Default(0) int totalStreams,              // Total streams in period
    @Default(0) int totalStreamMinutes,        // Total minutes streamed
    @Default(0) int totalViewerMinutes,        // Total viewer-minutes
    @Default(0) int peakViewerCount,           // Highest concurrent viewers
    @Default(0) int avgViewerCount,            // Average concurrent viewers
    @Default(0) int totalUniqueViewers,        // Unique viewer count
    @Default(0) int totalClips,                // Total highlight clips
    @Default(0) int totalClipViews,            // Total clip views
    @Default(0) int totalClipShares,           // Total clip shares
    @Default(0) double streamingRevenue,       // Revenue from streams (JPY)
    @Default(0) double clipRevenue,            // Revenue from clips (JPY)
    @Default(0) double affiliateCommission,    // Affiliate commissions (JPY)
    @Default(0) double totalRevenue,           // Total period revenue (JPY)
    @Default(0) int newFollowers,              // New followers added
    @Default(0) int totalFollowers,            // Current follower count
    @Default(0.0) double engagementRate,       // Viewer chat engagement rate
    @Default(0.0) double clipEngagementRate,   // Clip view-to-share ratio
  }) = _StreamerAnalytics;

  factory StreamerAnalytics.fromJson(Map<String, dynamic> json) =>
      _$StreamerAnalyticsFromJson(json);
}

/// Achievement badges for streamer profile
@freezed
class StreamerBadge with _$StreamerBadge {
  const factory StreamerBadge({
    required String id,                        // Badge ID
    required String name,                      // Display name
    required String emoji,                     // Badge emoji/icon
    required String description,               // What it represents
    required DateTime unlockedAt,              // When earned
    required StreamerBadgeType type,           // Badge category
    @Default({}) Map<String, dynamic> metadata, // Custom data
  }) = _StreamerBadge;

  factory StreamerBadge.fromJson(Map<String, dynamic> json) =>
      _$StreamerBadgeFromJson(json);
}

/// Badge categories
enum StreamerBadgeType {
  milestone,     // Streaming milestones (100h, 1k viewers, etc.)
  engagement,    // Community engagement achievements
  content,       // Content quality achievements
  growth,        // Growth milestones (10x followers, etc.)
  special,       // Special events and limited-time badges
}

extension StreamerBadgeTypeExt on StreamerBadgeType {
  String get label {
    switch (this) {
      case StreamerBadgeType.milestone:
        return 'Milestone';
      case StreamerBadgeType.engagement:
        return 'Engagement';
      case StreamerBadgeType.content:
        return 'Content';
      case StreamerBadgeType.growth:
        return 'Growth';
      case StreamerBadgeType.special:
        return 'Special';
    }
  }
}

/// Streamer leaderboard entry
@freezed
class StreamerLeaderboardEntry with _$StreamerLeaderboardEntry {
  const factory StreamerLeaderboardEntry({
    required String userId,                    // Streamer ID
    required String displayName,               // Display name
    required int rank,                         // Leaderboard rank
    required int score,                        // Ranking score
    required String scoreMetric,               // What metric (viewers, revenue, etc)
    required StreamerTier tier,                // Tier badge
    @Default(0) int streak,                    // Current streak
    @Default(false) bool isBadgeEarned,       // Earned badge this period
  }) = _StreamerLeaderboardEntry;

  factory StreamerLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$StreamerLeaderboardEntryFromJson(json);
}

/// Tier upgrade eligibility check result
@freezed
class TierUpgradeEligibility with _$TierUpgradeEligibility {
  const factory TierUpgradeEligibility({
    required StreamerTier nextTier,             // Next tier to qualify for
    @Default(true) bool isEligible,            // Meets all requirements
    @Default([]) List<TierRequirementCheck> missingRequirements, // Failed checks
    @Default(0) int daysUntilEligible,        // Days until eligible (if not yet)
  }) = _TierUpgradeEligibility;

  factory TierUpgradeEligibility.fromJson(Map<String, dynamic> json) =>
      _$TierUpgradeEligibilityFromJson(json);
}

/// Individual tier requirement check
@freezed
class TierRequirementCheck with _$TierRequirementCheck {
  const factory TierRequirementCheck({
    required String requirement,               // Requirement name
    required int required,                     // Required value
    required int current,                      // Current value
    required bool isMet,                       // Requirement met
    @Default(0) int remaining,                 // How much more needed
  }) = _TierRequirementCheck;

  factory TierRequirementCheck.fromJson(Map<String, dynamic> json) =>
      _$TierRequirementCheckFromJson(json);
}
