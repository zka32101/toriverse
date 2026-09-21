
// Enums
enum ReportReason { harassment, spam, abuse, misinformation, copyright, other }

enum ContentModerationReason { explicit, spam, misinformation, copyright, hateSpeech }

enum ModerationAction { warn, mute, suspend, ban, contentRemoval }

enum ModerationType { temporary, permanent }

enum NotificationType { matchResult, friendRequest, followerActivity, newClip, liveStream }

enum ReportStatus { open, investigating, resolved, dismissed, appealed }

// Creator Analytics Models

/// Creator dashboard with aggregated metrics
class CreatorAnalyticsDashboard {
  final String creatorId;
  final int totalViews;
  final double totalEarnings;
  final int followerGrowth;
  final double engagementRate;
  final List<Map<String, dynamic>> topContent;
  final Map<String, dynamic> revenueBreakdown;
  final Map<String, dynamic> audienceDemographics;
  final DateTime updatedAt;

  const CreatorAnalyticsDashboard({
    required this.creatorId,
    this.totalViews = 0,
    this.totalEarnings = 0.0,
    this.followerGrowth = 0,
    this.engagementRate = 0.0,
    this.topContent = const [],
    this.revenueBreakdown = const {},
    this.audienceDemographics = const {},
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'creatorId': creatorId,
        'totalViews': totalViews,
        'totalEarnings': totalEarnings,
        'followerGrowth': followerGrowth,
        'engagementRate': engagementRate,
        'topContent': topContent,
        'revenueBreakdown': revenueBreakdown,
        'audienceDemographics': audienceDemographics,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory CreatorAnalyticsDashboard.fromJson(Map<String, dynamic> json) {
    return CreatorAnalyticsDashboard(
      creatorId: json['creatorId'] as String,
      totalViews: json['totalViews'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      followerGrowth: json['followerGrowth'] as int? ?? 0,
      engagementRate: (json['engagementRate'] as num?)?.toDouble() ?? 0.0,
      topContent: json['topContent'] != null
          ? List<Map<String, dynamic>>.from(
              (json['topContent'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : const [],
      revenueBreakdown: json['revenueBreakdown'] != null
          ? Map<String, dynamic>.from(json['revenueBreakdown'] as Map)
          : const {},
      audienceDemographics: json['audienceDemographics'] != null
          ? Map<String, dynamic>.from(json['audienceDemographics'] as Map)
          : const {},
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Individual content performance metrics
class ContentPerformance {
  final String contentId;
  final String contentType;
  final int views;
  final int engagement;
  final int avgWatchDuration;
  final int shareCount;
  final int likeCount;
  final double completionRate;
  final DateTime createdAt;

  const ContentPerformance({
    required this.contentId,
    required this.contentType,
    this.views = 0,
    this.engagement = 0,
    this.avgWatchDuration = 0,
    this.shareCount = 0,
    this.likeCount = 0,
    this.completionRate = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'contentType': contentType,
        'views': views,
        'engagement': engagement,
        'avgWatchDuration': avgWatchDuration,
        'shareCount': shareCount,
        'likeCount': likeCount,
        'completionRate': completionRate,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContentPerformance.fromJson(Map<String, dynamic> json) {
    return ContentPerformance(
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      views: json['views'] as int? ?? 0,
      engagement: json['engagement'] as int? ?? 0,
      avgWatchDuration: json['avgWatchDuration'] as int? ?? 0,
      shareCount: json['shareCount'] as int? ?? 0,
      likeCount: json['likeCount'] as int? ?? 0,
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Aggregated viewer demographics
class AudienceDemographics {
  final String creatorId;
  final Map<String, int> ageGroups;
  final Map<String, int> genders;
  final Map<String, int> regions;
  final Map<String, int> devices;
  final List<String> topCountries;
  final String languagePreference;
  final Map<String, int> activityTimes;
  final DateTime updatedAt;

  const AudienceDemographics({
    required this.creatorId,
    this.ageGroups = const {},
    this.genders = const {},
    this.regions = const {},
    this.devices = const {},
    this.topCountries = const [],
    this.languagePreference = 'en',
    this.activityTimes = const {},
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'creatorId': creatorId,
        'ageGroups': ageGroups,
        'genders': genders,
        'regions': regions,
        'devices': devices,
        'topCountries': topCountries,
        'languagePreference': languagePreference,
        'activityTimes': activityTimes,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory AudienceDemographics.fromJson(Map<String, dynamic> json) {
    return AudienceDemographics(
      creatorId: json['creatorId'] as String,
      ageGroups: json['ageGroups'] != null
          ? Map<String, int>.from(json['ageGroups'] as Map)
          : const {},
      genders: json['genders'] != null ? Map<String, int>.from(json['genders'] as Map) : const {},
      regions: json['regions'] != null ? Map<String, int>.from(json['regions'] as Map) : const {},
      devices: json['devices'] != null ? Map<String, int>.from(json['devices'] as Map) : const {},
      topCountries: json['topCountries'] != null
          ? List<String>.from(json['topCountries'] as List)
          : const [],
      languagePreference: json['languagePreference'] as String? ?? 'en',
      activityTimes: json['activityTimes'] != null
          ? Map<String, int>.from(json['activityTimes'] as Map)
          : const {},
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Revenue breakdown by source and period
class RevenueAnalytics {
  final String creatorId;
  final String period;
  final double totalRevenue;
  final double subscriptionRevenue;
  final double giftRevenue;
  final double clipRevenue;
  final double adRevenue;
  final double fees;
  final double taxes;
  final double netRevenue;
  final double projectedAnnualRevenue;
  final DateTime generatedAt;

  const RevenueAnalytics({
    required this.creatorId,
    required this.period,
    this.totalRevenue = 0.0,
    this.subscriptionRevenue = 0.0,
    this.giftRevenue = 0.0,
    this.clipRevenue = 0.0,
    this.adRevenue = 0.0,
    this.fees = 0.0,
    this.taxes = 0.0,
    this.netRevenue = 0.0,
    this.projectedAnnualRevenue = 0.0,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'creatorId': creatorId,
        'period': period,
        'totalRevenue': totalRevenue,
        'subscriptionRevenue': subscriptionRevenue,
        'giftRevenue': giftRevenue,
        'clipRevenue': clipRevenue,
        'adRevenue': adRevenue,
        'fees': fees,
        'taxes': taxes,
        'netRevenue': netRevenue,
        'projectedAnnualRevenue': projectedAnnualRevenue,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      creatorId: json['creatorId'] as String,
      period: json['period'] as String,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      subscriptionRevenue: (json['subscriptionRevenue'] as num?)?.toDouble() ?? 0.0,
      giftRevenue: (json['giftRevenue'] as num?)?.toDouble() ?? 0.0,
      clipRevenue: (json['clipRevenue'] as num?)?.toDouble() ?? 0.0,
      adRevenue: (json['adRevenue'] as num?)?.toDouble() ?? 0.0,
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      taxes: (json['taxes'] as num?)?.toDouble() ?? 0.0,
      netRevenue: (json['netRevenue'] as num?)?.toDouble() ?? 0.0,
      projectedAnnualRevenue: (json['projectedAnnualRevenue'] as num?)?.toDouble() ?? 0.0,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

// Community Safety Models

/// User report for abuse/spam/harassment
class UserReport {
  final String reportId;
  final String reporterId;
  final String reportedUserId;
  final ReportReason reason;
  final String? description;
  final List<String> evidence;
  final DateTime createdAt;
  final ReportStatus status;
  final String? moderatorNotes;

  const UserReport({
    required this.reportId,
    required this.reporterId,
    required this.reportedUserId,
    required this.reason,
    this.description,
    this.evidence = const [],
    required this.createdAt,
    this.status = ReportStatus.open,
    this.moderatorNotes,
  });

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'reporterId': reporterId,
        'reportedUserId': reportedUserId,
        'reason': reason.index,
        'description': description,
        'evidence': evidence,
        'createdAt': createdAt.toIso8601String(),
        'status': status.index,
        'moderatorNotes': moderatorNotes,
      };

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      reportId: json['reportId'] as String,
      reporterId: json['reporterId'] as String,
      reportedUserId: json['reportedUserId'] as String,
      reason: ReportReason.values[json['reason'] as int],
      description: json['description'] as String?,
      evidence: json['evidence'] != null ? List<String>.from(json['evidence'] as List) : const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] != null ? ReportStatus.values[json['status'] as int] : ReportStatus.open,
      moderatorNotes: json['moderatorNotes'] as String?,
    );
  }
}

/// Content flagged for moderation
class ContentModeration {
  final String contentId;
  final String contentType;
  final ContentModerationReason flagReason;
  final String? description;
  final ReportStatus status;
  final String? moderatorNotes;
  final int reviewCount;
  final DateTime? reviewedAt;

  const ContentModeration({
    required this.contentId,
    required this.contentType,
    required this.flagReason,
    this.description,
    this.status = ReportStatus.open,
    this.moderatorNotes,
    this.reviewCount = 0,
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'contentType': contentType,
        'flagReason': flagReason.index,
        'description': description,
        'status': status.index,
        'moderatorNotes': moderatorNotes,
        'reviewCount': reviewCount,
        'reviewedAt': reviewedAt?.toIso8601String(),
      };

  factory ContentModeration.fromJson(Map<String, dynamic> json) {
    return ContentModeration(
      contentId: json['contentId'] as String,
      contentType: json['contentType'] as String,
      flagReason: ContentModerationReason.values[json['flagReason'] as int],
      description: json['description'] as String?,
      status: json['status'] != null ? ReportStatus.values[json['status'] as int] : ReportStatus.open,
      moderatorNotes: json['moderatorNotes'] as String?,
      reviewCount: json['reviewCount'] as int? ?? 0,
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
    );
  }
}

/// Moderation action taken on user
class CommunityModeration {
  final String moderationId;
  final ModerationAction action;
  final String targetUserId;
  final String actionReason;
  final ModerationType durationType;
  final int durationHours;
  final DateTime createdAt;
  final String? createdBy;
  final bool appealable;
  final String? appealDetails;

  const CommunityModeration({
    required this.moderationId,
    required this.action,
    required this.targetUserId,
    required this.actionReason,
    this.durationType = ModerationType.permanent,
    this.durationHours = 0,
    required this.createdAt,
    this.createdBy,
    this.appealable = true,
    this.appealDetails,
  });

  Map<String, dynamic> toJson() => {
        'moderationId': moderationId,
        'action': action.index,
        'targetUserId': targetUserId,
        'actionReason': actionReason,
        'durationType': durationType.index,
        'durationHours': durationHours,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'appealable': appealable,
        'appealDetails': appealDetails,
      };

  factory CommunityModeration.fromJson(Map<String, dynamic> json) {
    return CommunityModeration(
      moderationId: json['moderationId'] as String,
      action: ModerationAction.values[json['action'] as int],
      targetUserId: json['targetUserId'] as String,
      actionReason: json['actionReason'] as String,
      durationType: json['durationType'] != null
          ? ModerationType.values[json['durationType'] as int]
          : ModerationType.permanent,
      durationHours: json['durationHours'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String?,
      appealable: json['appealable'] as bool? ?? true,
      appealDetails: json['appealDetails'] as String?,
    );
  }
}

// Notification & Engagement Models

/// Push notification
class PushNotification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? deepLink;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool clicked;
  final DateTime? clickedAt;

  const PushNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.deepLink,
    required this.createdAt,
    this.sentAt,
    this.deliveredAt,
    this.readAt,
    this.clicked = false,
    this.clickedAt,
  });

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'type': type.index,
        'title': title,
        'body': body,
        'deepLink': deepLink,
        'createdAt': createdAt.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'deliveredAt': deliveredAt?.toIso8601String(),
        'readAt': readAt?.toIso8601String(),
        'clicked': clicked,
        'clickedAt': clickedAt?.toIso8601String(),
      };

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values[json['type'] as int],
      title: json['title'] as String,
      body: json['body'] as String,
      deepLink: json['deepLink'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt'] as String) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt'] as String) : null,
      clicked: json['clicked'] as bool? ?? false,
      clickedAt: json['clickedAt'] != null ? DateTime.parse(json['clickedAt'] as String) : null,
    );
  }
}

/// User engagement metrics
class UserEngagementMetrics {
  final String userId;
  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final int sessionDuration;
  final Map<String, int> featureUsage;
  final double churnRisk;
  final DateTime? lastActiveAt;
  final int engagementScore;
  final DateTime calculatedAt;

  const UserEngagementMetrics({
    required this.userId,
    this.dailyActiveUsers = 0,
    this.monthlyActiveUsers = 0,
    this.sessionDuration = 0,
    this.featureUsage = const {},
    this.churnRisk = 0.0,
    this.lastActiveAt,
    this.engagementScore = 50,
    required this.calculatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'dailyActiveUsers': dailyActiveUsers,
        'monthlyActiveUsers': monthlyActiveUsers,
        'sessionDuration': sessionDuration,
        'featureUsage': featureUsage,
        'churnRisk': churnRisk,
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'engagementScore': engagementScore,
        'calculatedAt': calculatedAt.toIso8601String(),
      };

  factory UserEngagementMetrics.fromJson(Map<String, dynamic> json) {
    return UserEngagementMetrics(
      userId: json['userId'] as String,
      dailyActiveUsers: json['dailyActiveUsers'] as int? ?? 0,
      monthlyActiveUsers: json['monthlyActiveUsers'] as int? ?? 0,
      sessionDuration: json['sessionDuration'] as int? ?? 0,
      featureUsage: json['featureUsage'] != null
          ? Map<String, int>.from(json['featureUsage'] as Map)
          : const {},
      churnRisk: (json['churnRisk'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt'] as String) : null,
      engagementScore: json['engagementScore'] as int? ?? 50,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }
}

/// Achievement badge
class AchievementBadge {
  final String badgeId;
  final String name;
  final String description;
  final String? iconUrl;
  final String requirement;
  final int unlockedByCount;
  final String? rarityTier;
  final String? category;
  final DateTime createdAt;

  const AchievementBadge({
    required this.badgeId,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.requirement,
    this.unlockedByCount = 0,
    this.rarityTier,
    this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'badgeId': badgeId,
        'name': name,
        'description': description,
        'iconUrl': iconUrl,
        'requirement': requirement,
        'unlockedByCount': unlockedByCount,
        'rarityTier': rarityTier,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AchievementBadge.fromJson(Map<String, dynamic> json) {
    return AchievementBadge(
      badgeId: json['badgeId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      requirement: json['requirement'] as String,
      unlockedByCount: json['unlockedByCount'] as int? ?? 0,
      rarityTier: json['rarityTier'] as String?,
      category: json['category'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

// Platform Monitoring

/// Platform-wide metrics
class PlatformMetrics {
  final String metricsId;
  final String period;
  final int dailyActiveUsers;
  final int monthlyActiveUsers;
  final int sessionCount;
  final int avgSessionDuration;
  final Map<String, int> featurePopularity;
  final double errorRate;
  final double apiLatencyP50;
  final double apiLatencyP99;
  final int serverLoad;
  final int databaseQueries;
  final double cacheHitRate;
  final DateTime generatedAt;

  const PlatformMetrics({
    required this.metricsId,
    required this.period,
    this.dailyActiveUsers = 0,
    this.monthlyActiveUsers = 0,
    this.sessionCount = 0,
    this.avgSessionDuration = 0,
    this.featurePopularity = const {},
    this.errorRate = 0.0,
    this.apiLatencyP50 = 0.0,
    this.apiLatencyP99 = 0.0,
    this.serverLoad = 0,
    this.databaseQueries = 0,
    this.cacheHitRate = 0.0,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() => {
        'metricsId': metricsId,
        'period': period,
        'dailyActiveUsers': dailyActiveUsers,
        'monthlyActiveUsers': monthlyActiveUsers,
        'sessionCount': sessionCount,
        'avgSessionDuration': avgSessionDuration,
        'featurePopularity': featurePopularity,
        'errorRate': errorRate,
        'apiLatencyP50': apiLatencyP50,
        'apiLatencyP99': apiLatencyP99,
        'serverLoad': serverLoad,
        'databaseQueries': databaseQueries,
        'cacheHitRate': cacheHitRate,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformMetrics(
      metricsId: json['metricsId'] as String,
      period: json['period'] as String,
      dailyActiveUsers: json['dailyActiveUsers'] as int? ?? 0,
      monthlyActiveUsers: json['monthlyActiveUsers'] as int? ?? 0,
      sessionCount: json['sessionCount'] as int? ?? 0,
      avgSessionDuration: json['avgSessionDuration'] as int? ?? 0,
      featurePopularity: json['featurePopularity'] != null
          ? Map<String, int>.from(json['featurePopularity'] as Map)
          : const {},
      errorRate: (json['errorRate'] as num?)?.toDouble() ?? 0.0,
      apiLatencyP50: (json['apiLatencyP50'] as num?)?.toDouble() ?? 0.0,
      apiLatencyP99: (json['apiLatencyP99'] as num?)?.toDouble() ?? 0.0,
      serverLoad: json['serverLoad'] as int? ?? 0,
      databaseQueries: json['databaseQueries'] as int? ?? 0,
      cacheHitRate: (json['cacheHitRate'] as num?)?.toDouble() ?? 0.0,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}
