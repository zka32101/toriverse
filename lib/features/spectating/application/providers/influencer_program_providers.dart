import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/data/repositories/influencer_program_repository.dart';
import 'package:toriverse/features/spectating/domain/models/influencer_program.dart';

/// Influencer program repository provider for dependency injection
final influencerProgramRepositoryProvider = Provider((ref) {
  return InfluencerProgramRepository();
});

/// Get streamer verification status
final streamerVerificationProvider = FutureProvider.family<StreamerVerification, String>((ref, userId) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.getStreamerVerification(userId);
});

/// Check tier upgrade eligibility
final tierUpgradeEligibilityProvider = FutureProvider.family<TierUpgradeEligibility, _CheckTierEligibilityParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.checkTierUpgradeEligibility(params.userId, params.nextTier);
});

/// Upgrade streamer tier
final upgradeStreamerTierProvider = FutureProvider.autoDispose.family<void, _UpgradeStreamerTierParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.upgradeStreamerTier(params.userId, params.newTier);
});

/// Create referral code
final createReferralCodeProvider =
    FutureProvider.autoDispose.family<String, String>((ref, referrerId) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.createReferralCode(referrerId);
});

/// Claim referral bonus
final claimReferralProvider = FutureProvider.autoDispose.family<void, _ClaimReferralParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.claimReferral(params.referralCode, params.newUserId);
});

/// Watch streamer referrals
final streamerReferralsProvider = StreamProvider.family<List<ReferralRecord>, String>((ref, referrerId) {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.watchStreamerReferrals(referrerId);
});

/// Get streamer analytics
final streamerAnalyticsProvider = FutureProvider.family<StreamerAnalytics, _GetAnalyticsParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.getStreamerAnalytics(
    userId: params.userId,
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});

/// Get streamer leaderboard
final streamerLeaderboardProvider = FutureProvider.family<List<StreamerLeaderboardEntry>, _GetLeaderboardParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.getStreamerLeaderboard(
    metric: params.metric,
    limit: params.limit,
  );
});

/// Award badge to streamer
final awardBadgeProvider = FutureProvider.autoDispose.family<void, _AwardBadgeParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.awardBadge(
    params.userId,
    params.type,
    params.name,
    params.emoji,
    params.description,
  );
});

/// Get monthly earnings breakdown
final monthlyEarningsBreakdownProvider = FutureProvider.family<Map<String, dynamic>, _GetMonthlyEarningsParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.getMonthlyEarningsBreakdown(
    params.userId,
    params.year,
    params.month,
  );
});

/// Check if streamer is suspended
final streamerSuspensionStatusProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.isStreamerSuspended(userId);
});

/// Suspend streamer account
final suspendStreamerProvider = FutureProvider.autoDispose.family<void, _SuspendStreamerParams>((ref, params) async {
  final repo = ref.watch(influencerProgramRepositoryProvider);
  return repo.suspendStreamer(params.userId, params.reason);
});

// ============================================================================
// Parameter classes
// ============================================================================

/// Parameters for checking tier upgrade eligibility
class _CheckTierEligibilityParams {
  final String userId;
  final StreamerTier nextTier;

  _CheckTierEligibilityParams({
    required this.userId,
    required this.nextTier,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CheckTierEligibilityParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          nextTier == other.nextTier;

  @override
  int get hashCode => userId.hashCode ^ nextTier.hashCode;
}

/// Parameters for upgrading streamer tier
class _UpgradeStreamerTierParams {
  final String userId;
  final StreamerTier newTier;

  _UpgradeStreamerTierParams({
    required this.userId,
    required this.newTier,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _UpgradeStreamerTierParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          newTier == other.newTier;

  @override
  int get hashCode => userId.hashCode ^ newTier.hashCode;
}

/// Parameters for claiming referral
class _ClaimReferralParams {
  final String referralCode;
  final String newUserId;

  _ClaimReferralParams({
    required this.referralCode,
    required this.newUserId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClaimReferralParams &&
          runtimeType == other.runtimeType &&
          referralCode == other.referralCode &&
          newUserId == other.newUserId;

  @override
  int get hashCode => referralCode.hashCode ^ newUserId.hashCode;
}

/// Parameters for getting analytics
class _GetAnalyticsParams {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;

  _GetAnalyticsParams({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetAnalyticsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          periodStart == other.periodStart &&
          periodEnd == other.periodEnd;

  @override
  int get hashCode => userId.hashCode ^ periodStart.hashCode ^ periodEnd.hashCode;
}

/// Parameters for getting leaderboard
class _GetLeaderboardParams {
  final String metric;
  final int limit;

  _GetLeaderboardParams({
    required this.metric,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetLeaderboardParams &&
          runtimeType == other.runtimeType &&
          metric == other.metric &&
          limit == other.limit;

  @override
  int get hashCode => metric.hashCode ^ limit.hashCode;
}

/// Parameters for awarding badge
class _AwardBadgeParams {
  final String userId;
  final StreamerBadgeType type;
  final String name;
  final String emoji;
  final String description;

  _AwardBadgeParams({
    required this.userId,
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AwardBadgeParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          type == other.type &&
          name == other.name &&
          emoji == other.emoji &&
          description == other.description;

  @override
  int get hashCode =>
      userId.hashCode ^
      type.hashCode ^
      name.hashCode ^
      emoji.hashCode ^
      description.hashCode;
}

/// Parameters for getting monthly earnings
class _GetMonthlyEarningsParams {
  final String userId;
  final int year;
  final int month;

  _GetMonthlyEarningsParams({
    required this.userId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _GetMonthlyEarningsParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => userId.hashCode ^ year.hashCode ^ month.hashCode;
}

/// Parameters for suspending streamer
class _SuspendStreamerParams {
  final String userId;
  final String reason;

  _SuspendStreamerParams({
    required this.userId,
    required this.reason,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SuspendStreamerParams &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          reason == other.reason;

  @override
  int get hashCode => userId.hashCode ^ reason.hashCode;
}
