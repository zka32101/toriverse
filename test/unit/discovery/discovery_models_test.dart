import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/discovery/domain/models/discovery.dart';

void main() {
  group('Discovery Models Tests', () {
    group('SearchQuery', () {
      test('should create SearchQuery with all required fields', () {
        final query = SearchQuery(
          queryId: 'query_001',
          userId: 'user_001',
          searchText: 'top creator',
          searchType: SearchType.creator,
          performedAt: DateTime.now(),
        );

        expect(query.queryId, 'query_001');
        expect(query.userId, 'user_001');
        expect(query.searchText, 'top creator');
        expect(query.searchType, SearchType.creator);
      });

      test('should serialize and deserialize SearchQuery', () {
        final originalQuery = SearchQuery(
          queryId: 'query_001',
          userId: 'user_001',
          searchText: 'viral clip',
          searchType: SearchType.clip,
          resultsCount: 42,
          performedAt: DateTime(2026, 8, 28),
          isPopular: true,
        );

        final json = originalQuery.toJson();
        final deserializedQuery = SearchQuery.fromJson(json);

        expect(deserializedQuery.queryId, originalQuery.queryId);
        expect(deserializedQuery.searchText, originalQuery.searchText);
        expect(deserializedQuery.resultsCount, 42);
        expect(deserializedQuery.isPopular, true);
      });

      test('should support equality comparison', () {
        final query1 = SearchQuery(
          queryId: 'query_001',
          userId: 'user_001',
          searchText: 'test',
          searchType: SearchType.creator,
          performedAt: DateTime(2026, 8, 28),
        );

        final query2 = SearchQuery(
          queryId: 'query_001',
          userId: 'user_001',
          searchText: 'test',
          searchType: SearchType.creator,
          performedAt: DateTime(2026, 8, 28),
        );

        expect(query1, query2);
      });
    });

    group('RecommendationFeed', () {
      test('should create RecommendationFeed with personalized type', () {
        final feed = RecommendationFeed(
          feedId: 'feed_001',
          userId: 'user_001',
          feedType: RecommendationFeedType.personalized,
          items: [],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 6)),
        );

        expect(feed.feedId, 'feed_001');
        expect(feed.feedType, RecommendationFeedType.personalized);
        expect(feed.items, isEmpty);
      });

      test('should have default confidence score of 0.85', () {
        final feed = RecommendationFeed(
          feedId: 'feed_001',
          userId: 'user_001',
          feedType: RecommendationFeedType.trending,
          items: [],
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(feed.confidence, 0.85);
      });

      test('should serialize and deserialize RecommendationFeed', () {
        final originalFeed = RecommendationFeed(
          feedId: 'feed_001',
          userId: 'user_001',
          feedType: RecommendationFeedType.trending,
          items: const [
            {'creatorId': 'creator_001', 'displayName': 'Top Creator'}
          ],
          generatedAt: DateTime(2026, 8, 28, 10, 0),
          expiresAt: DateTime(2026, 8, 28, 11, 0),
          confidence: 0.95,
        );

        final json = originalFeed.toJson();
        final deserializedFeed = RecommendationFeed.fromJson(json);

        expect(deserializedFeed.feedId, originalFeed.feedId);
        expect(deserializedFeed.feedType, RecommendationFeedType.trending);
        expect(deserializedFeed.confidence, 0.95);
      });
    });

    group('TrendingContent', () {
      test('should create TrendingContent with rank and score', () {
        final trending = TrendingContent(
          trendingId: 'trend_001',
          contentType: ContentTypeEnum.creator,
          contentId: 'creator_001',
          rank: 1,
          score: 9850.5,
          trendingCategory: TrendingCategory.thisWeek,
          generatedAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );

        expect(trending.rank, 1);
        expect(trending.score, 9850.5);
        expect(trending.contentType, ContentTypeEnum.creator);
      });

      test('should support different trending categories', () {
        final categories = [
          TrendingCategory.thisWeek,
          TrendingCategory.thisMonth,
          TrendingCategory.allTime,
          TrendingCategory.gaming,
          TrendingCategory.entertainment,
        ];

        for (var category in categories) {
          final trending = TrendingContent(
            trendingId: 'trend_${category.name}',
            contentType: ContentTypeEnum.clip,
            contentId: 'clip_001',
            trendingCategory: category,
            generatedAt: DateTime.now(),
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          );

          expect(trending.trendingCategory, category);
        }
      });
    });

    group('DiscoveryAnalytics', () {
      test('should record discovery action with type and content', () {
        final analytics = DiscoveryAnalytics(
          analyticsId: 'analytics_001',
          userId: 'user_001',
          action: DiscoveryActionType.view,
          contentType: ContentTypeEnum.clip,
          contentId: 'clip_001',
          creatorId: 'creator_001',
          actionAt: DateTime.now(),
        );

        expect(analytics.action, DiscoveryActionType.view);
        expect(analytics.contentType, ContentTypeEnum.clip);
        expect(analytics.conversionAction, false);
      });

      test('should track conversion actions', () {
        final followAction = DiscoveryAnalytics(
          analyticsId: 'analytics_001',
          userId: 'user_001',
          action: DiscoveryActionType.follow,
          contentType: ContentTypeEnum.creator,
          contentId: 'creator_001',
          actionAt: DateTime.now(),
          conversionAction: true,
        );

        expect(followAction.action, DiscoveryActionType.follow);
        expect(followAction.conversionAction, true);
      });

      test('should track duration viewed', () {
        final analytics = DiscoveryAnalytics(
          analyticsId: 'analytics_001',
          userId: 'user_001',
          action: DiscoveryActionType.view,
          contentType: ContentTypeEnum.clip,
          contentId: 'clip_001',
          actionAt: DateTime.now(),
          durationViewed: 45000, // 45 seconds in ms
        );

        expect(analytics.durationViewed, 45000);
      });
    });

    group('CreatorSearchCard', () {
      test('should create creator search card with minimal data', () {
        final card = CreatorSearchCard(
          creatorId: 'creator_001',
          displayName: 'Top Creator',
        );

        expect(card.creatorId, 'creator_001');
        expect(card.displayName, 'Top Creator');
        expect(card.followerCount, 0);
        expect(card.verificationBadge, false);
      });

      test('should include all creator stats', () {
        final card = CreatorSearchCard(
          creatorId: 'creator_001',
          displayName: 'Top Creator',
          bio: 'Professional gamer',
          avatarUrl: 'https://example.com/avatar.jpg',
          followerCount: 5000,
          creatorTier: 'verified',
          verificationBadge: true,
          topClipThisMonth: 'clip_001',
          avgViewsPerClip: 2500.0,
          lastStreamedAt: DateTime.now().subtract(const Duration(hours: 2)),
          lastClipUploadedAt: DateTime.now().subtract(const Duration(hours: 6)),
        );

        expect(card.followerCount, 5000);
        expect(card.verificationBadge, true);
        expect(card.avgViewsPerClip, 2500.0);
      });
    });

    group('SavedSearch', () {
      test('should save search with filters', () {
        final saved = SavedSearch(
          savedSearchId: 'saved_001',
          userId: 'user_001',
          searchText: 'advanced tier creators',
          searchFilters: {
            'skillLevel': 'advanced',
            'creatorTier': 'verified',
          },
          savedAt: DateTime(2026, 8, 28),
        );

        expect(saved.searchText, 'advanced tier creators');
        expect(saved.searchFilters['skillLevel'], 'advanced');
      });

      test('should track last execution', () {
        final saved = SavedSearch(
          savedSearchId: 'saved_001',
          userId: 'user_001',
          searchText: 'test query',
          savedAt: DateTime(2026, 8, 28, 10, 0),
          lastExecutedAt: DateTime(2026, 8, 28, 15, 30),
          resultCount: 42,
        );

        expect(saved.lastExecutedAt, isNotNull);
        expect(saved.resultCount, 42);
      });
    });

    group('DiscoveryMetrics', () {
      test('should aggregate platform-wide metrics', () {
        final metrics = DiscoveryMetrics(
          metricsId: 'metrics_2026_08',
          period: 'daily',
          totalSearches: 5000,
          uniqueSearchers: 1200,
          avgResultsPerQuery: 15.5,
          topSearchTerms: ['creator', 'viral clip', 'tournament'],
          topTrendingCreators: ['creator_001', 'creator_002'],
          topTrendingClips: ['clip_001', 'clip_002'],
          discoveryRate: 0.35,
          generatedAt: DateTime.now(),
        );

        expect(metrics.totalSearches, 5000);
        expect(metrics.uniqueSearchers, 1200);
        expect(metrics.discoveryRate, 0.35);
        expect(metrics.topSearchTerms.length, 3);
      });
    });

    group('UserPreferences', () {
      test('should store user personalization preferences', () {
        final prefs = UserPreferences(
          userId: 'user_001',
          preferredSkillLevels: ['intermediate', 'advanced'],
          preferredCreatorTiers: ['verified', 'featured'],
          preferredContentTypes: ['clips', 'matches'],
          languagePreference: 'en',
          notificationsEnabled: true,
          updatedAt: DateTime.now(),
        );

        expect(prefs.preferredSkillLevels.length, 2);
        expect(prefs.preferredContentTypes, containsAll(['clips', 'matches']));
        expect(prefs.notificationsEnabled, true);
      });
    });
  });
}
