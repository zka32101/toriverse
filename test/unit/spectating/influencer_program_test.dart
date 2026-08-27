import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/spectating/domain/models/influencer_program.dart';

void main() {
  group('StreamerVerification', () {
    test('creates verification with correct data', () {
      final verification = StreamerVerification(
        userId: 'user_123',
        tier: StreamerTier.affiliate,
        isVerified: true,
        followerCount: 500,
        totalStreams: 25,
        avgViewerCount: 30.0,
        avgStreamDuration: 45.0,
      );

      expect(verification.userId, 'user_123');
      expect(verification.tier, StreamerTier.affiliate);
      expect(verification.isVerified, true);
      expect(verification.followerCount, 500);
    });

    test('serializes verification to JSON', () {
      final verification = StreamerVerification(
        userId: 'user_123',
        tier: StreamerTier.partner,
        isVerified: true,
        followerCount: 1500,
        totalStreams: 50,
        avgViewerCount: 75.0,
        avgStreamDuration: 50.0,
      );

      final json = verification.toJson();
      expect(json['userId'], 'user_123');
      expect(json['tier'], 'partner');
      expect(json['isVerified'], true);
    });

    test('deserializes verification from JSON', () {
      final json = {
        'userId': 'user_123',
        'tier': 'premium',
        'isVerified': true,
        'followerCount': 15000,
        'totalStreams': 200,
        'avgViewerCount': 250.0,
        'avgStreamDuration': 60.0,
      };

      final verification = StreamerVerification.fromJson(json);
      expect(verification.userId, 'user_123');
      expect(verification.tier, StreamerTier.premium);
    });
  });

  group('StreamerTier Extension', () {
    test('returns correct labels', () {
      expect(StreamerTier.unverified.label, 'Unverified');
      expect(StreamerTier.affiliate.label, 'Affiliate');
      expect(StreamerTier.partner.label, 'Partner');
      expect(StreamerTier.premium.label, 'Premium');
    });

    test('returns correct revenue shares', () {
      expect(StreamerTier.unverified.revenueShare, 0.0);
      expect(StreamerTier.affiliate.revenueShare, 0.2);
      expect(StreamerTier.partner.revenueShare, 0.3);
      expect(StreamerTier.premium.revenueShare, 0.4);
    });

    test('returns correct icons', () {
      expect(StreamerTier.unverified.icon, '🔒');
      expect(StreamerTier.affiliate.icon, '⭐');
      expect(StreamerTier.partner.icon, '💫');
      expect(StreamerTier.premium.icon, '👑');
    });

    test('canMonetize returns correct values', () {
      expect(StreamerTier.unverified.canMonetize, false);
      expect(StreamerTier.affiliate.canMonetize, true);
      expect(StreamerTier.partner.canMonetize, true);
      expect(StreamerTier.premium.canMonetize, true);
    });

    test('permission methods return correct values', () {
      expect(StreamerTier.unverified.canEarnAffiliateCommission, false);
      expect(StreamerTier.affiliate.canEarnAffiliateCommission, true);
      expect(StreamerTier.partner.canEarnPartnerBonus, true);
      expect(StreamerTier.premium.canEarnPremiumBonus, true);
    });
  });

  group('ReferralRecord', () {
    test('creates referral with correct data', () {
      final now = DateTime.now();
      final record = ReferralRecord(
        id: 'ref_123',
        referrerId: 'streamer_1',
        referredUserId: 'user_new',
        referredAt: now,
        referralCode: 'REF_STREAMER_ABC123',
        referralBonus: 500,
        commissionRate: 0.05,
        status: ReferralStatus.active,
      );

      expect(record.id, 'ref_123');
      expect(record.referrerId, 'streamer_1');
      expect(record.referralBonus, 500);
      expect(record.commissionRate, 0.05);
    });

    test('serializes referral to JSON', () {
      final record = ReferralRecord(
        id: 'ref_123',
        referrerId: 'streamer_1',
        referredUserId: 'user_new',
        referredAt: DateTime.now(),
        referralCode: 'REF_STREAMER_ABC123',
        referralBonus: 500,
        commissionRate: 0.05,
      );

      final json = record.toJson();
      expect(json['id'], 'ref_123');
      expect(json['referralBonus'], 500);
      expect(json['commissionRate'], 0.05);
    });

    test('deserializes referral from JSON', () {
      final json = {
        'id': 'ref_123',
        'referrerId': 'streamer_1',
        'referredUserId': 'user_new',
        'referredAt': DateTime.now().toIso8601String(),
        'referralCode': 'REF_STREAMER_ABC123',
        'referralBonus': 500,
        'commissionRate': 0.05,
        'status': 'active',
      };

      final record = ReferralRecord.fromJson(json);
      expect(record.id, 'ref_123');
      expect(record.referralBonus, 500);
    });
  });

  group('ReferralStatus Extension', () {
    test('returns correct labels', () {
      expect(ReferralStatus.pending.label, 'Pending');
      expect(ReferralStatus.active.label, 'Active');
      expect(ReferralStatus.inactive.label, 'Inactive');
      expect(ReferralStatus.expired.label, 'Expired');
    });

    test('isEarning returns correct values', () {
      expect(ReferralStatus.pending.isEarning, false);
      expect(ReferralStatus.active.isEarning, true);
      expect(ReferralStatus.inactive.isEarning, false);
    });
  });

  group('StreamerAnalytics', () {
    test('creates analytics with correct data', () {
      final now = DateTime.now();
      final analytics = StreamerAnalytics(
        userId: 'user_123',
        periodStart: now.subtract(const Duration(days: 30)),
        periodEnd: now,
        totalStreams: 15,
        totalStreamMinutes: 750,
        totalViewerMinutes: 22500,
        peakViewerCount: 150,
        avgViewerCount: 30,
        totalClips: 8,
        totalClipViews: 2000,
        streamingRevenue: 7500.0,
        clipRevenue: 10000.0,
        affiliateCommission: 2500.0,
        totalRevenue: 20000.0,
      );

      expect(analytics.userId, 'user_123');
      expect(analytics.totalStreams, 15);
      expect(analytics.totalRevenue, 20000.0);
    });

    test('serializes analytics to JSON', () {
      final analytics = StreamerAnalytics(
        userId: 'user_123',
        periodStart: DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: DateTime.now(),
        totalStreamMinutes: 750,
        streamingRevenue: 7500.0,
      );

      final json = analytics.toJson();
      expect(json['userId'], 'user_123');
      expect(json['totalStreamMinutes'], 750);
      expect(json['streamingRevenue'], 7500.0);
    });

    test('deserializes analytics from JSON', () {
      final now = DateTime.now();
      final json = {
        'userId': 'user_123',
        'periodStart': now.subtract(const Duration(days: 30)).toIso8601String(),
        'periodEnd': now.toIso8601String(),
        'totalStreams': 15,
        'totalStreamMinutes': 750,
        'streamingRevenue': 7500.0,
        'totalRevenue': 20000.0,
      };

      final analytics = StreamerAnalytics.fromJson(json);
      expect(analytics.userId, 'user_123');
      expect(analytics.streamingRevenue, 7500.0);
    });
  });

  group('StreamerBadge', () {
    test('creates badge with correct data', () {
      final now = DateTime.now();
      final badge = StreamerBadge(
        id: 'badge_001',
        name: '100 Hours Streamed',
        emoji: '⏰',
        description: 'Streamed for 100+ hours',
        unlockedAt: now,
        type: StreamerBadgeType.milestone,
      );

      expect(badge.id, 'badge_001');
      expect(badge.name, '100 Hours Streamed');
      expect(badge.type, StreamerBadgeType.milestone);
    });

    test('serializes badge to JSON', () {
      final badge = StreamerBadge(
        id: 'badge_001',
        name: '100 Hours',
        emoji: '⏰',
        description: 'Streamed 100 hours',
        unlockedAt: DateTime.now(),
        type: StreamerBadgeType.milestone,
      );

      final json = badge.toJson();
      expect(json['id'], 'badge_001');
      expect(json['emoji'], '⏰');
      expect(json['type'], 'milestone');
    });

    test('deserializes badge from JSON', () {
      final json = {
        'id': 'badge_001',
        'name': '100 Hours',
        'emoji': '⏰',
        'description': 'Streamed 100 hours',
        'unlockedAt': DateTime.now().toIso8601String(),
        'type': 'milestone',
      };

      final badge = StreamerBadge.fromJson(json);
      expect(badge.id, 'badge_001');
      expect(badge.emoji, '⏰');
    });
  });

  group('StreamerLeaderboardEntry', () {
    test('creates leaderboard entry with correct data', () {
      final entry = StreamerLeaderboardEntry(
        userId: 'user_123',
        displayName: 'TopStreamer',
        rank: 1,
        score: 50000,
        scoreMetric: 'viewers',
        tier: StreamerTier.premium,
      );

      expect(entry.rank, 1);
      expect(entry.score, 50000);
      expect(entry.scoreMetric, 'viewers');
      expect(entry.tier, StreamerTier.premium);
    });
  });

  group('TierUpgradeEligibility', () {
    test('creates eligibility with missing requirements', () {
      final checks = [
        TierRequirementCheck(
          requirement: 'Followers',
          required: 1000,
          current: 500,
          isMet: false,
          remaining: 500,
        ),
      ];

      final eligibility = TierUpgradeEligibility(
        nextTier: StreamerTier.partner,
        isEligible: false,
        missingRequirements: checks,
        daysUntilEligible: 30,
      );

      expect(eligibility.isEligible, false);
      expect(eligibility.missingRequirements.length, 1);
      expect(eligibility.daysUntilEligible, 30);
    });

    test('creates eligibility with all requirements met', () {
      final eligibility = TierUpgradeEligibility(
        nextTier: StreamerTier.partner,
        isEligible: true,
        missingRequirements: const [],
        daysUntilEligible: 0,
      );

      expect(eligibility.isEligible, true);
      expect(eligibility.missingRequirements.isEmpty, true);
    });
  });
}
