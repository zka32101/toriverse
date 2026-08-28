import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../domain/models/discovery.dart';

part 'discovery_providers.freezed.dart';

// ===== PROVIDER PARAMETER CLASSES =====

@freezed
class SearchParam with _$SearchParam {
  const factory SearchParam({
    required String query,
    required SearchType searchType,
    Map<String, dynamic>? filters,
    @Default(20) int limit,
  }) = _SearchParam;
}

@freezed
class RecommendationParam with _$RecommendationParam {
  const factory RecommendationParam({
    required String userId,
    required RecommendationFeedType feedType,
    @Default(20) int limit,
  }) = _RecommendationParam;
}

@freezed
class TrendingParam with _$TrendingParam {
  const factory TrendingParam({
    required ContentTypeEnum contentType,
    @Default('week') String timeframe,
    @Default(20) int limit,
  }) = _TrendingParam;
}

// ===== REPOSITORY PROVIDER =====

final discoveryRepositoryProvider = Provider((ref) {
  return DiscoveryRepository(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
  );
});

// ===== STREAM PROVIDERS (Real-time, 8 total) =====

/// Watch personalized recommendations in real-time
final watchPersonalizedFeedProvider =
    StreamProvider.family<RecommendationFeed, String>((ref, userId) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final feed = await repo.getPersonalizedFeed(userId);
    yield feed;

    // Re-generate every 6 hours
    await Future.delayed(const Duration(hours: 6));
    final newFeed = await repo.getPersonalizedFeed(userId);
    yield newFeed;
  } catch (e) {
    throw Exception('Failed to watch personalized feed: $e');
  }
});

/// Watch trending content in real-time
final watchTrendingFeedProvider =
    StreamProvider.family<RecommendationFeed, TrendingParam>(
        (ref, params) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final feed =
        await repo.getTrendingFeed(timeframe: params.timeframe, limit: params.limit);
    yield feed;

    // Update every hour
    await Future.delayed(const Duration(hours: 1));
    final newFeed =
        await repo.getTrendingFeed(timeframe: params.timeframe, limit: params.limit);
    yield newFeed;
  } catch (e) {
    throw Exception('Failed to watch trending feed: $e');
  }
});

/// Watch followed creators feed
final watchFollowedCreatorsFeedProvider =
    StreamProvider.family<RecommendationFeed, String>((ref, userId) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final feed = await repo.getFollowedCreatorsFeed(userId);
    yield feed;

    // Update every 2 hours
    await Future.delayed(const Duration(hours: 2));
    final newFeed = await repo.getFollowedCreatorsFeed(userId);
    yield newFeed;
  } catch (e) {
    throw Exception('Failed to watch followed creators feed: $e');
  }
});

/// Watch recommended clans
final watchRecommendedClansProvider =
    StreamProvider.family<RecommendationFeed, String>((ref, userId) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final feed = await repo.getRecommendedClans(userId);
    yield feed;

    // Update every 3 hours
    await Future.delayed(const Duration(hours: 3));
    final newFeed = await repo.getRecommendedClans(userId);
    yield newFeed;
  } catch (e) {
    throw Exception('Failed to watch recommended clans: $e');
  }
});

/// Watch search results in real-time
final watchSearchResultsProvider =
    StreamProvider.family<List<SearchResult>, SearchParam>((ref, params) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final results = await repo.globalSearch(
      params.query,
      type: params.searchType,
      limit: params.limit,
    );
    yield results;

    // Re-search every 30 seconds for updates
    await Future.delayed(const Duration(seconds: 30));
    final newResults = await repo.globalSearch(
      params.query,
      type: params.searchType,
      limit: params.limit,
    );
    yield newResults;
  } catch (e) {
    throw Exception('Failed to watch search results: $e');
  }
});

/// Watch trending creators in real-time
final watchTrendingCreatorsProvider =
    StreamProvider.family<List<CreatorSearchCard>, TrendingParam>(
        (ref, params) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final creators = await repo.getTrendingCreators(
      timeframe: params.timeframe,
      limit: params.limit,
    );
    yield creators;

    // Update every hour
    await Future.delayed(const Duration(hours: 1));
    final newCreators = await repo.getTrendingCreators(
      timeframe: params.timeframe,
      limit: params.limit,
    );
    yield newCreators;
  } catch (e) {
    throw Exception('Failed to watch trending creators: $e');
  }
});

/// Watch trending clips in real-time
final watchTrendingClipsProvider =
    StreamProvider.family<List<SearchResult>, TrendingParam>((ref, params) async* {
  final repo = ref.watch(discoveryRepositoryProvider);
  try {
    final clips = await repo.getTrendingClips(
      timeframe: params.timeframe,
      limit: params.limit,
    );
    yield clips;

    // Update every 2 hours
    await Future.delayed(const Duration(hours: 2));
    final newClips = await repo.getTrendingClips(
      timeframe: params.timeframe,
      limit: params.limit,
    );
    yield newClips;
  } catch (e) {
    throw Exception('Failed to watch trending clips: $e');
  }
});

/// Watch discovery metrics (admin only)
final watchDiscoveryMetricsProvider =
    StreamProvider<DiscoveryMetrics>((ref) async* {
  try {
    // Placeholder: would fetch from Firestore
    final metrics = DiscoveryMetrics(
      metricsId: 'metrics_${DateTime.now().toIso8601String()}',
      period: 'daily',
      totalSearches: 0,
      uniqueSearchers: 0,
      avgResultsPerQuery: 0.0,
      discoveryRate: 0.0,
      generatedAt: DateTime.now(),
    );
    yield metrics;

    // Update hourly
    await Future.delayed(const Duration(hours: 1));
  } catch (e) {
    throw Exception('Failed to watch discovery metrics: $e');
  }
});

// ===== FUTURE PROVIDERS (Async Caching, 10+ total) =====

/// Fetch cached personalized recommendations
final personalizedFeedProvider =
    FutureProvider.family<RecommendationFeed, String>((ref, userId) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getPersonalizedFeed(userId);
});

/// Fetch cached trending feed
final trendingFeedProvider =
    FutureProvider.family<RecommendationFeed, TrendingParam>(
        (ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getTrendingFeed(
    timeframe: params.timeframe,
    limit: params.limit,
  );
});

/// Fetch followed creators feed (cached)
final followedCreatorsFeedProvider =
    FutureProvider.family<RecommendationFeed, String>((ref, userId) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getFollowedCreatorsFeed(userId);
});

/// Fetch recommended clans (cached)
final recommendedClansProvider =
    FutureProvider.family<RecommendationFeed, String>((ref, userId) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getRecommendedClans(userId);
});

/// Fetch search results (cached)
final searchResultsProvider =
    FutureProvider.family<List<SearchResult>, SearchParam>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.globalSearch(
    params.query,
    type: params.searchType,
    limit: params.limit,
  );
});

/// Fetch search suggestions
final searchSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, query) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getSearchSuggestions(query);
});

/// Fetch user's saved searches
final userSavedSearchesProvider =
    FutureProvider.family<List<SavedSearch>, String>((ref, userId) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getUserSavedSearches(userId);
});

/// Fetch trending creators (cached)
final trendingCreatorsProvider =
    FutureProvider.family<List<CreatorSearchCard>, TrendingParam>(
        (ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getTrendingCreators(
    timeframe: params.timeframe,
    limit: params.limit,
  );
});

/// Fetch trending clips (cached)
final trendingClipsProvider =
    FutureProvider.family<List<SearchResult>, TrendingParam>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getTrendingClips(
    timeframe: params.timeframe,
    limit: params.limit,
  );
});

/// Fetch trending matches (cached)
final trendingMatchesProvider =
    FutureProvider.family<List<SearchResult>, TrendingParam>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getTrendingMatches(
    timeframe: params.timeframe,
    limit: params.limit,
  );
});

/// Fetch recently verified creators
final newCreatorsFeedProvider =
    FutureProvider.family<List<CreatorSearchCard>, int>((ref, limit) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getNewCreatorsFeed(limit: limit);
});

// ===== MUTATION PROVIDERS (Transactions, 3+) =====

/// Record discovery action (view, click, follow, subscribe)
final recordDiscoveryActionProvider = FutureProvider.family<void,
    ({
      String userId,
      DiscoveryActionType action,
      ContentTypeEnum contentType,
      String contentId,
      String? creatorId,
    })>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);

  await repo.recordDiscoveryAction(
    params.userId,
    params.action,
    params.contentType,
    params.contentId,
    creatorId: params.creatorId,
    conversionAction:
        params.action == DiscoveryActionType.follow ||
        params.action == DiscoveryActionType.subscribe,
  );

  // Invalidate related providers
  ref.invalidate(personalizedFeedProvider);
  ref.invalidate(watchPersonalizedFeedProvider);
});

/// Save a search for quick re-execution
final saveSearchProvider = FutureProvider.family<SavedSearch,
    ({
      String userId,
      String query,
      Map<String, dynamic>? filters,
    })>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);

  final savedSearch = await repo.saveSearch(
    params.userId,
    params.query,
    filters: params.filters,
  );

  // Invalidate saved searches
  ref.invalidate(userSavedSearchesProvider);

  return savedSearch;
});

/// Regenerate recommendations for user
final regenerateRecommendationsProvider = FutureProvider.family<void, String>(
    (ref, userId) async {
  final repo = ref.watch(discoveryRepositoryProvider);

  await repo.getPersonalizedFeed(userId);

  // Invalidate all recommendation feeds
  ref.invalidate(personalizedFeedProvider);
  ref.invalidate(watchPersonalizedFeedProvider);
  ref.invalidate(recommendedClansProvider);
  ref.invalidate(watchRecommendedClansProvider);
});

// ===== ANALYTICS/SEARCH PROVIDERS =====

/// Get popular search terms
final popularSearchTermsProvider = FutureProvider.family<List<String>,
    ({
      int limit,
      String timeframe,
    })>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getPopularSearchTerms(
    limit: params.limit,
    timeframe: params.timeframe,
  );
});

/// Get search term trends
final searchTermTrendsProvider = FutureProvider.family<Map<String, int>,
    ({
      String term,
      String timeframe,
    })>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getSearchTermTrends(
    params.term,
    timeframe: params.timeframe,
  );
});

/// Get user's search history
final userSearchHistoryProvider =
    FutureProvider.family<List<SearchQuery>, ({String userId, int limit})>(
        (ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getUserSearchHistory(
    params.userId,
    limit: params.limit,
  );
});

/// Get trending skill levels
final trendingSkillLevelsProvider = FutureProvider.family<Map<String, int>,
    String>((ref, timeframe) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getTrendingSkillLevels(timeframe: timeframe);
});

/// Get related creators
final relatedCreatorsProvider = FutureProvider.family<List<CreatorSearchCard>,
    ({String creatorId, int limit})>((ref, params) async {
  final repo = ref.watch(discoveryRepositoryProvider);
  return repo.getRelatedCreators(
    params.creatorId,
    limit: params.limit,
  );
});
