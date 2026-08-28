import 'package:freezed_annotation/freezed_annotation.dart';

part 'discovery.freezed.dart';
part 'discovery.g.dart';

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
@freezed
class SearchQuery with _$SearchQuery {
  const factory SearchQuery({
    required String queryId,
    required String userId,
    required String searchText,
    required SearchType searchType,
    @Default({}) Map<String, dynamic> filters,
    @Default(0) int resultsCount,
    required DateTime performedAt,
    @Default(false) bool isPopular,
  }) = _SearchQuery;

  factory SearchQuery.fromJson(Map<String, dynamic> json) =>
      _$SearchQueryFromJson(json);
}

/// Real-time personalized recommendation feed
@freezed
class RecommendationFeed with _$RecommendationFeed {
  const factory RecommendationFeed({
    required String feedId,
    required String userId,
    required RecommendationFeedType feedType,
    @Default([]) List<Map<String, dynamic>> items,
    required DateTime generatedAt,
    required DateTime expiresAt,
    @Default(0.85) double confidence,
  }) = _RecommendationFeed;

  factory RecommendationFeed.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFeedFromJson(json);
}

/// Trending content rankings
@freezed
class TrendingContent with _$TrendingContent {
  const factory TrendingContent({
    required String trendingId,
    required ContentTypeEnum contentType,
    required String contentId,
    @Default(0) int rank,
    @Default(0.0) double score,
    required TrendingCategory trendingCategory,
    required DateTime generatedAt,
    required DateTime expiresAt,
  }) = _TrendingContent;

  factory TrendingContent.fromJson(Map<String, dynamic> json) =>
      _$TrendingContentFromJson(json);
}

/// Discovery analytics for tracking user behavior
@freezed
class DiscoveryAnalytics with _$DiscoveryAnalytics {
  const factory DiscoveryAnalytics({
    required String analyticsId,
    required String userId,
    required DiscoveryActionType action,
    required ContentTypeEnum contentType,
    required String contentId,
    String? creatorId,
    required DateTime actionAt,
    @Default(0) int durationViewed,
    @Default(false) bool conversionAction,
  }) = _DiscoveryAnalytics;

  factory DiscoveryAnalytics.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryAnalyticsFromJson(json);
}

/// Cached search result
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required String resultId,
    required String queryId,
    required ContentTypeEnum contentType,
    required String contentId,
    @Default(0.0) double matchScore,
    @Default(0) int rank,
    @Default({}) Map<String, dynamic> displayData,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}

/// Optimized creator search display
@freezed
class CreatorSearchCard with _$CreatorSearchCard {
  const factory CreatorSearchCard({
    required String creatorId,
    required String displayName,
    String? bio,
    String? avatarUrl,
    @Default(0) int followerCount,
    String? creatorTier,
    @Default(false) bool verificationBadge,
    String? topClipThisMonth,
    @Default(0.0) double avgViewsPerClip,
    DateTime? lastStreamedAt,
    DateTime? lastClipUploadedAt,
  }) = _CreatorSearchCard;

  factory CreatorSearchCard.fromJson(Map<String, dynamic> json) =>
      _$CreatorSearchCardFromJson(json);
}

/// Saved search for quick re-execution
@freezed
class SavedSearch with _$SavedSearch {
  const factory SavedSearch({
    required String savedSearchId,
    required String userId,
    required String searchText,
    @Default({}) Map<String, dynamic> searchFilters,
    required DateTime savedAt,
    DateTime? lastExecutedAt,
    @Default(0) int resultCount,
  }) = _SavedSearch;

  factory SavedSearch.fromJson(Map<String, dynamic> json) =>
      _$SavedSearchFromJson(json);
}

/// Platform-wide discovery metrics
@freezed
class DiscoveryMetrics with _$DiscoveryMetrics {
  const factory DiscoveryMetrics({
    required String metricsId,
    required String period,
    @Default(0) int totalSearches,
    @Default(0) int uniqueSearchers,
    @Default(0.0) double avgResultsPerQuery,
    @Default([]) List<String> topSearchTerms,
    @Default([]) List<String> topTrendingCreators,
    @Default([]) List<String> topTrendingClips,
    @Default(0.0) double discoveryRate,
    required DateTime generatedAt,
  }) = _DiscoveryMetrics;

  factory DiscoveryMetrics.fromJson(Map<String, dynamic> json) =>
      _$DiscoveryMetricsFromJson(json);
}

/// User preferences for personalization
@freezed
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    required String userId,
    @Default([]) List<String> preferredSkillLevels,
    @Default([]) List<String> preferredCreatorTiers,
    @Default([]) List<String> preferredContentTypes,
    @Default('en') String languagePreference,
    @Default(true) bool notificationsEnabled,
    required DateTime updatedAt,
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}
