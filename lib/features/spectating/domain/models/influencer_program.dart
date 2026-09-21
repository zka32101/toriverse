
/// Parses a DateTime from JSON. Tolerates ISO-8601 strings (our own
/// [toJson] output), raw [DateTime] instances, and duck-typed Firestore
/// `Timestamp` objects (which expose a `toDate()` method) since some
/// fields are written server-side via `FieldValue.serverTimestamp()` and
/// read back without going through [toJson].
DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String) return DateTime.parse(value);
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  try {
    return (value as dynamic).toDate() as DateTime;
  } catch (_) {
    return DateTime.now();
  }
}

DateTime? _parseDateTimeOrNull(dynamic value) {
  if (value == null) return null;
  return _parseDateTime(value);
}

List<String> _stringList(dynamic value) =>
    (value as List<dynamic>?)?.map((e) => e as String).toList() ?? const [];

/// Streamer verification status and tier information
///
/// Tracks verification level, monetization tier, and program eligibility.
class StreamerVerification {
  final String userId;
  final StreamerTier tier;
  final bool isVerified;
  final int followerCount;
  final int totalStreams;
  final double avgViewerCount;
  final double avgStreamDuration;
  final DateTime? verifiedAt;
  final DateTime? tierUpgradedAt;
  final List<String> badges;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? suspendedAt;
  final Map<String, dynamic> metadata;

  const StreamerVerification({
    required this.userId,                    // Streamer's user ID
    required this.tier,                       // Current monetization tier
    required this.isVerified,                 // Passed verification
    required this.followerCount,               // Total followers
    required this.totalStreams,                // Lifetime stream count
    required this.avgViewerCount,               // Average viewers per stream
    required this.avgStreamDuration,            // Avg minutes per stream
    this.verifiedAt,                            // When verified
    this.tierUpgradedAt,                        // When tier last upgraded
    this.badges = const [],                     // Achievement badges
    this.isSuspended = false,                   // Account suspended
    this.suspensionReason,                      // Reason for suspension
    this.suspendedAt,                           // When suspended
    this.metadata = const {},                   // Custom metadata
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'tier': tier.name,
        'isVerified': isVerified,
        'followerCount': followerCount,
        'totalStreams': totalStreams,
        'avgViewerCount': avgViewerCount,
        'avgStreamDuration': avgStreamDuration,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'tierUpgradedAt': tierUpgradedAt?.toIso8601String(),
        'badges': badges,
        'isSuspended': isSuspended,
        'suspensionReason': suspensionReason,
        'suspendedAt': suspendedAt?.toIso8601String(),
        'metadata': metadata,
      };

  factory StreamerVerification.fromJson(Map<String, dynamic> json) {
    return StreamerVerification(
      userId: json['userId'] as String,
      tier: StreamerTier.values.byName(json['tier'] as String),
      isVerified: json['isVerified'] as bool,
      followerCount: json['followerCount'] as int,
      totalStreams: json['totalStreams'] as int,
      avgViewerCount: (json['avgViewerCount'] as num).toDouble(),
      avgStreamDuration: (json['avgStreamDuration'] as num).toDouble(),
      verifiedAt: _parseDateTimeOrNull(json['verifiedAt']),
      tierUpgradedAt: _parseDateTimeOrNull(json['tierUpgradedAt']),
      badges: _stringList(json['badges']),
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
      suspendedAt: _parseDateTimeOrNull(json['suspendedAt']),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
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
class VerificationRequirements {
  final StreamerTier tier;
  final int minFollowers;
  final int minTotalStreams;
  final double minAvgViewers;
  final int minStreakDays;
  final bool requiresBankAccount;
  final bool requiresIdentityVerification;
  final List<String> restrictions;

  const VerificationRequirements({
    required this.tier,
    required this.minFollowers,                 // Minimum follower count
    required this.minTotalStreams,               // Minimum lifetime streams
    required this.minAvgViewers,                 // Minimum average viewers
    required this.minStreakDays,                 // Minimum streak days
    required this.requiresBankAccount,           // Must provide banking info
    required this.requiresIdentityVerification,  // Photo ID verification
    this.restrictions = const [],                // Content restrictions
  });

  Map<String, dynamic> toJson() => {
        'tier': tier.name,
        'minFollowers': minFollowers,
        'minTotalStreams': minTotalStreams,
        'minAvgViewers': minAvgViewers,
        'minStreakDays': minStreakDays,
        'requiresBankAccount': requiresBankAccount,
        'requiresIdentityVerification': requiresIdentityVerification,
        'restrictions': restrictions,
      };

  factory VerificationRequirements.fromJson(Map<String, dynamic> json) {
    return VerificationRequirements(
      tier: StreamerTier.values.byName(json['tier'] as String),
      minFollowers: json['minFollowers'] as int,
      minTotalStreams: json['minTotalStreams'] as int,
      minAvgViewers: (json['minAvgViewers'] as num).toDouble(),
      minStreakDays: json['minStreakDays'] as int,
      requiresBankAccount: json['requiresBankAccount'] as bool,
      requiresIdentityVerification:
          json['requiresIdentityVerification'] as bool,
      restrictions: _stringList(json['restrictions']),
    );
  }
}

/// Referral tracking for viral growth
///
/// Tracks user-to-user referrals with revenue sharing.
class ReferralRecord {
  final String id;
  final String referrerId;
  final String referredUserId;
  final DateTime referredAt;
  final String referralCode;
  final int referralBonus;
  final double commissionRate;
  final ReferralStatus status;
  final DateTime? activatedAt;
  final int? totalCommissionEarned;
  final DateTime? lastCommissionAt;
  final int referralCount;

  const ReferralRecord({
    required this.id,                          // Unique referral ID
    required this.referrerId,                  // Who referred
    required this.referredUserId,               // Who was referred
    required this.referredAt,                   // When referred
    required this.referralCode,                 // Unique code used
    required this.referralBonus,                // One-time bonus (JPY)
    required this.commissionRate,               // Ongoing commission %
    this.status = ReferralStatus.pending,       // pending, active, inactive
    this.activatedAt,                           // When referred user started paying
    this.totalCommissionEarned,                 // Total commission from this referral
    this.lastCommissionAt,                      // Last commission payment
    this.referralCount = 0,                     // How many this user referred
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'referrerId': referrerId,
        'referredUserId': referredUserId,
        'referredAt': referredAt.toIso8601String(),
        'referralCode': referralCode,
        'referralBonus': referralBonus,
        'commissionRate': commissionRate,
        'status': status.name,
        'activatedAt': activatedAt?.toIso8601String(),
        'totalCommissionEarned': totalCommissionEarned,
        'lastCommissionAt': lastCommissionAt?.toIso8601String(),
        'referralCount': referralCount,
      };

  factory ReferralRecord.fromJson(Map<String, dynamic> json) {
    return ReferralRecord(
      id: json['id'] as String,
      referrerId: json['referrerId'] as String,
      referredUserId: json['referredUserId'] as String,
      referredAt: _parseDateTime(json['referredAt']),
      referralCode: json['referralCode'] as String,
      referralBonus: json['referralBonus'] as int,
      commissionRate: (json['commissionRate'] as num).toDouble(),
      status: json['status'] != null
          ? ReferralStatus.values.byName(json['status'] as String)
          : ReferralStatus.pending,
      activatedAt: _parseDateTimeOrNull(json['activatedAt']),
      totalCommissionEarned: json['totalCommissionEarned'] as int?,
      lastCommissionAt: _parseDateTimeOrNull(json['lastCommissionAt']),
      referralCount: json['referralCount'] as int? ?? 0,
    );
  }
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
class StreamerAnalytics {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalStreams;
  final int totalStreamMinutes;
  final int totalViewerMinutes;
  final int peakViewerCount;
  final int avgViewerCount;
  final int totalUniqueViewers;
  final int totalClips;
  final int totalClipViews;
  final int totalClipShares;
  final double streamingRevenue;
  final double clipRevenue;
  final double affiliateCommission;
  final double totalRevenue;
  final int newFollowers;
  final int totalFollowers;
  final double engagementRate;
  final double clipEngagementRate;

  const StreamerAnalytics({
    required this.userId,                    // Streamer ID
    required this.periodStart,               // Analytics period start
    required this.periodEnd,                 // Analytics period end
    this.totalStreams = 0,              // Total streams in period
    this.totalStreamMinutes = 0,        // Total minutes streamed
    this.totalViewerMinutes = 0,        // Total viewer-minutes
    this.peakViewerCount = 0,           // Highest concurrent viewers
    this.avgViewerCount = 0,            // Average concurrent viewers
    this.totalUniqueViewers = 0,        // Unique viewer count
    this.totalClips = 0,                // Total highlight clips
    this.totalClipViews = 0,            // Total clip views
    this.totalClipShares = 0,           // Total clip shares
    this.streamingRevenue = 0.0,        // Revenue from streams (JPY)
    this.clipRevenue = 0.0,             // Revenue from clips (JPY)
    this.affiliateCommission = 0.0,     // Affiliate commissions (JPY)
    this.totalRevenue = 0.0,            // Total period revenue (JPY)
    this.newFollowers = 0,              // New followers added
    this.totalFollowers = 0,            // Current follower count
    this.engagementRate = 0.0,        // Viewer chat engagement rate
    this.clipEngagementRate = 0.0,    // Clip view-to-share ratio
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'totalStreams': totalStreams,
        'totalStreamMinutes': totalStreamMinutes,
        'totalViewerMinutes': totalViewerMinutes,
        'peakViewerCount': peakViewerCount,
        'avgViewerCount': avgViewerCount,
        'totalUniqueViewers': totalUniqueViewers,
        'totalClips': totalClips,
        'totalClipViews': totalClipViews,
        'totalClipShares': totalClipShares,
        'streamingRevenue': streamingRevenue,
        'clipRevenue': clipRevenue,
        'affiliateCommission': affiliateCommission,
        'totalRevenue': totalRevenue,
        'newFollowers': newFollowers,
        'totalFollowers': totalFollowers,
        'engagementRate': engagementRate,
        'clipEngagementRate': clipEngagementRate,
      };

  factory StreamerAnalytics.fromJson(Map<String, dynamic> json) {
    return StreamerAnalytics(
      userId: json['userId'] as String,
      periodStart: _parseDateTime(json['periodStart']),
      periodEnd: _parseDateTime(json['periodEnd']),
      totalStreams: json['totalStreams'] as int? ?? 0,
      totalStreamMinutes: json['totalStreamMinutes'] as int? ?? 0,
      totalViewerMinutes: json['totalViewerMinutes'] as int? ?? 0,
      peakViewerCount: json['peakViewerCount'] as int? ?? 0,
      avgViewerCount: json['avgViewerCount'] as int? ?? 0,
      totalUniqueViewers: json['totalUniqueViewers'] as int? ?? 0,
      totalClips: json['totalClips'] as int? ?? 0,
      totalClipViews: json['totalClipViews'] as int? ?? 0,
      totalClipShares: json['totalClipShares'] as int? ?? 0,
      streamingRevenue: (json['streamingRevenue'] as num?)?.toDouble() ?? 0.0,
      clipRevenue: (json['clipRevenue'] as num?)?.toDouble() ?? 0.0,
      affiliateCommission:
          (json['affiliateCommission'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      newFollowers: json['newFollowers'] as int? ?? 0,
      totalFollowers: json['totalFollowers'] as int? ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0.0,
      clipEngagementRate:
          (json['clipEngagementRate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Achievement badges for streamer profile
class StreamerBadge {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final DateTime unlockedAt;
  final StreamerBadgeType type;
  final Map<String, dynamic> metadata;

  const StreamerBadge({
    required this.id,                          // Badge ID
    required this.name,                        // Display name
    required this.emoji,                       // Badge emoji/icon
    required this.description,                 // What it represents
    required this.unlockedAt,                  // When earned
    required this.type,                        // Badge category
    this.metadata = const {},                  // Custom data
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'description': description,
        'unlockedAt': unlockedAt.toIso8601String(),
        'type': type.name,
        'metadata': metadata,
      };

  factory StreamerBadge.fromJson(Map<String, dynamic> json) {
    return StreamerBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      unlockedAt: _parseDateTime(json['unlockedAt']),
      type: StreamerBadgeType.values.byName(json['type'] as String),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? const {},
    );
  }
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
class StreamerLeaderboardEntry {
  final String userId;
  final String displayName;
  final int rank;
  final int score;
  final String scoreMetric;
  final StreamerTier tier;
  final int streak;
  final bool isBadgeEarned;

  const StreamerLeaderboardEntry({
    required this.userId,                    // Streamer ID
    required this.displayName,                // Display name
    required this.rank,                        // Leaderboard rank
    required this.score,                        // Ranking score
    required this.scoreMetric,                  // What metric (viewers, revenue, etc)
    required this.tier,                         // Tier badge
    this.streak = 0,                    // Current streak
    this.isBadgeEarned = false,       // Earned badge this period
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'rank': rank,
        'score': score,
        'scoreMetric': scoreMetric,
        'tier': tier.name,
        'streak': streak,
        'isBadgeEarned': isBadgeEarned,
      };

  factory StreamerLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return StreamerLeaderboardEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      rank: json['rank'] as int,
      score: json['score'] as int,
      scoreMetric: json['scoreMetric'] as String,
      tier: StreamerTier.values.byName(json['tier'] as String),
      streak: json['streak'] as int? ?? 0,
      isBadgeEarned: json['isBadgeEarned'] as bool? ?? false,
    );
  }
}

/// Tier upgrade eligibility check result
class TierUpgradeEligibility {
  final StreamerTier nextTier;
  final bool isEligible;
  final List<TierRequirementCheck> missingRequirements;
  final int daysUntilEligible;

  const TierUpgradeEligibility({
    required this.nextTier,                     // Next tier to qualify for
    this.isEligible = false,            // Meets all requirements
    this.missingRequirements = const [], // Failed checks
    this.daysUntilEligible = 0,        // Days until eligible (if not yet)
  });

  Map<String, dynamic> toJson() => {
        'nextTier': nextTier.name,
        'isEligible': isEligible,
        'missingRequirements':
            missingRequirements.map((e) => e.toJson()).toList(),
        'daysUntilEligible': daysUntilEligible,
      };

  factory TierUpgradeEligibility.fromJson(Map<String, dynamic> json) {
    return TierUpgradeEligibility(
      nextTier: StreamerTier.values.byName(json['nextTier'] as String),
      isEligible: json['isEligible'] as bool? ?? false,
      missingRequirements: (json['missingRequirements'] as List<dynamic>?)
              ?.map((e) =>
                  TierRequirementCheck.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      daysUntilEligible: json['daysUntilEligible'] as int? ?? 0,
    );
  }
}

/// Individual tier requirement check
class TierRequirementCheck {
  final String requirement;
  final int required;
  final int current;
  final bool isMet;
  final int remaining;

  const TierRequirementCheck({
    required this.requirement,                  // Requirement name
    required this.required,                     // Required value
    required this.current,                      // Current value
    required this.isMet,                        // Requirement met
    this.remaining = 0,                 // How much more needed
  });

  Map<String, dynamic> toJson() => {
        'requirement': requirement,
        'required': required,
        'current': current,
        'isMet': isMet,
        'remaining': remaining,
      };

  factory TierRequirementCheck.fromJson(Map<String, dynamic> json) {
    return TierRequirementCheck(
      requirement: json['requirement'] as String,
      required: json['required'] as int,
      current: json['current'] as int,
      isMet: json['isMet'] as bool,
      remaining: json['remaining'] as int? ?? 0,
    );
  }
}
