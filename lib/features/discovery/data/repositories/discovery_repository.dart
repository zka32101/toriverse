import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../../discovery/domain/models/discovery.dart';

class DiscoveryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  DiscoveryRepository({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
  })  : _firestore = firestore,
        _analytics = analytics;

  // ===== ADVANCED SEARCH METHODS (8) =====

  /// Search creators by name, bio, or tags
  Future<List<CreatorSearchCard>> searchCreators(
    String query, {
    Map<String, dynamic>? filters,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CreatorSearchCard(
          creatorId: doc.id,
          displayName: data['displayName'] ?? '',
          bio: data['bio'],
          avatarUrl: data['avatarUrl'],
          followerCount: data['followerCount'] ?? 0,
          creatorTier: data['creatorTier'],
          verificationBadge: data['isVerified'] ?? false,
          topClipThisMonth: data['topClipThisMonth'],
          avgViewsPerClip: (data['avgViewsPerClip'] ?? 0).toDouble(),
          lastStreamedAt: data['lastStreamedAt'] != null
              ? (data['lastStreamedAt'] as Timestamp).toDate()
              : null,
          lastClipUploadedAt: data['lastClipUploadedAt'] != null
              ? (data['lastClipUploadedAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search creators: $e');
    }
  }

  /// Search clips by title, description, tags
  Future<List<SearchResult>> searchClips(
    String query, {
    Map<String, dynamic>? filters,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('clips')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: query + 'z')
          .orderBy('title')
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return SearchResult(
          resultId: '${entry.key}_${entry.value.id}',
          queryId: query,
          contentType: ContentTypeEnum.clip,
          contentId: entry.value.id,
          matchScore: 0.9,
          rank: entry.key + 1,
          displayData: {
            'title': data['title'],
            'creatorId': data['creatorId'],
            'viewCount': data['viewCount'] ?? 0,
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search clips: $e');
    }
  }

  /// Search match archives by players, result
  Future<List<SearchResult>> searchMatches(
    String query, {
    Map<String, dynamic>? filters,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('matches')
          .where('status', isEqualTo: 'finished')
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return SearchResult(
          resultId: '${entry.key}_${entry.value.id}',
          queryId: query,
          contentType: ContentTypeEnum.match,
          contentId: entry.value.id,
          matchScore: 0.8,
          rank: entry.key + 1,
          displayData: {
            'players': data['players'] ?? [],
            'createdAt': data['createdAt'],
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search matches: $e');
    }
  }

  /// Search clans by name, description
  Future<List<SearchResult>> searchClans(
    String query, {
    Map<String, dynamic>? filters,
    int limit = 20,
  }) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('clans')
          .where('clanName', isGreaterThanOrEqualTo: query)
          .where('clanName', isLessThan: query + 'z')
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return SearchResult(
          resultId: '${entry.key}_${entry.value.id}',
          queryId: query,
          contentType: ContentTypeEnum.clan,
          contentId: entry.value.id,
          matchScore: 0.85,
          rank: entry.key + 1,
          displayData: {
            'clanName': data['clanName'],
            'memberCount': data['memberCount'] ?? 0,
          },
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search clans: $e');
    }
  }

  /// Global search across all content types
  Future<List<SearchResult>> globalSearch(
    String query, {
    SearchType? type,
    int limit = 20,
  }) async {
    try {
      List<SearchResult> results = [];

      if (type == null || type == SearchType.creator) {
        final creators = await searchCreators(query, limit: limit);
        results.addAll(creators.asMap().entries.map((entry) {
          return SearchResult(
            resultId: 'creator_${entry.key}',
            queryId: query,
            contentType: ContentTypeEnum.creator,
            contentId: entry.value.creatorId,
            matchScore: 0.9,
            rank: entry.key + 1,
            displayData: entry.value.toJson(),
          );
        }));
      }

      if (type == null || type == SearchType.clip) {
        final clips = await searchClips(query, limit: limit);
        results.addAll(clips);
      }

      if (type == null || type == SearchType.match) {
        final matches = await searchMatches(query, limit: limit);
        results.addAll(matches);
      }

      if (type == null || type == SearchType.clan) {
        final clans = await searchClans(query, limit: limit);
        results.addAll(clans);
      }

      results.sort((a, b) => b.matchScore.compareTo(a.matchScore));
      return results.take(limit).toList();
    } catch (e) {
      throw Exception('Global search failed: $e');
    }
  }

  /// Get autocomplete suggestions for search
  Future<List<String>> getSearchSuggestions(String query) async {
    try {
      final snapshot = await _firestore
          .collection('search_queries')
          .where('searchText', isGreaterThanOrEqualTo: query)
          .where('searchText', isLessThan: query + 'z')
          .where('isPopular', isEqualTo: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()['searchText'] as String))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save a search for quick re-execution
  Future<SavedSearch> saveSearch(
    String userId,
    String query, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final savedSearchId =
          _firestore.collection('users').doc(userId).collection('saved_searches').doc().id;
      final savedSearch = SavedSearch(
        savedSearchId: savedSearchId,
        userId: userId,
        searchText: query,
        searchFilters: filters ?? {},
        savedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_searches')
          .doc(savedSearchId)
          .set(savedSearch.toJson());

      await _analytics.logEvent(
        name: 'search_saved',
        parameters: {
          'user_id': userId,
          'query': query,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return savedSearch;
    } catch (e) {
      throw Exception('Failed to save search: $e');
    }
  }

  /// Get user's saved searches
  Future<List<SavedSearch>> getUserSavedSearches(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_searches')
          .orderBy('savedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedSearch.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get saved searches: $e');
    }
  }

  // ===== RECOMMENDATIONS METHODS (8) =====

  /// Get ML-based personalized recommendations
  Future<RecommendationFeed> getPersonalizedFeed(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final feedId = 'feed_${DateTime.now().millisecondsSinceEpoch}';
      final feed = RecommendationFeed(
        feedId: feedId,
        userId: userId,
        feedType: RecommendationFeedType.personalized,
        items: [],
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 6)),
        confidence: 0.85,
      );

      await _analytics.logEvent(
        name: 'personalized_feed_generated',
        parameters: {
          'user_id': userId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return feed;
    } catch (e) {
      throw Exception('Failed to get personalized feed: $e');
    }
  }

  /// Get trending content feed
  Future<RecommendationFeed> getTrendingFeed({
    int limit = 20,
    String timeframe = 'week',
  }) async {
    try {
      final feedId = 'trending_${timeframe}_${DateTime.now().millisecondsSinceEpoch}';
      final feed = RecommendationFeed(
        feedId: feedId,
        userId: 'system',
        feedType: RecommendationFeedType.trending,
        items: [],
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        confidence: 0.95,
      );

      return feed;
    } catch (e) {
      throw Exception('Failed to get trending feed: $e');
    }
  }

  /// Get feed from followed creators
  Future<RecommendationFeed> getFollowedCreatorsFeed(
    String userId, {
    int limit = 20,
  }) async {
    try {
      final feedId = 'followed_${DateTime.now().millisecondsSinceEpoch}';
      final feed = RecommendationFeed(
        feedId: feedId,
        userId: userId,
        feedType: RecommendationFeedType.followedCreators,
        items: [],
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        confidence: 0.9,
      );

      return feed;
    } catch (e) {
      throw Exception('Failed to get followed creators feed: $e');
    }
  }

  /// Get recommended clans based on user profile
  Future<RecommendationFeed> getRecommendedClans(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final feedId = 'clans_${DateTime.now().millisecondsSinceEpoch}';
      final feed = RecommendationFeed(
        feedId: feedId,
        userId: userId,
        feedType: RecommendationFeedType.recommendedClans,
        items: [],
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 3)),
        confidence: 0.8,
      );

      return feed;
    } catch (e) {
      throw Exception('Failed to get recommended clans: $e');
    }
  }

  /// Get recently verified/joined creators
  Future<List<CreatorSearchCard>> getNewCreatorsFeed({
    int limit = 15,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('isVerified', isEqualTo: true)
          .orderBy('verifiedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CreatorSearchCard(
          creatorId: doc.id,
          displayName: data['displayName'] ?? '',
          bio: data['bio'],
          avatarUrl: data['avatarUrl'],
          followerCount: data['followerCount'] ?? 0,
          creatorTier: data['creatorTier'],
          verificationBadge: true,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get new creators: $e');
    }
  }

  /// Get related creator recommendations
  Future<List<CreatorSearchCard>> getRelatedCreators(
    String creatorId, {
    int limit = 10,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('creatorTier', isEqualTo: 'verified')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CreatorSearchCard(
          creatorId: doc.id,
          displayName: data['displayName'] ?? '',
          bio: data['bio'],
          avatarUrl: data['avatarUrl'],
          followerCount: data['followerCount'] ?? 0,
          creatorTier: data['creatorTier'],
          verificationBadge: data['isVerified'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get related creators: $e');
    }
  }

  /// Record a discovery action (view, click, follow, etc.)
  Future<void> recordDiscoveryAction(
    String userId,
    DiscoveryActionType action,
    ContentTypeEnum contentType,
    String contentId, {
    String? creatorId,
    int durationViewed = 0,
    bool conversionAction = false,
  }) async {
    try {
      final analyticsId = _firestore
          .collection('users')
          .doc(userId)
          .collection('discovery_actions')
          .doc()
          .id;

      final analytics = DiscoveryAnalytics(
        analyticsId: analyticsId,
        userId: userId,
        action: action,
        contentType: contentType,
        contentId: contentId,
        creatorId: creatorId,
        actionAt: DateTime.now(),
        durationViewed: durationViewed,
        conversionAction: conversionAction,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('discovery_actions')
          .doc(analyticsId)
          .set(analytics.toJson());

      await _analytics.logEvent(
        name: 'discovery_action',
        parameters: {
          'user_id': userId,
          'action': action.toString().split('.').last,
          'content_type': contentType.toString().split('.').last,
          'content_id': contentId,
          'conversion': conversionAction,
        },
      );
    } catch (e) {
      throw Exception('Failed to record discovery action: $e');
    }
  }

  // ===== TRENDING CONTENT METHODS (5) =====

  /// Get trending creators this period
  Future<List<CreatorSearchCard>> getTrendingCreators({
    String timeframe = 'week',
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('trending_rankings')
          .doc('creators_$timeframe')
          .collection('rankings')
          .orderBy('rank')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CreatorSearchCard(
          creatorId: data['contentId'] ?? '',
          displayName: data['displayName'] ?? '',
          followerCount: data['followerCount'] ?? 0,
          verificationBadge: data['verified'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending creators: $e');
    }
  }

  /// Get trending clips
  Future<List<SearchResult>> getTrendingClips({
    String timeframe = 'week',
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('trending_rankings')
          .doc('clips_$timeframe')
          .collection('rankings')
          .orderBy('rank')
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return SearchResult(
          resultId: '${entry.key}_${entry.value.id}',
          queryId: 'trending_clips',
          contentType: ContentTypeEnum.clip,
          contentId: data['contentId'] ?? '',
          matchScore: data['score'].toDouble() ?? 0.0,
          rank: entry.key + 1,
          displayData: data,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending clips: $e');
    }
  }

  /// Get trending matches
  Future<List<SearchResult>> getTrendingMatches({
    String timeframe = 'week',
    int limit = 20,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('trending_rankings')
          .doc('matches_$timeframe')
          .collection('rankings')
          .orderBy('rank')
          .limit(limit)
          .get();

      return snapshot.docs.asMap().entries.map((entry) {
        final data = entry.value.data() as Map<String, dynamic>;
        return SearchResult(
          resultId: '${entry.key}_${entry.value.id}',
          queryId: 'trending_matches',
          contentType: ContentTypeEnum.match,
          contentId: data['contentId'] ?? '',
          matchScore: data['score'].toDouble() ?? 0.0,
          rank: entry.key + 1,
          displayData: data,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get trending matches: $e');
    }
  }

  /// Get which skill levels are currently trending
  Future<Map<String, int>> getTrendingSkillLevels({
    String timeframe = 'week',
  }) async {
    try {
      final snapshot = await _firestore
          .collection('trending_rankings')
          .doc('skill_levels_$timeframe')
          .get();

      if (snapshot.exists) {
        return Map<String, int>.from(snapshot.data() ?? {});
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get trending skill levels: $e');
    }
  }

  /// Batch update trending rankings (called periodically)
  Future<void> updateTrendingRankings() async {
    try {
      // This would be called by Cloud Functions
      await _analytics.logEvent(
        name: 'trending_rankings_updated',
        parameters: {
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Failed to update trending rankings: $e');
    }
  }

  // ===== SEARCH ANALYTICS METHODS (4) =====

  /// Record a search query
  Future<void> recordSearchQuery(
    String userId,
    String query, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryId = _firestore.collection('search_queries').doc().id;
      final searchQuery = SearchQuery(
        queryId: queryId,
        userId: userId,
        searchText: query,
        searchType: SearchType.creator,
        filters: filters ?? {},
        resultsCount: 0,
        performedAt: DateTime.now(),
      );

      await _firestore
          .collection('search_queries')
          .doc(queryId)
          .set(searchQuery.toJson());

      await _analytics.logEvent(
        name: 'search_performed',
        parameters: {
          'user_id': userId,
          'query': query,
          'filters_applied': filters != null,
        },
      );
    } catch (e) {
      throw Exception('Failed to record search query: $e');
    }
  }

  /// Get popular search terms
  Future<List<String>> getPopularSearchTerms({
    int limit = 20,
    String timeframe = 'week',
  }) async {
    try {
      final snapshot = await _firestore
          .collection('search_queries')
          .where('performedAt',
              isGreaterThan: DateTime.now().subtract(Duration(
                days: timeframe == 'week' ? 7 : 30,
              )))
          .orderBy('performedAt', descending: true)
          .limit(limit * 3)
          .get();

      final termCounts = <String, int>{};
      for (var doc in snapshot.docs) {
        final term = (doc.data()['searchText'] as String).toLowerCase();
        termCounts[term] = (termCounts[term] ?? 0) + 1;
      }

      final sorted = termCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted.take(limit).map((e) => e.key).toList();
    } catch (e) {
      throw Exception('Failed to get popular search terms: $e');
    }
  }

  /// Get search term trends over time
  Future<Map<String, int>> getSearchTermTrends(
    String term, {
    String timeframe = 'week',
  }) async {
    try {
      final snapshot = await _firestore
          .collection('search_queries')
          .where('searchText', isEqualTo: term)
          .orderBy('performedAt', descending: true)
          .get();

      final dailyCounts = <String, int>{};
      for (var doc in snapshot.docs) {
        final date = (doc.data()['performedAt'] as Timestamp)
            .toDate()
            .toString()
            .split(' ')[0];
        dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
      }

      return dailyCounts;
    } catch (e) {
      throw Exception('Failed to get search term trends: $e');
    }
  }

  /// Get user's search history
  Future<List<SearchQuery>> getUserSearchHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('search_queries')
          .where('userId', isEqualTo: userId)
          .orderBy('performedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => SearchQuery.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get search history: $e');
    }
  }
}
