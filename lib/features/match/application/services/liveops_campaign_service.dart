import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/services/remote_config_service.dart';

/// Service for managing LiveOps campaigns and seasonal events
///
/// Handles:
/// - Fetch active campaigns from Firestore
/// - Track campaign participation
/// - Manage seasonal event rewards
/// - Update campaign status via Remote Config
class LiveOpsCampaignService {
  final FirebaseFirestore _firestore;
  final RemoteConfigService _remoteConfig;

  LiveOpsCampaignService({
    FirebaseFirestore? firestore,
    required RemoteConfigService remoteConfig,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _remoteConfig = remoteConfig;

  /// Fetch all active campaigns
  ///
  /// Active = currently_live: true AND now > startTime AND now < endTime
  Future<List<Campaign>> fetchActiveCampaigns() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('campaigns')
          .where('currently_live', isEqualTo: true)
          .where('start_time', isLessThanOrEqualTo: now)
          .where('end_time', isGreaterThan: now)
          .orderBy('start_time', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs
          .map((doc) => Campaign.fromFirestore(doc))
          .toList();
    } catch (e) {
      // On error, return empty list (no active campaigns)
      return [];
    }
  }

  /// Fetch featured campaign (highest priority)
  ///
  /// Displayed on home screen banner.
  Future<Campaign?> fetchFeaturedCampaign() async {
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .where('currently_live', isEqualTo: true)
          .where('is_featured', isEqualTo: true)
          .where('start_time', isLessThanOrEqualTo: DateTime.now())
          .where('end_time', isGreaterThan: DateTime.now())
          .orderBy('priority', descending: true)
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      if (snapshot.docs.isEmpty) return null;
      return Campaign.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  /// Stream active campaigns for real-time updates
  ///
  /// Provides live updates when campaigns are added/removed/modified.
  Stream<List<Campaign>> streamActiveCampaigns() {
    try {
      final now = DateTime.now();
      return _firestore
          .collection('campaigns')
          .where('currently_live', isEqualTo: true)
          .where('start_time', isLessThanOrEqualTo: now)
          .where('end_time', isGreaterThan: now)
          .orderBy('start_time', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Campaign.fromFirestore(doc))
              .toList())
          .handleError((_) => <Campaign>[]);
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Fetch rewards for a specific campaign
  Future<List<CampaignReward>> fetchCampaignRewards(String campaignId) async {
    try {
      final snapshot = await _firestore
          .collection('campaigns')
          .doc(campaignId)
          .collection('rewards')
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs
          .map((doc) => CampaignReward.fromFirestore(doc))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Track campaign participation
  ///
  /// Called when player interacts with campaign (claim reward, complete challenge, etc).
  Future<void> trackCampaignParticipation({
    required String userId,
    required String campaignId,
    required String eventType, // 'viewed', 'claimed_reward', 'completed_challenge'
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('campaign_participation')
          .add({
            'campaign_id': campaignId,
            'event_type': eventType,
            'timestamp': DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Silent fail — participation tracking is not critical
    }
  }

  /// Get user's campaign progress for a specific campaign
  ///
  /// Example: "3/5 challenges completed" or "Reward claimed"
  Future<CampaignProgress?> getUserCampaignProgress({
    required String userId,
    required String campaignId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('campaign_progress')
          .doc(campaignId)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!snapshot.exists) return null;
      return CampaignProgress.fromFirestore(snapshot);
    } catch (e) {
      return null;
    }
  }

  /// Claim campaign reward
  ///
  /// Updates user's cosmetics and marks campaign as claimed.
  Future<bool> claimCampaignReward({
    required String userId,
    required String campaignId,
    required String rewardId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('campaign_progress')
          .doc(campaignId)
          .update({
            'claimed_rewards': FieldValue.arrayUnion([rewardId]),
            'reward_claimed_at': DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 10));

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get special event bonuses (e.g., weekend double points, holiday events)
  ///
  /// Read from Remote Config for easy LiveOps adjustment without redeployment.
  Future<SpecialEventBonuses> getSpecialEventBonuses() async {
    try {
      // Fetch from Remote Config
      final streakMultiplier = _remoteConfig.getString('weekend_streak_multiplier');
      final cosmeticDropRate = _remoteConfig.getString('special_event_cosmetic_drop_rate');
      final bonusMatchRewards = _remoteConfig.getString('holiday_bonus_match_rewards');

      return SpecialEventBonuses(
        streakMultiplier: double.tryParse(streakMultiplier) ?? 1.0,
        cosmeticDropRateIncrease:
            double.tryParse(cosmeticDropRate) ?? 0.0, // Additional %
        bonusMatchRewardsMultiplier:
            double.tryParse(bonusMatchRewards) ?? 1.0,
        isActive: true,
      );
    } catch (e) {
      // Default: no bonuses
      return SpecialEventBonuses(
        streakMultiplier: 1.0,
        cosmeticDropRateIncrease: 0.0,
        bonusMatchRewardsMultiplier: 1.0,
        isActive: false,
      );
    }
  }

  /// Log campaign analytics
  ///
  /// Tracks which campaigns drive engagement and conversion.
  Future<void> logCampaignAnalytics({
    required String userId,
    required String campaignId,
    required String eventType, // 'view', 'click', 'reward_claim'
  }) async {
    try {
      // Could fire Firebase Analytics event here
      // analytics.logEvent(
      //   name: 'campaign_interaction',
      //   parameters: {
      //     'campaign_id': campaignId,
      //     'event_type': eventType,
      //   },
      // );
    } catch (e) {
      // Silent fail
    }
  }
}

/// Campaign model
class Campaign {
  final String id;
  final String name;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool currentlyLive;
  final bool isFeatured;
  final int priority; // Lower number = higher priority
  final String? bannerImageUrl;
  final String? campaignType; // 'seasonal', 'promotional', 'limited_time'
  final List<String>? cosmeticRewards;

  Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.currentlyLive,
    required this.isFeatured,
    required this.priority,
    this.bannerImageUrl,
    this.campaignType,
    this.cosmeticRewards,
  });

  bool get isActive =>
      currentlyLive &&
      DateTime.now().isAfter(startTime) &&
      DateTime.now().isBefore(endTime);

  static Campaign fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Campaign(
      id: doc.id,
      name: data['name'] ?? 'Campaign',
      description: data['description'] ?? '',
      startTime: DateTime.parse(data['start_time'] ?? '2026-09-02'),
      endTime: DateTime.parse(data['end_time'] ?? '2026-12-31'),
      currentlyLive: data['currently_live'] ?? false,
      isFeatured: data['is_featured'] ?? false,
      priority: data['priority'] ?? 999,
      bannerImageUrl: data['banner_image_url'],
      campaignType: data['campaign_type'],
      cosmeticRewards:
          List<String>.from(data['cosmetic_rewards'] ?? []),
    );
  }
}

/// Campaign reward model
class CampaignReward {
  final String id;
  final String campaignId;
  final String rewardType; // 'cosmetic', 'cosmetic_voucher', 'rank_points'
  final String rewardId;
  final String description;
  final int? quantity;

  CampaignReward({
    required this.id,
    required this.campaignId,
    required this.rewardType,
    required this.rewardId,
    required this.description,
    this.quantity,
  });

  static CampaignReward fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampaignReward(
      id: doc.id,
      campaignId: data['campaign_id'] ?? '',
      rewardType: data['reward_type'] ?? 'cosmetic',
      rewardId: data['reward_id'] ?? '',
      description: data['description'] ?? '',
      quantity: data['quantity'],
    );
  }
}

/// User's campaign progress
class CampaignProgress {
  final String campaignId;
  final List<String> claimedRewards;
  final DateTime? rewardClaimedAt;
  final int challengesCompleted;
  final int challengesRequired;

  CampaignProgress({
    required this.campaignId,
    required this.claimedRewards,
    this.rewardClaimedAt,
    required this.challengesCompleted,
    required this.challengesRequired,
  });

  bool get hasClaimedReward => claimedRewards.isNotEmpty;

  static CampaignProgress fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CampaignProgress(
      campaignId: doc.id,
      claimedRewards: List<String>.from(data['claimed_rewards'] ?? []),
      rewardClaimedAt: data['reward_claimed_at'] != null
          ? DateTime.parse(data['reward_claimed_at'] as String)
          : null,
      challengesCompleted: data['challenges_completed'] ?? 0,
      challengesRequired: data['challenges_required'] ?? 1,
    );
  }
}

/// Special event bonuses (e.g., weekend multipliers, holiday events)
class SpecialEventBonuses {
  final double streakMultiplier; // e.g., 2.0 for weekend double points
  final double cosmeticDropRateIncrease; // e.g., 0.05 for +5% drop rate
  final double bonusMatchRewardsMultiplier; // e.g., 1.5 for 50% bonus rewards
  final bool isActive;

  SpecialEventBonuses({
    required this.streakMultiplier,
    required this.cosmeticDropRateIncrease,
    required this.bonusMatchRewardsMultiplier,
    required this.isActive,
  });
}
