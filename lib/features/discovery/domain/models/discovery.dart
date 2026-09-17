import 'package:freezed_annotation/freezed_annotation.dart';

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
  const SearchQuery({
    required String queryId,
    required String userId,
    required String searchText,
    required SearchType searchType,
    Map<String, dynamic> filters,
    int resultsCount,
    required DateTime performedAt,
    bool isPopular,
  });
}

/// Real-time personalized recommendation feed
class RecommendationFeed {
  const RecommendationFeed({
    required String feedId,
    required String userId,
    required RecommendationFeedType feedType,
    List<Map<String, dynamic>> items,
    required DateTime generatedAt,
    required DateTime expiresAt,
    double confidence,
  });
}

/// Trending content rankings
class TrendingContent {
  const TrendingContent({
    required String trendingId,
    required ContentTypeEnum contentType,
    required String contentId,
    int rank,
    double score,
    required TrendingCategory trendingCategory,
    required DateTime generatedAt,
    required DateTime expiresAt,
  });
}

/// Discovery analytics for tracking user behavior
class DiscoveryAnalytics {
  const DiscoveryAnalytics({
    required String analyticsId,
    required String userId,
    required DiscoveryActionType action,
    required ContentTypeEnum contentType,
    required String contentId,
    String? creatorId,
    required DateTime actionAt,
    int durationViewed,
    bool conversionAction,
  });
}

/// Cached search result
class SearchResult {
  const SearchResult({
    required String resultId,
    required String queryId,
    required ContentTypeEnum contentType,
    required String contentId,
    double matchScore,
    int rank,
    Map<String, dynamic> displayData,
  });
}

/// Optimized creator search display
class CreatorSearchCard {
  const CreatorSearchCard({
    required String creatorId,
    required String displayName,
    String? bio,
    String? avatarUrl,
    int followerCount,
    String? creatorTier,
    bool verificationBadge,
    String? topClipThisMonth,
    double avgViewsPerClip,
    DateTime? lastStreamedAt,
    DateTime? lastClipUploadedAt,
  });
}

/// Saved search for quick re-execution
class SavedSearch {
  const SavedSearch({
    required String savedSearchId,
    required String userId,
    required String searchText,
    Map<String, dynamic> searchFilters,
    required DateTime savedAt,
    DateTime? lastExecutedAt,
    int resultCount,
  });
}

/// Platform-wide discovery metrics
class DiscoveryMetrics {
  const DiscoveryMetrics({
    required String metricsId,
    required String period,
    int totalSearches,
    int uniqueSearchers,
    double avgResultsPerQuery,
    List<String> topSearchTerms,
    List<String> topTrendingCreators,
    List<String> topTrendingClips,
    double discoveryRate,
    required DateTime generatedAt,
  });
}

/// User preferences for personalization
class UserPreferences {
  const UserPreferences({
    required String userId,
    List<String> preferredSkillLevels,
    List<String> preferredCreatorTiers,
    List<String> preferredContentTypes,
    String languagePreference,
    bool notificationsEnabled,
    required DateTime updatedAt,
  });
}
