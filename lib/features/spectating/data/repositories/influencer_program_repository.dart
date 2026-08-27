import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/spectating/domain/models/influencer_program.dart';

/// Repository for influencer program management
///
/// Handles streamer verification, tier upgrades, referral tracking,
/// analytics aggregation, and monetization calculations.
class InfluencerProgramRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  // Tier upgrade requirements (configurable via Remote Config)
  static const Map<StreamerTier, VerificationRequirements> _tierRequirements = {
    StreamerTier.affiliate: VerificationRequirements(
      tier: StreamerTier.affiliate,
      minFollowers: 100,
      minTotalStreams: 10,
      minAvgViewers: 5,
      minStreakDays: 7,
      requiresBankAccount: true,
      requiresIdentityVerification: false,
      restrictions: [],
    ),
    StreamerTier.partner: VerificationRequirements(
      tier: StreamerTier.partner,
      minFollowers: 1000,
      minTotalStreams: 50,
      minAvgViewers: 25,
      minStreakDays: 30,
      requiresBankAccount: true,
      requiresIdentityVerification: true,
      restrictions: [],
    ),
    StreamerTier.premium: VerificationRequirements(
      tier: StreamerTier.premium,
      minFollowers: 10000,
      minTotalStreams: 200,
      minAvgViewers: 100,
      minStreakDays: 90,
      requiresBankAccount: true,
      requiresIdentityVerification: true,
      restrictions: [],
    ),
  };

  InfluencerProgramRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  /// Get streamer verification status
  Future<StreamerVerification> getStreamerVerification(String userId) async {
    final doc =
        await _firestore.collection('streamerVerifications').doc(userId).get();

    if (!doc.exists) {
      // Create default unverified entry
      return StreamerVerification(
        userId: userId,
        tier: StreamerTier.unverified,
        isVerified: false,
        followerCount: 0,
        totalStreams: 0,
        avgViewerCount: 0,
        avgStreamDuration: 0,
      );
    }

    return StreamerVerification.fromJson(doc.data()!);
  }

  /// Check tier upgrade eligibility
  Future<TierUpgradeEligibility> checkTierUpgradeEligibility(
    String userId,
    StreamerTier nextTier,
  ) async {
    final verification = await getStreamerVerification(userId);
    final requirements = _tierRequirements[nextTier];

    if (requirements == null) {
      return const TierUpgradeEligibility(
        nextTier: StreamerTier.premium,
        isEligible: false,
      );
    }

    final checks = <TierRequirementCheck>[
      TierRequirementCheck(
        requirement: 'Followers',
        required: requirements.minFollowers,
        current: verification.followerCount,
        isMet: verification.followerCount >= requirements.minFollowers,
        remaining:
            (requirements.minFollowers - verification.followerCount).clamp(0, double.infinity).toInt(),
      ),
      TierRequirementCheck(
        requirement: 'Total Streams',
        required: requirements.minTotalStreams,
        current: verification.totalStreams,
        isMet: verification.totalStreams >= requirements.minTotalStreams,
        remaining:
            (requirements.minTotalStreams - verification.totalStreams).clamp(0, double.infinity).toInt(),
      ),
      TierRequirementCheck(
        requirement: 'Average Viewers',
        required: requirements.minAvgViewers.toInt(),
        current: verification.avgViewerCount.toInt(),
        isMet: verification.avgViewerCount >= requirements.minAvgViewers,
        remaining: 0,
      ),
    ];

    final allMet = checks.every((c) => c.isMet);

    return TierUpgradeEligibility(
      nextTier: nextTier,
      isEligible: allMet,
      missingRequirements: checks.where((c) => !c.isMet).toList(),
    );
  }

  /// Upgrade streamer to next tier
  Future<void> upgradeStreamerTier(
    String userId,
    StreamerTier newTier,
  ) async {
    final now = DateTime.now();

    await _firestore.collection('streamerVerifications').doc(userId).update({
      'tier': newTier.name,
      'tierUpgradedAt': now,
      'isVerified': true,
    });

    // Log analytics
    await _logInfluencerEvent(
      userId: userId,
      eventType: 'tier_upgraded',
      parameters: {
        'newTier': newTier.label,
        'revenueShare': newTier.revenueShare,
      },
    );
  }

  /// Create referral code for streamer
  Future<String> createReferralCode(String referrerId) async {
    // Generate unique referral code (format: REF_USERID_RANDOM)
    final random =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final referralCode = 'REF_${referrerId}_$random';

    final record = ReferralRecord(
      id: referralCode,
      referrerId: referrerId,
      referredUserId: '',
      referredAt: DateTime.now(),
      referralCode: referralCode,
      referralBonus: 500, // ¥500 one-time bonus
      commissionRate: 0.05, // 5% ongoing commission
      status: ReferralStatus.pending,
    );

    await _firestore
        .collection('referralRecords')
        .doc(referralCode)
        .set(record.toJson());

    return referralCode;
  }

  /// Claim referral bonus
  Future<void> claimReferral(
    String referralCode,
    String newUserId,
  ) async {
    final doc =
        await _firestore.collection('referralRecords').doc(referralCode).get();

    if (!doc.exists) {
      throw Exception('Invalid referral code');
    }

    final record = ReferralRecord.fromJson(doc.data()!);

    if (record.status != ReferralStatus.pending) {
      throw Exception('Referral code already used');
    }

    // Update referral record
    await _firestore.collection('referralRecords').doc(referralCode).update({
      'referredUserId': newUserId,
      'status': ReferralStatus.active.name,
      'activatedAt': DateTime.now(),
    });

    // Award bonus to referrer
    await _firestore
        .collection('users')
        .doc(record.referrerId)
        .update({
      'referralBonusBalance': FieldValue.increment(record.referralBonus),
      'totalReferrals': FieldValue.increment(1),
    });

    // Log analytics
    await _logInfluencerEvent(
      userId: record.referrerId,
      eventType: 'referral_claimed',
      parameters: {
        'referralCode': referralCode,
        'newUserId': newUserId,
        'bonus': record.referralBonus,
      },
    );
  }

  /// Get referral history for streamer
  Stream<List<ReferralRecord>> watchStreamerReferrals(String referrerId) {
    return _firestore
        .collection('referralRecords')
        .where('referrerId', isEqualTo: referrerId)
        .orderBy('referredAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReferralRecord.fromJson({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  /// Calculate streamer analytics for period
  Future<StreamerAnalytics> getStreamerAnalytics({
    required String userId,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    // Aggregate from streaming sessions
    final sessions = await _firestore
        .collection('streamingSessions')
        .where('userId', isEqualTo: userId)
        .where('startedAt', isGreaterThanOrEqualTo: periodStart)
        .where('startedAt', isLessThanOrEqualTo: periodEnd)
        .get();

    int totalStreamMinutes = 0;
    int totalViewerMinutes = 0;
    int peakViewers = 0;
    int totalClips = 0;
    int totalClipViews = 0;
    double streamingRevenue = 0.0;
    double clipRevenue = 0.0;

    for (final doc in sessions.docs) {
      final data = doc.data();
      final startedAt = (data['startedAt'] as Timestamp).toDate();
      final endedAt = data['endedAt'] != null
          ? (data['endedAt'] as Timestamp).toDate()
          : DateTime.now();

      final duration = endedAt.difference(startedAt).inMinutes;
      totalStreamMinutes += duration;

      final viewerCount = (data['viewerCount'] as int?) ?? 0;
      totalViewerMinutes += viewerCount * duration;

      if (viewerCount > peakViewers) {
        peakViewers = viewerCount;
      }

      final clips = (data['generatedHighlights'] as List<dynamic>?) ?? [];
      totalClips += clips.length;

      // Calculate clip revenue
      for (final clip in clips) {
        final views = (clip['viewCount'] as int?) ?? 0;
        totalClipViews += views;
        clipRevenue += views * 5.0; // ¥5 per clip view
      }

      streamingRevenue += duration * 10.0; // ¥10 per minute
    }

    // Get affiliate commissions from referrals
    double affiliateCommission = 0.0;
    final referrals = await _firestore
        .collection('referralRecords')
        .where('referrerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (final doc in referrals.docs) {
      final commission = (doc.data()['totalCommissionEarned'] as int?) ?? 0;
      affiliateCommission += commission;
    }

    final totalRevenue = streamingRevenue + clipRevenue + affiliateCommission;
    final avgViewers =
        totalStreamMinutes > 0 ? (totalViewerMinutes / totalStreamMinutes).toInt() : 0;

    return StreamerAnalytics(
      userId: userId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      totalStreams: sessions.docs.length,
      totalStreamMinutes: totalStreamMinutes,
      totalViewerMinutes: totalViewerMinutes,
      peakViewerCount: peakViewers,
      avgViewerCount: avgViewers,
      totalClips: totalClips,
      totalClipViews: totalClipViews,
      streamingRevenue: streamingRevenue,
      clipRevenue: clipRevenue,
      affiliateCommission: affiliateCommission,
      totalRevenue: totalRevenue,
    );
  }

  /// Get top streamers leaderboard
  Future<List<StreamerLeaderboardEntry>> getStreamerLeaderboard({
    required String metric,
    int limit = 50,
  }) async {
    final query = await _firestore
        .collection('streamerVerifications')
        .where('isVerified', isEqualTo: true)
        .limit(limit)
        .get();

    List<StreamerLeaderboardEntry> entries = [];

    for (int i = 0; i < query.docs.length; i++) {
      final doc = query.docs[i];
      final verification = StreamerVerification.fromJson(doc.data());

      int score = 0;
      switch (metric) {
        case 'viewers':
          score = verification.avgViewerCount.toInt();
          break;
        case 'followers':
          score = verification.followerCount;
          break;
        case 'streams':
          score = verification.totalStreams;
          break;
        default:
          score = verification.followerCount;
      }

      entries.add(StreamerLeaderboardEntry(
        userId: verification.userId,
        displayName: 'Streamer ${i + 1}', // TODO: Get from user profile
        rank: i + 1,
        score: score,
        scoreMetric: metric,
        tier: verification.tier,
      ));
    }

    return entries;
  }

  /// Award badge to streamer
  Future<void> awardBadge(
    String userId,
    StreamerBadgeType type,
    String name,
    String emoji,
    String description,
  ) async {
    final badge = StreamerBadge(
      id: '${userId}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      description: description,
      unlockedAt: DateTime.now(),
      type: type,
    );

    await _firestore
        .collection('streamerVerifications')
        .doc(userId)
        .collection('badges')
        .doc(badge.id)
        .set(badge.toJson());

    await _firestore
        .collection('streamerVerifications')
        .doc(userId)
        .update({
      'badges': FieldValue.arrayUnion([badge.id]),
    });

    // Log analytics
    await _logInfluencerEvent(
      userId: userId,
      eventType: 'badge_awarded',
      parameters: {
        'badgeName': name,
        'badgeType': type.label,
      },
    );
  }

  /// Update affiliate commission from referral
  Future<void> updateReferralCommission(
    String referralCode,
    int commission,
  ) async {
    await _firestore
        .collection('referralRecords')
        .doc(referralCode)
        .update({
      'totalCommissionEarned': FieldValue.increment(commission),
      'lastCommissionAt': DateTime.now(),
    });
  }

  /// Get monthly earnings breakdown
  Future<Map<String, dynamic>> getMonthlyEarningsBreakdown(
    String userId,
    int year,
    int month,
  ) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 1);

    final analytics = await getStreamerAnalytics(
      userId: userId,
      periodStart: startDate,
      periodEnd: endDate,
    );

    return {
      'year': year,
      'month': month,
      'streamingRevenue': analytics.streamingRevenue,
      'clipRevenue': analytics.clipRevenue,
      'affiliateCommission': analytics.affiliateCommission,
      'totalRevenue': analytics.totalRevenue,
      'platformFee': analytics.totalRevenue * 0.3, // 30% platform fee
      'streamerPayout':
          analytics.totalRevenue * 0.7, // 70% to streamer (before revenue share)
      'streamer30DayRetention': 0.0, // TODO: Calculate from retention data
    };
  }

  /// Check streamer suspension status
  Future<bool> isStreamerSuspended(String userId) async {
    final verification = await getStreamerVerification(userId);
    return verification.isSuspended;
  }

  /// Suspend streamer account
  Future<void> suspendStreamer(
    String userId,
    String reason,
  ) async {
    await _firestore
        .collection('streamerVerifications')
        .doc(userId)
        .update({
      'isSuspended': true,
      'suspensionReason': reason,
      'suspendedAt': DateTime.now(),
    });

    // Log analytics
    await _logInfluencerEvent(
      userId: userId,
      eventType: 'streamer_suspended',
      parameters: {
        'reason': reason,
      },
    );
  }

  /// Log influencer program analytics event
  Future<void> _logInfluencerEvent({
    required String userId,
    required String eventType,
    required Map<String, dynamic> parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventType,
        parameters: {
          'userId': userId,
          ...parameters,
        },
      );
    } catch (e) {
      print('Analytics logging failed: $e');
    }
  }
}
