
// Enums
enum SearchType { creator, clip, match, clan }

enum RecommendationFeedType {
  personalized,
  trending,
  followedCreators,
  recommendedClans
}

enum TrendingCategory { thisWeek, thisMonth, allTime, gaming, entertainment }

enum DiscoveryActionType { view, click, share, follow, subscribe }

enum ContentTypeEnum { creator, clip, match, clan }

// Models

/// Represents a search query performed by a user
class SearchQuery {
  final String queryId;
  final String userId;
  final String searchText;
  final SearchType searchType;
  final Map<String, dynamic> filters;
  final int resultsCount;
  final DateTime performedAt;
  final bool isPopular;

  const SearchQuery({
    required this.queryId,
    required this.userId,
    required this.searchText,
    required this.searchType,
    this.filters = const {},
    this.resultsCount = 0,
    required this.performedAt,
    this.isPopular = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'queryId': queryId,
      'userId': userId,
      'searchText': searchText,
      'searchType': searchType.name,
      'filters': filters,
      'resultsCount': resultsCount,
      'performedAt': performedAt.toIso8601String(),
      'isPopular': isPopular,
    };
  }

  factory SearchQuery.fromJson(Map<String, dynamic> json) {
    return SearchQuery(
      queryId: json['queryId'] as String,
      userId: json['userId'] as String,
      searchText: json['searchText'] as String,
      searchType: SearchType.values.byName(json['searchType'] as String),
      filters: json['filters'] != null
          ? Map<String, dynamic>.from(json['filters'] as Map)
          : const {},
      resultsCount: json['resultsCount'] as int? ?? 0,
      performedAt: DateTime.parse(json['performedAt'] as String),
      isPopular: json['isPopular'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQuery &&
          runtimeType == other.runtimeType &&
          queryId == other.queryId &&
          userId == other.userId &&
          searchText == other.searchText &&
          searchType == other.searchType &&
          resultsCount == other.resultsCount &&
          performedAt == other.performedAt &&
          isPopular == other.isPopular;

  @override
  int get hashCode => Object.hash(
        queryId,
        userId,
        searchText,
        searchType,
        resultsCount,
        performedAt,
        isPopular,
      );
}

/// Real-time personalized recommendation feed
class RecommendationFeed {
  final String feedId;
  final String userId;
  final RecommendationFeedType feedType;
  final List<Map<String, dynamic>> items;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final double confidence;

  const RecommendationFeed({
    required this.feedId,
    required this.userId,
    required this.feedType,
    this.items = const [],
    required this.generatedAt,
    required this.expiresAt,
    this.confidence = 0.85,
  });

  Map<String, dynamic> toJson() {
    return {
      'feedId': feedId,
      'userId': userId,
      'feedType': feedType.name,
      'items': items,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'confidence': confidence,
    };
  }

  factory RecommendationFeed.fromJson(Map<String, dynamic> json) {
    return RecommendationFeed(
      feedId: json['feedId'] as String,
      userId: json['userId'] as String,
      feedType:
          RecommendationFeedType.values.byName(json['feedType'] as String),
      items: json['items'] != null
          ? List<Map<String, dynamic>>.from(
              (json['items'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
            )
          : const [],
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
    );
  }
}

/// Trending content rankings
class TrendingContent {
  final String trendingId;
  final ContentTypeEnum contentType;
  final String contentId;
  final int rank;
  final double score;
  final TrendingCategory trendingCategory;
  final DateTime generatedAt;
  final DateTime expiresAt;

  const TrendingContent({
    required this.trendingId,
    required this.contentType,
    required this.contentId,
    this.rank = 0,
    this.score = 0.0,
    required this.trendingCategory,
    required this.generatedAt,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'trendingId': trendingId,
      'contentType': contentType.name,
      'contentId': contentId,
      'rank': rank,
      'score': score,
      'trendingCategory': trendingCategory.name,
      'generatedAt': generatedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory TrendingContent.fromJson(Map<String, dynamic> json) {
    return TrendingContent(
      trendingId: json['trendingId'] as String,
      contentType: ContentTypeEnum.values.byName(json['contentType'] as String),
      contentId: json['contentId'] as String,
      rank: json['rank'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      trendingCategory:
          TrendingCategory.values.byName(json['trendingCategory'] as String),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// Discovery analytics for tracking user behavior
class DiscoveryAnalytics {
  final String analyticsId;
  final String userId;
  final DiscoveryActionType action;
  final ContentTypeEnum contentType;
  final String contentId;
  final String? creatorId;
  final DateTime actionAt;
  final int durationViewed;
  final bool conversionAction;

  const DiscoveryAnalytics({
    required this.analyticsId,
    required this.userId,
    required this.action,
    required this.contentType,
    required this.contentId,
    this.creatorId,
    required this.actionAt,
    this.durationViewed = 0,
    this.conversionAction = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'analyticsId': analyticsId,
      'userId': userId,
      'action': action.name,
      'contentType': contentType.name,
      'contentId': contentId,
      'creatorId': creatorId,
      'actionAt': actionAt.toIso8601String(),
      'durationViewed': durationViewed,
      'conversionAction': conversionAction,
    };
  }

  factory DiscoveryAnalytics.fromJson(Map<String, dynamic> json) {
    return DiscoveryAnalytics(
      analyticsId: json['analyticsId'] as String,
      userId: json['userId'] as String,
      action: DiscoveryActionType.values.byName(json['action'] as String),
      contentType: ContentTypeEnum.values.byName(json['contentType'] as String),
      contentId: json['contentId'] as String,
      creatorId: json['creatorId'] as String?,
      actionAt: DateTime.parse(json['actionAt'] as String),
      durationViewed: json['durationViewed'] as int? ?? 0,
      conversionAction: json['conversionAction'] as bool? ?? false,
    );
  }
}

/// Cached search result
class SearchResult {
  final String resultId;
  final String queryId;
  final ContentTypeEnum contentType;
  final String contentId;
  final double matchScore;
  final int rank;
  final Map<String, dynamic> displayData;

  const SearchResult({
    required this.resultId,
    required this.queryId,
    required this.contentType,
    required this.contentId,
    this.matchScore = 0.0,
    this.rank = 0,
    this.displayData = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'resultId': resultId,
      'queryId': queryId,
      'contentType': contentType.name,
      'contentId': contentId,
      'matchScore': matchScore,
      'rank': rank,
      'displayData': displayData,
    };
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      resultId: json['resultId'] as String,
      queryId: json['queryId'] as String,
      contentType: ContentTypeEnum.values.byName(json['contentType'] as String),
      contentId: json['contentId'] as String,
      matchScore: (json['matchScore'] as num?)?.toDouble() ?? 0.0,
      rank: json['rank'] as int? ?? 0,
      displayData: json['displayData'] != null
          ? Map<String, dynamic>.from(json['displayData'] as Map)
          : const {},
    );
  }
}

/// Optimized creator search display
class CreatorSearchCard {
  final String creatorId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final int followerCount;
  final String? creatorTier;
  final bool verificationBadge;
  final String? topClipThisMonth;
  final double avgViewsPerClip;
  final DateTime? lastStreamedAt;
  final DateTime? lastClipUploadedAt;

  const CreatorSearchCard({
    required this.creatorId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.followerCount = 0,
    this.creatorTier,
    this.verificationBadge = false,
    this.topClipThisMonth,
    this.avgViewsPerClip = 0.0,
    this.lastStreamedAt,
    this.lastClipUploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'creatorId': creatorId,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'followerCount': followerCount,
      'creatorTier': creatorTier,
      'verificationBadge': verificationBadge,
      'topClipThisMonth': topClipThisMonth,
      'avgViewsPerClip': avgViewsPerClip,
      'lastStreamedAt': lastStreamedAt?.toIso8601String(),
      'lastClipUploadedAt': lastClipUploadedAt?.toIso8601String(),
    };
  }

  factory CreatorSearchCard.fromJson(Map<String, dynamic> json) {
    return CreatorSearchCard(
      creatorId: json['creatorId'] as String,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      followerCount: json['followerCount'] as int? ?? 0,
      creatorTier: json['creatorTier'] as String?,
      verificationBadge: json['verificationBadge'] as bool? ?? false,
      topClipThisMonth: json['topClipThisMonth'] as String?,
      avgViewsPerClip: (json['avgViewsPerClip'] as num?)?.toDouble() ?? 0.0,
      lastStreamedAt: json['lastStreamedAt'] != null
          ? DateTime.parse(json['lastStreamedAt'] as String)
          : null,
      lastClipUploadedAt: json['lastClipUploadedAt'] != null
          ? DateTime.parse(json['lastClipUploadedAt'] as String)
          : null,
    );
  }
}

/// Saved search for quick re-execution
class SavedSearch {
  final String savedSearchId;
  final String userId;
  final String searchText;
  final Map<String, dynamic> searchFilters;
  final DateTime savedAt;
  final DateTime? lastExecutedAt;
  final int resultCount;

  const SavedSearch({
    required this.savedSearchId,
    required this.userId,
    required this.searchText,
    this.searchFilters = const {},
    required this.savedAt,
    this.lastExecutedAt,
    this.resultCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'savedSearchId': savedSearchId,
      'userId': userId,
      'searchText': searchText,
      'searchFilters': searchFilters,
      'savedAt': savedAt.toIso8601String(),
      'lastExecutedAt': lastExecutedAt?.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      savedSearchId: json['savedSearchId'] as String,
      userId: json['userId'] as String,
      searchText: json['searchText'] as String,
      searchFilters: json['searchFilters'] != null
          ? Map<String, dynamic>.from(json['searchFilters'] as Map)
          : const {},
      savedAt: DateTime.parse(json['savedAt'] as String),
      lastExecutedAt: json['lastExecutedAt'] != null
          ? DateTime.parse(json['lastExecutedAt'] as String)
          : null,
      resultCount: json['resultCount'] as int? ?? 0,
    );
  }
}

/// Platform-wide discovery metrics
class DiscoveryMetrics {
  final String metricsId;
  final String period;
  final int totalSearches;
  final int uniqueSearchers;
  final double avgResultsPerQuery;
  final List<String> topSearchTerms;
  final List<String> topTrendingCreators;
  final List<String> topTrendingClips;
  final double discoveryRate;
  final DateTime generatedAt;

  const DiscoveryMetrics({
    required this.metricsId,
    required this.period,
    this.totalSearches = 0,
    this.uniqueSearchers = 0,
    this.avgResultsPerQuery = 0.0,
    this.topSearchTerms = const [],
    this.topTrendingCreators = const [],
    this.topTrendingClips = const [],
    this.discoveryRate = 0.0,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'metricsId': metricsId,
      'period': period,
      'totalSearches': totalSearches,
      'uniqueSearchers': uniqueSearchers,
      'avgResultsPerQuery': avgResultsPerQuery,
      'topSearchTerms': topSearchTerms,
      'topTrendingCreators': topTrendingCreators,
      'topTrendingClips': topTrendingClips,
      'discoveryRate': discoveryRate,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory DiscoveryMetrics.fromJson(Map<String, dynamic> json) {
    return DiscoveryMetrics(
      metricsId: json['metricsId'] as String,
      period: json['period'] as String,
      totalSearches: json['totalSearches'] as int? ?? 0,
      uniqueSearchers: json['uniqueSearchers'] as int? ?? 0,
      avgResultsPerQuery: (json['avgResultsPerQuery'] as num?)?.toDouble() ?? 0.0,
      topSearchTerms: json['topSearchTerms'] != null
          ? List<String>.from(json['topSearchTerms'] as List)
          : const [],
      topTrendingCreators: json['topTrendingCreators'] != null
          ? List<String>.from(json['topTrendingCreators'] as List)
          : const [],
      topTrendingClips: json['topTrendingClips'] != null
          ? List<String>.from(json['topTrendingClips'] as List)
          : const [],
      discoveryRate: (json['discoveryRate'] as num?)?.toDouble() ?? 0.0,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }
}

/// User preferences for personalization
class UserPreferences {
  final String userId;
  final List<String> preferredSkillLevels;
  final List<String> preferredCreatorTiers;
  final List<String> preferredContentTypes;
  final String languagePreference;
  final bool notificationsEnabled;
  final DateTime updatedAt;

  const UserPreferences({
    required this.userId,
    this.preferredSkillLevels = const [],
    this.preferredCreatorTiers = const [],
    this.preferredContentTypes = const [],
    this.languagePreference = 'en',
    this.notificationsEnabled = true,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'preferredSkillLevels': preferredSkillLevels,
      'preferredCreatorTiers': preferredCreatorTiers,
      'preferredContentTypes': preferredContentTypes,
      'languagePreference': languagePreference,
      'notificationsEnabled': notificationsEnabled,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'] as String,
      preferredSkillLevels: json['preferredSkillLevels'] != null
          ? List<String>.from(json['preferredSkillLevels'] as List)
          : const [],
      preferredCreatorTiers: json['preferredCreatorTiers'] != null
          ? List<String>.from(json['preferredCreatorTiers'] as List)
          : const [],
      preferredContentTypes: json['preferredContentTypes'] != null
          ? List<String>.from(json['preferredContentTypes'] as List)
          : const [],
      languagePreference: json['languagePreference'] as String? ?? 'en',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
