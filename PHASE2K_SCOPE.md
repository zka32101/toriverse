# Phase 2k: Discovery & Recommendations Engine

**Status**: Planning  
**Target**: Help users discover content, creators, and matches aligned with interests  
**Estimated Models**: 8-10 Freezed classes  
**Estimated Repository Methods**: 25-30  
**Estimated Riverpod Providers**: 20+  
**Estimated Widgets**: 4-5  
**Documentation**: 500+ lines  

---

## Vision

Enable seamless content discovery through **intelligent recommendations**, **advanced search**, and **trending content feeds**. Transform casual users into engaged explorers of the Toriverse ecosystem by making it easy to find creators, matches, and clips that match their interests.

### Key Revenue Implications
- Increase daily session duration through discovery (retention)
- Surface monetized content (clips, creator subscriptions) to engaged audiences
- Enable creators to be discovered by new followers (growth flywheel)

---

## Domain Models (8-10 Total)

### Discovery (4 models)
1. **SearchQuery**
   - queryId, userId, searchText, searchType (creator, match, clip, clan)
   - filters (skillLevel, creatorTier, language, dateRange)
   - resultsCount, performedAt, isPopular
   - Track popular searches for trending insights

2. **RecommendationFeed**
   - feedId, userId, feedType (personalized, trending, followed_creators, recommended_clans)
   - items: [CreatorCard, ClipCard, MatchCard, ClanCard] (polymorphic)
   - generatedAt, expiresAt, confidence (0.0-1.0)
   - Real-time feed generation based on user behavior

3. **TrendingContent**
   - trendingId, contentType (creator, clip, match, clan, skillLevel)
   - contentId, rank, score (view count + engagement)
   - trendingCategory (this_week, this_month, all_time, gaming, entertainment)
   - generatedAt, expiresAt
   - Hourly/daily trending rankings

4. **DiscoveryAnalytics**
   - analyticsId, userId, action (view, click, share, follow, subscribe)
   - contentType, contentId, creatorId
   - clickedAt, durationViewed, conversionAction (follow/subscribe)
   - Feed implicit feedback for ML model training

### Search (3 models)
5. **SearchResult**
   - resultId, queryId, contentType, contentId
   - matchScore (relevance 0.0-1.0), rank
   - displayRank, resultMetadata (title, description, image)
   - Efficient search result caching

6. **CreatorSearchCard**
   - creatorId, displayName, bio, avatarUrl
   - followerCount, creatorTier, verificationBadge
   - topClipThisMonth, avgViewsPerClip
   - recentActivity (lastStreamedAt, lastClipUploadedAt)
   - Search-optimized creator display

7. **SavedSearch**
   - savedSearchId, userId, searchText, searchFilters
   - savedAt, lastExecutedAt, resultCount
   - Help users quickly re-execute frequent searches

### Analytics (2 models)
8. **DiscoveryMetrics**
   - metricsId, period (daily, weekly, monthly)
   - totalSearches, uniqueSearchers, avgResultsPerQuery
   - topSearchTerms, topTrendingCreators, topTrendingClips
   - discoveryRate (% users discovering new creators)
   - Platform-wide discovery health metrics

9. **UserPreferences**
   - userId, preferredSkillLevels (beginner, intermediate, advanced)
   - preferredCreatorTiers, preferredContentTypes (clips, matches, commentary)
   - languagePreferences, notificationPreferences
   - Personalization profile for recommendation engine

---

## Repository Methods (25-30 Total)

### Advanced Search (8 methods)
- `searchCreators(query, filters, limit)` — Full-text search on creators
- `searchClips(query, filters, limit)` — Search clips by title/tags
- `searchMatches(query, filters, limit)` — Search match archives
- `searchClans(query, filters, limit)` — Search clans by name/description
- `globalSearch(query, type, limit)` — Multi-type search
- `getSearchSuggestions(query)` — Autocomplete suggestions
- `saveSearch(userId, query, filters)` — Save frequent searches
- `getUserSavedSearches(userId)` — Retrieve saved searches

### Recommendations (8 methods)
- `getPersonalizedFeed(userId, limit)` — ML-based recommendations
- `getTrendingFeed(limit, timeframe)` — Trending creators/clips/matches
- `getFollowedCreatorsFeed(userId, limit)` — Feed from followed creators
- `getRecommendedClans(userId, limit)` — Clan recommendations
- `getNewCreatorsFeed(limit)` — Recently verified/joined creators
- `getRelatedCreators(creatorId, limit)` — Similar creator recommendations
- `generateRecommendations(userId)` — Batch generate via Cloud Functions
- `recordDiscoveryAction(userId, action, contentType, contentId)` — Log interactions

### Trending Content (5 methods)
- `getTrendingCreators(timeframe, limit)` — Top creators this period
- `getTrendingClips(timeframe, limit)` — Viral clips
- `getTrendingMatches(timeframe, limit)` — Popular match replays
- `getTrendingSkillLevels(timeframe)` — Which skill levels trending
- `updateTrendingRankings()` — Periodic batch update

### Search Analytics (4 methods)
- `recordSearchQuery(userId, query, filters)` — Log searches
- `getPopularSearchTerms(limit, timeframe)` — Most common searches
- `getSearchTermTrends(term, timeframe)` — Search volume over time
- `getUserSearchHistory(userId, limit)` — User's recent searches

---

## Riverpod Providers (20+ Total)

### StreamProviders (Real-time, 8 total)
- `watchPersonalizedFeedProvider` — Real-time personalized recommendations
- `watchTrendingFeedProvider` — Real-time trending content
- `watchFollowedCreatorsFeedProvider` — Followed creators' recent activity
- `watchRecommendedClansProvider` — Clan recommendations
- `watchSearchResultsProvider` — Search results with updates
- `watchTrendingCreatorsProvider` — Live trending creators
- `watchTrendingClipsProvider` — Live trending clips
- `watchDiscoveryMetricsProvider` — Platform-wide metrics (admin only)

### FutureProviders (Async, 10+ total)
- `personalizedFeedProvider` — Cached recommendations
- `trendingFeedProvider` — Trending content cache
- `followedCreatorsFeedProvider` — Followed creators feed
- `recommendedClansProvider` — Clan recommendations cache
- `searchResultsProvider` — Search results cache
- `searchSuggestionsProvider` — Autocomplete suggestions
- `userSavedSearchesProvider` — Saved searches list
- `trendingCreatorsProvider` — Top creators this period
- `trendingClipsProvider` — Viral clips this period
- `creatorSearchCardsProvider` — Search-optimized creator cards

### MutationProviders (Transactions, 3+ total)
- `recordDiscoveryActionProvider` → Invalidates feed/metrics
- `saveSearchProvider` → Invalidates saved searches
- `regenerateRecommendationsProvider` → Invalidates personalized feed

---

## Widgets (4-5 Total)

### 1. DiscoveryFeedWidget
- Personalized recommendations carousel
- "Discover" section on home screen
- Real-time trending indicators
- Swipe to accept/dismiss recommendations

### 2. AdvancedSearchWidget
- Multi-tab search (creators, clips, matches, clans)
- Filter controls (skill level, tier, date range, language)
- Search suggestions dropdown
- Saved search quick access

### 3. TrendingContentWidget
- Trending creators list (this week/month)
- Trending clips carousel (viral content)
- "What's Hot" badges on cards
- Time-period toggle (week/month/all-time)

### 4. CreatorDiscoveryCardWidget
- Large card for creator showcase
- Follower count, creator tier, verification badge
- Top clip preview
- Follow button

### 5. SearchResultsWidget (optional)
- Paginated search results list
- Result type indicators (creator, clip, match, clan)
- Relevance score display
- Sort/filter results

---

## Firestore Schema

```
firestore/
├── search_queries/
│   └── {queryId}: SearchQuery (archived for analytics)
├── trending_rankings/
│   ├── creators_{period}: [TrendingContent]
│   ├── clips_{period}: [TrendingContent]
│   ├── matches_{period}: [TrendingContent]
│   └── clans_{period}: [TrendingContent]
├── users/
│   └── {userId}/
│       ├── preferences: UserPreferences
│       ├── saved_searches/
│       │   └── {savedSearchId}: SavedSearch
│       ├── recommendation_feed/
│       │   └── {feedId}: RecommendationFeed (denormalized)
│       ├── discovery_actions/
│       │   └── {actionId}: DiscoveryAnalytics (implicit feedback)
│       └── search_history/
│           └── {queryId}: SearchQuery (denormalized)
├── discovery_analytics/
│   └── {metricsId}: DiscoveryMetrics (hourly aggregates)
└── search_indexes/
    ├── creators/ (full-text index)
    ├── clips/ (full-text index)
    ├── matches/ (full-text index)
    └── clans/ (full-text index)
```

### Composite Indexes Required
1. `creators` collection: (verified, followerCount DESC) for top verified creators
2. `clips` collection: (creatorId, viewCount DESC) for creator's top clips
3. `trending_rankings/creators_week`: (score DESC, rank ASC)
4. `trending_rankings/clips_week`: (score DESC, rank ASC)
5. `users/{userId}/search_history`: (savedAt DESC) for recent searches
6. `discovery_analytics`: (period DESC, totalSearches DESC) for trends

---

## Analytics Events

```dart
'search_performed' { user_id, query, search_type, result_count, filters_applied }
'search_result_clicked' { user_id, result_type, content_id, result_rank, click_time }
'recommendation_viewed' { user_id, feed_type, content_id, impression_position }
'recommendation_clicked' { user_id, feed_type, content_id, action (follow/subscribe/view) }
'trending_content_viewed' { user_id, content_type, content_id, trending_rank }
'discovery_action' { user_id, action_type, content_type, content_id, conversion }
'search_saved' { user_id, query, filters }
'saved_search_executed' { user_id, saved_search_id, query }
'feed_refreshed' { user_id, feed_type, new_items_count }
'creator_discovered' { discovering_user_id, discovered_creator_id, discovery_method (search/recommend/trending) }
```

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Search results load | < 800ms |
| Personalized feed generation | < 1.2s |
| Trending rankings update | < 2s (hourly) |
| Autocomplete suggestions | < 300ms |
| Search result ranking | < 500ms |
| Feed item display | < 60fps smooth scroll |

---

## Testing Strategy

- **Unit Tests** (20+ specs): Search algorithms, ranking logic, recommendation scoring
- **Widget Tests** (30+ specs): Search UI, discovery feed, trending display
- **Integration Tests** (3 specs): Search → view profile, Feed → follow creator, Trending → view clip

---

## Implementation Plan

### Step 1: Domain Models (8-10 classes)
- Search queries, recommendations, trending content, analytics models

### Step 2: Repository (25-30 methods)
- Search, recommendations, trending, analytics

### Step 3: Riverpod Providers (20+ providers)
- StreamProviders for real-time feeds
- FutureProviders for search/recommendations
- MutationProviders with cache invalidation

### Step 4: UI Widgets (4-5 widgets)
- Discovery feed, advanced search, trending display, creator cards

### Step 5: Tests & Documentation
- Comprehensive test specs
- 500+ line documentation

---

## Success Metrics

✅ All 8-10 models compile  
✅ All 25-30 repository methods work  
✅ All 20+ providers with proper invalidation  
✅ All 4-5 widgets render correctly  
✅ Search results < 800ms  
✅ Personalized feed < 1.2s  
✅ Trending rankings updated hourly  
✅ Discovery rate increase measurable in analytics  
✅ 95%+ test coverage on models  
✅ 20+ unit tests passing  
✅ 30+ widget tests passing  
✅ 3 integration tests passing  

---

**Next Steps:**
1. Confirm Phase 2k scope ✓
2. Implement domain models
3. Implement repository
4. Implement providers
5. Implement widgets
6. Test & document
7. Create PR #13
8. Merge & move to Phase 3

**Estimated Duration**: 4-6 hours continuous development

---

*Phase 2 Completion: After Phase 2k, Phase 2 (watch-to-enjoy platform) is complete with 11 sub-phases (2a-2k).*

*Next Phase: Phase 3 (Post-Launch Features & Community Building)*
