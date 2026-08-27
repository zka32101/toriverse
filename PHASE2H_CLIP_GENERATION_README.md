# Phase 2h — Clip Generation & Social Sharing

**Phase**: 2h (Post-Live Spectating)  
**Status**: In Development  
**Target Completion**: Q3 2026  
**OKR Focus**: Viral Coefficient (0.3-0.5), Share Growth, Creator Incentives

---

## Overview

Phase 2h implements automatic clip generation from highlight moments and multi-platform social sharing to drive viral growth. Clips are generated in multiple aspect ratios (16:9, 9:16, 1:1) optimized for different platforms (YouTube, Instagram, TikTok, Twitter, Twitch), with built-in share tracking, recommendation engine integration, and viral coefficient calculations.

### Key Features

1. **Multi-Format Clip Generation**: Generate clips in landscape (16:9), vertical (9:16), and square (1:1) formats
2. **Platform Optimization**: Automatic format selection based on platform (YouTube prefers 16:9, TikTok prefers 9:16, etc.)
3. **Social Share Tracking**: UTM-parametrized tracking URLs to measure click-through and viral spread
4. **Recommendation Engine**: Clips recommended to viewers based on watching history and viral scores
5. **Creator Profiles**: Track creator statistics (clips created, total views, engagement rate, follower count)
6. **Trending Leaderboard**: Real-time trending clips with velocity calculation and featured status
7. **Viral Tracking**: Share depth, unique reachers, viral coefficient calculation
8. **Comment Integration**: Collect comments and reactions from external platforms

---

## Architecture

### Layer Separation (MVVM)

```
Domain (Freezed Models)
↓
Data (Repository - Firestore operations)
↓
Application (Riverpod Providers - state management)
↓
Presentation (ConsumerWidgets - UI)
```

### Folder Structure

```
lib/features/clipping/
├── domain/
│   └── models/clip.dart                          # 12 Freezed models (292 lines)
├── data/
│   └── repositories/clip_repository.dart         # 20+ methods (650 lines)
├── application/
│   └── providers/clip_providers.dart             # 30+ providers (1000+ lines)
└── presentation/
    └── widgets/
        ├── clip_generator_widget.dart            # Clip creation UI
        ├── clip_share_widget.dart                # Social sharing UI
        ├── clip_metrics_widget.dart              # Engagement metrics
        └── trending_clips_widget.dart            # Trending leaderboard
```

---

## Domain Models (12 Freezed Classes)

### 1. **MatchClip**
Represents a generated video clip from a match highlight moment.

**Fields**:
- `id: String` — Unique clip identifier
- `matchId: String` — Reference to source match
- `highlightId: String` — Reference to highlight moment
- `creatorId: String` — User who created/triggered generation
- `title: String` — Clip title
- `description: String` — Clip description
- `durationSeconds: int` — Video length (default: 0)
- `startTimestamp: int` — Clip start position in match (seconds)
- `endTimestamp: int` — Clip end position in match (seconds)
- `momentType: String` — Event type (upset, strategic_move, key_turn, final_reversal)
- `isGenerated: bool` — Whether clip is ready (default: false)
- `isProcessing: bool` — Whether generation is in progress (default: false)
- `generatedAt: DateTime?` — Timestamp when generated
- `publishedAt: DateTime?` — Timestamp when published
- `formatIds: List<String>` — IDs of available formats (default: [])
- `totalViews: int` — Cumulative views (default: 0)
- `totalShares: int` — Cumulative shares (default: 0)
- `totalLikes: int` — Cumulative likes (default: 0)
- `engagementScore: int` — Aggregated engagement (default: 0)

**Firestore Path**: `/clips/{clipId}`

### 2. **ClipFormat**
Multiple aspect ratio variants of a single clip for different platforms.

**Fields**:
- `id: String` — Format-specific ID
- `clipId: String` — Reference to parent clip
- `aspectRatio: String` — Ratio (16:9, 9:16, 1:1)
- `platform: String` — Target platform (youtube, instagram, tiktok, twitter, twitch)
- `videoUrl: String` — CDN URL to video file
- `thumbnailUrl: String` — Thumbnail image URL (default: '')
- `fileSize: int` — Bytes (default: 0)
- `bitrate: int` — kbps (default: 0)
- `resolution: String` — 1080p, 720p, 480p
- `isReady: bool` — Whether format is ready for upload (default: false)
- `uploadedAt: DateTime?` — When uploaded to CDN
- `expiredAt: DateTime?` — Expiration time (for temporary formats)
- `views: int` — Format-specific views (default: 0)
- `likes: int` — Format-specific likes (default: 0)
- `shares: int` — Format-specific shares (default: 0)

**Firestore Path**: `/clips/{clipId}/formats/{formatId}`

### 3. **ClipUploadStatus**
Tracks clip distribution to social platforms.

**Fields**:
- `id: String` — Upload record ID
- `clipId: String` — Reference to clip
- `platform: String` — Target platform
- `status: String` — pending, uploading, uploaded, failed, processing
- `platformClipId: String` — External ID (YouTube video ID, Instagram post ID, etc.)
- `platformUrl: String` — Direct link to posted clip
- `uploadedAt: DateTime?` — Timestamp of successful upload
- `scheduledAt: DateTime?` — For scheduled posts
- `errorMessage: String` — Error details if failed (default: '')
- `retryCount: int` — Number of retry attempts (default: 0)
- `lastRetryAt: DateTime?` — Timestamp of last retry

**Firestore Path**: `/clips/{clipId}/uploads/{uploadStatusId}`

### 4. **ClipShare**
Social sharing record with tracking.

**Fields**:
- `id: String` — Share record ID
- `clipId: String` — Reference to clip
- `userId: String` — User who shared
- `platform: String` — Where shared (facebook, twitter, whatsapp, telegram, email, etc.)
- `shareType: String` — How shared (direct_link, embed, video_upload, story, etc.)
- `sharedAt: DateTime?` — When shared
- `isTracked: bool` — Whether tracking is enabled (default: false)
- `trackingUrl: String` — URL with UTM parameters (default: '')
- `clickCount: int` — Number of click-throughs (default: 0)
- `impressions: int` — Number of impressions (default: 0)

**Firestore Path**: `/clips/{clipId}/shares/{shareId}`

### 5. **ClipMetrics**
Aggregated engagement metrics across platforms.

**Fields**:
- `id: String` — Metrics record ID
- `clipId: String` — Reference to clip
- `totalViews: int` — Sum of all views (default: 0)
- `youtubeViews: int` — YouTube-only views (default: 0)
- `instagramViews: int` — Instagram-only views (default: 0)
- `tiktokViews: int` — TikTok-only views (default: 0)
- `twitterViews: int` — Twitter-only views (default: 0)
- `twitchViews: int` — Twitch-only views (default: 0)
- `totalLikes: int` — Sum of all likes (default: 0)
- `totalShares: int` — Sum of all shares (default: 0)
- `totalComments: int` — Sum of all comments (default: 0)
- `totalClicks: int` — Sum of tracking URL clicks (default: 0)
- `avgEngagementRate: double` — (likes + comments + shares) / views (default: 0.0)
- `viralScore: int` — Custom virality metric (default: 0)
- `updatedAt: DateTime?` — Last update timestamp

**Firestore Path**: `/clips/{clipId}/metrics/current`

### 6. **ClipGenerationConfig**
Settings for clip generation.

**Fields**:
- `id: String` — Config ID
- `template: String` — Generation template (standard, highlight_reel, dramatic, funny) (default: 'standard')
- `includeMusic: bool` — Add background music (default: true)
- `bgmTrackId: String` — Music track ID (default: '')
- `bgmVolume: double` — Music volume 0.0-1.0 (default: 1.0)
- `includeEffects: bool` — Add transitions/overlays/animations (default: true)
- `includeTextOverlay: bool` — Add player names/scores/stats (default: true)
- `textStyle: String` — Text styling (default, modern, retro, minimal) (default: 'default')
- `autoGenerateThumbnail: bool` — Auto-generate thumbnail (default: true)
- `generateVertical: bool` — Generate 9:16 format (default: true)
- `generateSquare: bool` — Generate 1:1 format (default: true)
- `generateLandscape: bool` — Generate 16:9 format (default: true)
- `colorGrade: String` — Color grading preset (default: '')
- `playbackSpeed: double` — Speed multiplier (default: 1.0)
- `platforms: List<String>` — Target platforms (default: [])

**Firestore Path**: `/clips/{clipId}/config/current`

### 7. **ClipGenerationJob**
Tracks clip generation progress.

**Fields**:
- `id: String` — Job ID
- `clipId: String` — Reference to clip
- `status: String` — queued, processing, completed, failed
- `progress: double` — 0.0-1.0 progress indicator (default: 0.0)
- `startedAt: DateTime?` — When processing started
- `completedAt: DateTime?` — When processing completed
- `errorMessage: String` — Error details if failed (default: '')
- `retryCount: int` — Number of retries (default: 0)
- `processorId: String` — ID of processing worker (default: '')
- `processingMetadata: Map<String, dynamic>` — Additional data (default: {})

**Firestore Path**: `/clips/{clipId}/generation_jobs/{jobId}`

### 8. **ClipRecommendation**
Recommendation engine record.

**Fields**:
- `id: String` — Recommendation ID
- `userId: String` — Target user
- `clipId: String` — Recommended clip
- `reason: String` — Why recommended (similar_match, trending, liked_by_friends, etc.) (default: '')
- `relevanceScore: double` — 0.0-1.0 confidence (default: 0.0)
- `recommendedAt: DateTime?` — When recommended
- `isClicked: bool` — Whether user clicked (default: false)
- `clickedAt: DateTime?` — When clicked
- `isShared: bool` — Whether user shared (default: false)

**Firestore Path**: `/users/{userId}/clip_recommendations/{recommendationId}`

### 9. **TrendingClip**
Trending clips leaderboard entry.

**Fields**:
- `rank: String` — Rank number (1, 2, 3, etc.)
- `clipId: String` — Reference to clip
- `title: String` — Clip title
- `viewsLast24h: int` — Views in last 24 hours (default: 0)
- `sharesLast24h: int` — Shares in last 24 hours (default: 0)
- `trendingVelocity: double` — Growth rate multiplier (default: 0.0)
- `totalViews: int` — Cumulative views (default: 0)
- `thumbnailUrl: String` — Thumbnail URL (default: '')
- `trendingStartedAt: DateTime?` — When trending started
- `isFeatured: bool` — Whether featured/promoted (default: false)

**Firestore Path**: `/trending_clips/{clipId}`

### 10. **ClipCreatorProfile**
Creator statistics and metadata.

**Fields**:
- `userId: String` — Creator's user ID
- `totalClipsCreated: int` — Lifetime clips (default: 0)
- `totalViews: int` — Sum of all clip views (default: 0)
- `totalShares: int` — Sum of all shares (default: 0)
- `totalLikes: int` — Sum of all likes (default: 0)
- `avgEngagementRate: double` — Average engagement rate (default: 0.0)
- `viralClips: int` — Clips with >100k views (default: 0)
- `lastClipAt: DateTime?` — When last clip created
- `followerCount: int` — Creator's followers (default: 0)
- `isVerified: bool` — Verified badge (default: false)
- `creatorRating: int` — 1-5 star rating (default: 0)

**Firestore Path**: `/clip_creators/{userId}`

### 11. **ClipComment**
Comments/reactions from external platforms.

**Fields**:
- `id: String` — Comment ID
- `clipId: String` — Reference to clip
- `userId: String` — Commenter's user ID
- `displayName: String` — Display name
- `comment: String` — Comment text
- `createdAt: DateTime?` — When posted
- `likes: int` — Like count (default: 0)
- `likedBy: List<String>` — User IDs who liked (default: [])
- `platform: String` — Source platform (default: '')
- `platformCommentId: String` — External platform ID (default: '')

**Firestore Path**: `/clips/{clipId}/comments/{commentId}`

### 12. **ViralTrackingData**
Tracks viral spread and share metrics.

**Fields**:
- `id: String` — Tracking record ID
- `clipId: String` — Reference to clip
- `totalShares: int` — Total share events (default: 0)
- `sharedByUserIds: List<String>` — User IDs who shared (default: [])
- `shareDepth: int` — Max distance from original sharer (default: 0)
- `uniqueReachers: int` — Unique users who saw via shares (default: 0)
- `viralCoefficient: double` — shares / views (default: 0.0)
- `measuredAt: DateTime?` — Measurement timestamp
- `topSharerIds: List<String>` — Most active sharers (default: [])

**Firestore Path**: `/clips/{clipId}/viral_tracking/current`

---

## Repository Methods (25 Methods)

### Clip Management (6 methods)

```dart
Future<MatchClip> createClip({
  required String matchId,
  required String highlightId,
  required String creatorId,
  required String title,
  required String description,
  required String momentType,
  required int startTimestamp,
  required int endTimestamp,
})
```
Creates new clip from highlight moment. Logs analytics event 'clip_created'.

```dart
Future<MatchClip?> getClip(String clipId)
```
Retrieves single clip by ID.

```dart
Stream<MatchClip?> watchClip(String clipId)
```
Real-time watch on single clip.

```dart
Future<List<MatchClip>> getClipsByMatch(String matchId)
```
Gets all clips from a match, ordered by publishedAt descending.

```dart
Future<List<MatchClip>> getCreatorClips(String creatorId)
```
Gets creator's clips (limited to 50 most recent).

```dart
Future<void> updateClip(String clipId, Map<String, dynamic> updates)
```
Updates clip metadata. Logs 'clip_updated' event.

```dart
Future<void> deleteClip(String clipId)
```
Deletes clip and all related documents (formats, uploads, shares, etc.). Logs 'clip_deleted' event.

### Clip Generation (3 methods)

```dart
Future<ClipGenerationJob> submitForGeneration(
  String clipId,
  ClipGenerationConfig config,
)
```
Submits clip for background processing. Creates generation job, stores config, updates clip status. Logs 'clip_generation_submitted' event with platforms.

```dart
Stream<ClipGenerationJob?> watchGenerationJob(String clipId, String jobId)
```
Real-time watch on generation job progress.

```dart
Future<void> completeGenerationJob(String clipId, String jobId)
```
Marks job completed, updates clip with isGenerated: true and generatedAt. Logs 'clip_generation_completed' event.

### Clip Formats (4 methods)

```dart
Future<void> addClipFormat(String clipId, ClipFormat format)
```
Adds new format variant to clip. Updates formatIds array.

```dart
Future<List<ClipFormat>> getClipFormats(String clipId)
```
Gets all format variants for a clip.

```dart
Future<ClipFormat?> getClipFormatByAspectRatio(
  String clipId,
  String aspectRatio,
)
```
Gets specific format by aspect ratio (e.g., "16:9").

```dart
Future<void> updateClipFormat(
  String clipId,
  String formatId,
  Map<String, dynamic> updates,
)
```
Updates format metadata (e.g., set isReady: true).

### Social Uploads (3 methods)

```dart
Future<void> recordUploadStatus(String clipId, ClipUploadStatus status)
```
Records upload attempt to platform. Logs 'clip_uploaded_to_platform' event with platform and status.

```dart
Stream<ClipUploadStatus?> watchUploadStatus(
  String clipId,
  String uploadStatusId,
)
```
Real-time watch on upload status.

```dart
Future<ClipUploadStatus?> getUploadStatusForPlatform(
  String clipId,
  String platform,
)
```
Gets upload status for specific platform (e.g., "youtube").

### Sharing (3 methods)

```dart
Future<void> shareClip(
  String clipId,
  String userId,
  String platform,
  String shareType,
)
```
Records share event. Creates ClipShare record with tracking URL, increments totalShares on clip. Logs 'clip_shared' event.

```dart
Future<List<ClipShare>> getClipShares(String clipId)
```
Gets all shares for a clip, ordered by sharedAt descending.

```dart
Future<void> trackShareClick(String clipId, String shareId)
```
Increments clickCount on share record.

**Tracking URL Generation**:
```dart
String _generateTrackingUrl(String clipId, String userId, String platform)
```
Generates UTM-parametrized tracking URL: `https://toriverse.app/clip/{clipId}?utm_source={platform}&utm_medium=share&utm_content={userId}`

### Metrics (4 methods)

```dart
Future<void> recordView(String clipId, String viewerId)
```
Increments totalViews on clip, logs view event.

```dart
Future<void> recordLike(String clipId, String userId)
```
Increments totalLikes on clip.

```dart
Future<ClipMetrics?> getClipMetrics(String clipId)
```
Gets aggregated metrics from `/clips/{clipId}/metrics/current`.

```dart
Future<void> updateClipMetrics(String clipId, ClipMetrics metrics)
```
Updates metrics document with merge options.

### Recommendations (3 methods)

```dart
Future<void> addRecommendation(ClipRecommendation recommendation)
```
Adds recommendation to user's feed.

```dart
Future<List<ClipRecommendation>> getRecommendations(String userId, {int limit = 20})
```
Gets user's personalized recommendations ordered by recommendedAt, limited to 20.

```dart
Future<void> markRecommendationClicked(String userId, String recommendationId)
```
Updates recommendation with isClicked: true and clickedAt timestamp.

### Trending (3 methods)

```dart
Future<List<TrendingClip>> getTrendingClips({int limit = 20})
```
Gets top 20 trending clips from `/trending_clips`, ordered by rank ascending.

```dart
Stream<List<TrendingClip>> watchTrendingClips({int limit = 20})
```
Real-time watch on trending clips collection.

```dart
Future<void> updateTrendingStatus(String clipId, TrendingClip trending)
```
Updates trending leaderboard entry with merge options.

### Creator Profiles (3 methods)

```dart
Future<ClipCreatorProfile?> getCreatorProfile(String userId)
```
Gets creator statistics from `/clip_creators/{userId}`.

```dart
Future<void> updateCreatorProfile(String userId, ClipCreatorProfile profile)
```
Updates profile with merge options.

```dart
Stream<ClipCreatorProfile?> watchCreatorProfile(String userId)
```
Real-time watch on creator profile.

### Viral Tracking (2 methods)

```dart
Future<ViralTrackingData?> getViralTrackingData(String clipId)
```
Gets viral tracking data from `/clips/{clipId}/viral_tracking/current`.

```dart
Future<void> updateViralTrackingData(String clipId, ViralTrackingData data)
```
Updates viral tracking data with merge options.

**Viral Coefficient Calculation**:
```dart
double calculateViralCoefficient(int shares, int views)
```
Returns `shares / views` (0.0 if views = 0). Target: 0.3-0.5.

---

## Riverpod Providers (30+ Providers)

### Repository Provider

```dart
final clipRepositoryProvider = Provider<ClipRepository>((ref) {
  return ClipRepository();
});
```

### Stream Providers (Real-time) — 5 providers

1. **watchClipProvider** — Family(ClipIdParam) — Single clip real-time
2. **watchTrendingClipsProvider** — Single — Trending list real-time
3. **watchCreatorProfileProvider** — Family(UserIdParam) — Creator profile real-time
4. **watchGenerationJobProvider** — Family(GenerationJobParam) — Job progress real-time
5. **watchUploadStatusProvider** — Family(UploadStatusParam) — Upload status real-time

All use `.autoDispose` to clean up when unused.

### Future Providers (Async) — 11 providers

1. **getClipProvider** — Family(ClipIdParam) — Single clip async
2. **clipsByMatchProvider** — Family(MatchIdParam) — Clips by match
3. **creatorClipsProvider** — Family(CreatorIdParam) — Creator's clips
4. **clipFormatsProvider** — Family(ClipIdParam) — All formats for clip
5. **clipFormatByAspectRatioProvider** — Family(AspectRatioParam) — Specific format
6. **clipSharesProvider** — Family(ClipIdParam) — All shares
7. **recommendationsProvider** — Family(UserIdParam) — User recommendations
8. **clipMetricsProvider** — Family(ClipIdParam) — Clip metrics
9. **creatorProfileProvider** — Family(UserIdParam) — Creator profile async
10. **viralTrackingDataProvider** — Family(ClipIdParam) — Viral metrics
11. **uploadStatusForPlatformProvider** — Family(PlatformParam) — Platform upload status

All use `.autoDispose` for efficient lifecycle management.

### Mutation Providers (State Changes) — 15 providers

Each mutation invalidates related providers for UI consistency:

1. **createClipProvider** — Creates clip, invalidates creatorClipsProvider + clipsByMatchProvider
2. **submitForGenerationProvider** — Submits for generation, invalidates watchGenerationJobProvider + watchClipProvider
3. **addClipFormatProvider** — Adds format, invalidates clipFormatsProvider
4. **shareClipProvider** — Shares clip, invalidates clipSharesProvider + clipMetricsProvider + viralTrackingDataProvider + watchClipProvider
5. **recordViewProvider** — Records view, invalidates clipMetricsProvider + watchClipProvider
6. **recordLikeProvider** — Records like, invalidates clipMetricsProvider + watchClipProvider
7. **completeGenerationJobProvider** — Completes job, invalidates watchGenerationJobProvider + watchClipProvider
8. **updateClipProvider** — Updates clip, invalidates watchClipProvider
9. **deleteClipProvider** — Deletes clip, invalidates all related providers
10. **addRecommendationProvider** — Adds recommendation, invalidates recommendationsProvider
11. **markRecommendationClickedProvider** — Marks clicked, invalidates recommendationsProvider
12. **updateTrendingStatusProvider** — Updates trending, invalidates watchTrendingClipsProvider
13. **recordUploadStatusProvider** — Records upload, invalidates watchUploadStatusProvider + uploadStatusForPlatformProvider
14. **trackShareClickProvider** — Tracks click, invalidates clipSharesProvider
15. Additional providers for updateClipFormat, updateClipMetrics, updateCreatorProfile, updateViralTrackingData

### Cache Invalidation Strategy

**Cascading invalidation ensures UI consistency**:
- When clip is shared → invalidate shares, metrics, viral tracking, clip data
- When view recorded → invalidate metrics, clip data
- When generation completes → invalidate generation job, clip data
- When format added → invalidate all formats list
- When trending updated → invalidate trending list
- When recommendation clicked → invalidate recommendations

---

## UI Components (4 Widgets)

### 1. ClipGeneratorWidget
**Purpose**: Create and submit clips for generation

**Features**:
- Title/description input fields
- Template selection (standard, highlight_reel, dramatic, funny)
- Format options: music, effects, text overlay, playback speed
- Aspect ratio selection: landscape (16:9), vertical (9:16), square (1:1)
- Platform selection: checkboxes for YouTube, Instagram, TikTok, Twitter, Twitch
- Validation: requires title
- Submission: calls createClipProvider + submitForGenerationProvider

**Lifecycle**:
1. User fills clip details
2. User selects formats and platforms
3. User taps "Submit for Generation"
4. createClipProvider creates clip
5. submitForGenerationProvider queues generation job
6. Success SnackBar shown
7. Form clears

### 2. ClipShareWidget
**Purpose**: Share clips to social platforms with tracking

**Features**:
- Modal dialog showing platform grid
- Share buttons: YouTube, Instagram, TikTok, Twitter, Twitch, More (native)
- Direct link display with copy button
- Platform-specific tracking URLs with UTM parameters
- Real-time share recording via shareClipProvider
- Success feedback

**Lifecycle**:
1. User opens share dialog
2. User taps platform button
3. shareClipProvider called with platform/shareType
4. Tracking URL generated (utm_source={platform}&utm_medium=share&utm_content={userId})
5. Success SnackBar shown
6. Metrics updated

### 3. ClipMetricsWidget
**Purpose**: Display clip engagement metrics and analytics

**Features**:
- Metric cards: Views, Likes, Shares, Comments, Clicks, Engagement Rate
- Large number formatting (1.0M, 1.0K)
- Platform breakdown: YouTube, Instagram, TikTok, Twitter, Twitch with percentages
- Progress bars showing platform distribution
- Viral score card (custom popularity ranking)
- Last updated timestamp
- Error handling and empty states
- Real-time updates via clipMetricsProvider

**Display**:
- Engagement Rate = (likes + comments + shares) / views * 100
- Viral Score = calculated metric reflecting popularity

### 4. TrendingClipsWidget
**Purpose**: Display trending clips leaderboard

**Features**:
- Ranked list of top 20 clips
- Rank badges with colors (#1=gold, #2=silver, #3=bronze, rest=blue)
- 24-hour metrics: Views, Shares, Velocity
- Total views counter
- "Featured" badge for promoted clips
- Trending start timestamp (relative time: "2h ago")
- Metrics: views(24h), shares(24h), velocity, total views
- Real-time updates via watchTrendingClipsProvider
- Scrollable list with smooth pagination

**Sorting**: By rank ascending (1, 2, 3, ...)

---

## Firestore Schema

### Collections

```
/clips/{clipId}
├── title: string
├── description: string
├── matchId: string
├── creatorId: string
├── isGenerated: boolean
├── isProcessing: boolean
├── generatedAt: timestamp
├── publishedAt: timestamp
├── totalViews: integer
├── totalShares: integer
├── totalLikes: integer
├── engagementScore: integer
├── formatIds: array
│
├── /clips/{clipId}/formats/{formatId}
│   ├── aspectRatio: string
│   ├── platform: string
│   ├── videoUrl: string
│   ├── isReady: boolean
│   └── views, likes, shares: integers
│
├── /clips/{clipId}/uploads/{uploadStatusId}
│   ├── platform: string
│   ├── status: string
│   ├── platformClipId: string
│   ├── platformUrl: string
│   └── retryCount: integer
│
├── /clips/{clipId}/shares/{shareId}
│   ├── userId: string
│   ├── platform: string
│   ├── trackingUrl: string
│   ├── clickCount: integer
│   └── sharedAt: timestamp
│
├── /clips/{clipId}/metrics/current
│   ├── totalViews: integer
│   ├── youtubeViews, instagramViews, tiktokViews: integers
│   ├── avgEngagementRate: double
│   ├── viralScore: integer
│   └── updatedAt: timestamp
│
├── /clips/{clipId}/generation_jobs/{jobId}
│   ├── status: string
│   ├── progress: double
│   └── completedAt: timestamp
│
├── /clips/{clipId}/config/current
│   ├── template: string
│   ├── platforms: array
│   └── [other generation settings]
│
└── /clips/{clipId}/viral_tracking/current
    ├── totalShares: integer
    ├── viralCoefficient: double
    ├── shareDepth: integer
    └── topSharerIds: array

/trending_clips/{clipId}
├── rank: string
├── title: string
├── viewsLast24h: integer
├── sharesLast24h: integer
├── trendingVelocity: double
├── isFeatured: boolean
└── trendingStartedAt: timestamp

/clip_creators/{userId}
├── totalClipsCreated: integer
├── totalViews: integer
├── avgEngagementRate: double
├── viralClips: integer
├── isVerified: boolean
└── creatorRating: integer

/users/{userId}/clip_recommendations/{recommendationId}
├── clipId: string
├── reason: string
├── relevanceScore: double
├── isClicked: boolean
└── recommendedAt: timestamp
```

### Required Indexes

1. `/clips` — composite index on (creatorId, publishedAt DESC)
2. `/clips` — composite index on (matchId, publishedAt DESC)
3. `/trending_clips` — simple index on rank ascending
4. `/users/{userId}/clip_recommendations` — simple index on recommendedAt descending

---

## Analytics Events

### Event: clip_created
```dart
{
  'clip_id': string,
  'match_id': string,
  'moment_type': string,
  'creator_id': string,
}
```

### Event: clip_generation_submitted
```dart
{
  'clip_id': string,
  'platforms': string (comma-separated),
  'template': string,
}
```

### Event: clip_generation_completed
```dart
{
  'clip_id': string,
  'duration_seconds': integer,
}
```

### Event: clip_uploaded_to_platform
```dart
{
  'clip_id': string,
  'platform': string,
  'status': string,
}
```

### Event: clip_shared
```dart
{
  'clip_id': string,
  'platform': string,
  'share_type': string,
  'user_id': string,
}
```

### Event: clip_viewed
```dart
{
  'clip_id': string,
  'viewer_id': string,
  'platform': string,
}
```

### Event: clip_liked
```dart
{
  'clip_id': string,
  'user_id': string,
}
```

### Event: share_clicked
```dart
{
  'clip_id': string,
  'platform': string,
  'utm_source': string,
}
```

### Event: recommendation_clicked
```dart
{
  'clip_id': string,
  'user_id': string,
  'reason': string,
}
```

---

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Clip creation | <500ms | Firestore write |
| Generation submission | <200ms | Job queue entry |
| Trending list load | <1s | 20 clips with metrics |
| Share tracking | <100ms | UTM URL generation + recording |
| Format generation | <30s | For all three aspect ratios |
| Viral coefficient calc | Real-time | Simple division math |
| Recommendation fetch | <1s | Top 20 personalized |
| Metrics aggregation | Hourly batch | Background task |

---

## Security & Access Control

### Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Clips — Anyone can read, only creator can update
    match /clips/{clipId} {
      allow read: if true;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.creatorId;
      allow update: if request.auth != null && request.auth.uid == resource.data.creatorId;
      allow delete: if request.auth != null && request.auth.uid == resource.data.creatorId;
      
      // Nested subcollections
      match /formats/{formatId} {
        allow read: if true;
        allow write: if request.auth != null && request.auth.uid == get(/databases/$(database)/documents/clips/$(clipId)).data.creatorId;
      }
      
      match /uploads/{uploadStatusId} {
        allow read: if request.auth != null;
        allow write: if request.auth.token.admin;
      }
      
      match /shares/{shareId} {
        allow read: if true;
        allow create: if request.auth != null;
        allow update: if request.auth != null;
      }
      
      match /metrics/current {
        allow read: if true;
        allow write: if request.auth.token.admin;
      }
      
      match /generation_jobs/{jobId} {
        allow read: if request.auth != null;
        allow write: if request.auth.token.admin;
      }
    }
    
    // Trending — Read-only for users, write for admin
    match /trending_clips/{clipId} {
      allow read: if true;
      allow write: if request.auth.token.admin;
    }
    
    // Creator profiles — Public read, only owner can update
    match /clip_creators/{userId} {
      allow read: if true;
      allow update: if request.auth != null && request.auth.uid == userId;
    }
    
    // Recommendations — Only owner can read
    match /users/{userId}/clip_recommendations/{recId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth.token.admin;
    }
  }
}
```

### Rate Limiting

- Share: 10 per minute per user
- View record: 100 per minute per clip
- Like: 10 per minute per user
- Recommendation add: 1000 per hour (system)

---

## Integration with Phase 2g (Live Spectating)

Clips are generated from **MatchHighlightMoment** records created during live spectating:

1. **Live Match** → Highlight moments recorded (Phase 2g)
2. **Clip Generator** → User creates clip from highlight (Phase 2h)
3. **Background Job** → Clip generated in multiple formats
4. **Social Upload** → Formats distributed to platforms
5. **Share Tracking** → UTM parameters track viral spread
6. **Metrics Aggregation** → Views/likes/shares aggregated hourly
7. **Trending Update** → High-engagement clips ranked in trending
8. **Recommendations** → Trending clips recommended to users

---

## Testing Strategy (50+ tests)

### Unit Tests (30+ tests)

**Models** (clip_models_test.dart):
- ✅ MatchClip serialization/deserialization
- ✅ ClipFormat multi-platform support
- ✅ ClipUploadStatus state transitions
- ✅ ClipShare tracking URL generation
- ✅ ClipMetrics engagement rate calculation
- ✅ ClipGenerationConfig template support
- ✅ ClipGenerationJob progress tracking
- ✅ ClipRecommendation relevance scoring
- ✅ TrendingClip ranking
- ✅ ClipCreatorProfile statistics
- ✅ ClipComment reactions
- ✅ ViralTrackingData coefficient calculation
- ✅ Model equality and hashing

### Widget Tests (25+ specs)

**ClipGeneratorWidget** (6 tests):
- ✅ Renders form fields
- ✅ Template selection updates state
- ✅ Format checkboxes work
- ✅ Platform selection toggles
- ✅ Validates title required
- ✅ Successful submission flow

**ClipShareWidget** (7 tests):
- ✅ Shows platform buttons
- ✅ Direct link display
- ✅ Share to each platform
- ✅ Native share dialog
- ✅ Multiple platform shares
- ✅ Tracking URL generation
- ✅ Dialog close

**ClipMetricsWidget** (7 tests):
- ✅ Displays metric cards
- ✅ Number formatting
- ✅ Platform breakdown
- ✅ Viral score display
- ✅ Loading state
- ✅ Error state
- ✅ Empty state

**TrendingClipsWidget** (7 tests):
- ✅ Displays trending list
- ✅ Rank badges with colors
- ✅ 24-hour metrics
- ✅ Featured badge
- ✅ Trending timestamp
- ✅ Real-time updates
- ✅ Tap navigation

**Integration** (3+ tests):
- ✅ Full creation → generation → sharing flow
- ✅ Multi-format generation
- ✅ Trending progression tracking

---

## Future Enhancements

1. **AI-Generated Titles**: Auto-generate catchy clip titles using ML
2. **Music Licensing**: Integrate licensed BGM library for copyright-free clips
3. **Comment Moderation**: ML-based comment filtering for toxicity
4. **Creator Monetization**: Revenue sharing based on clip performance
5. **Clip Reactions**: Emoji reactions in addition to likes
6. **Advanced Analytics**: Heatmaps showing when clips perform best
7. **Collaborative Clips**: Multiple creators combine their perspectives
8. **Scheduled Publishing**: Queue clips for automatic posting at optimal times
9. **Captions**: Auto-generate or manual captions for accessibility
10. **Clone Detection**: Prevent duplicate clips using video fingerprinting

---

## Deployment Checklist

- [ ] All 12 models compile with Freezed
- [ ] 25+ repository methods tested with Firestore
- [ ] 30+ Riverpod providers cache invalidation verified
- [ ] 4 widgets render and interact correctly
- [ ] 30+ unit tests pass
- [ ] 25+ widget specs implemented
- [ ] Analytics events logged correctly
- [ ] Security rules validated
- [ ] Performance targets met
- [ ] Integration with Phase 2g working
- [ ] PR created and merged
- [ ] Firebase indexes deployed
- [ ] Cloud Function for generation ready (placeholder)

---

**Phase 2h Complete** ✅  
**Next**: Monitor metrics, iterate on generation templates, prepare Phase 2i (Advanced Monetization)
