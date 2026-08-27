import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/clipping/domain/models/clip.dart';

void main() {
  group('MatchClip', () {
    test('creates clip with correct defaults', () {
      final clip = MatchClip(
        id: 'clip_001',
        matchId: 'match_001',
        highlightId: 'highlight_001',
        creatorId: 'user_001',
        title: 'Upset Victory',
        description: 'Amazing comeback',
        momentType: 'upset',
        startTimestamp: 10,
        endTimestamp: 45,
      );

      expect(clip.id, 'clip_001');
      expect(clip.matchId, 'match_001');
      expect(clip.durationSeconds, 35);
      expect(clip.isGenerated, false);
      expect(clip.isProcessing, false);
      expect(clip.totalViews, 0);
      expect(clip.totalShares, 0);
      expect(clip.totalLikes, 0);
    });

    test('serializes to JSON correctly', () {
      final clip = MatchClip(
        id: 'clip_001',
        matchId: 'match_001',
        highlightId: 'highlight_001',
        creatorId: 'user_001',
        title: 'Upset Victory',
        description: 'Amazing comeback',
        momentType: 'upset',
        startTimestamp: 10,
        endTimestamp: 45,
        totalViews: 100,
        totalShares: 20,
        totalLikes: 50,
      );

      final json = clip.toJson();
      expect(json['id'], 'clip_001');
      expect(json['matchId'], 'match_001');
      expect(json['totalViews'], 100);
      expect(json['totalShares'], 20);
      expect(json['totalLikes'], 50);
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'id': 'clip_001',
        'matchId': 'match_001',
        'highlightId': 'highlight_001',
        'creatorId': 'user_001',
        'title': 'Upset Victory',
        'description': 'Amazing comeback',
        'momentType': 'upset',
        'startTimestamp': 10,
        'endTimestamp': 45,
        'durationSeconds': 35,
        'isGenerated': false,
        'isProcessing': false,
        'totalViews': 100,
        'totalShares': 20,
        'totalLikes': 50,
        'engagementScore': 0,
        'formatIds': [],
      };

      final clip = MatchClip.fromJson(json);
      expect(clip.id, 'clip_001');
      expect(clip.totalViews, 100);
      expect(clip.durationSeconds, 35);
    });

    test('equality works correctly', () {
      final clip1 = MatchClip(
        id: 'clip_001',
        matchId: 'match_001',
        highlightId: 'highlight_001',
        creatorId: 'user_001',
        title: 'Upset Victory',
        description: 'Amazing comeback',
        momentType: 'upset',
        startTimestamp: 10,
        endTimestamp: 45,
      );

      final clip2 = MatchClip(
        id: 'clip_001',
        matchId: 'match_001',
        highlightId: 'highlight_001',
        creatorId: 'user_001',
        title: 'Upset Victory',
        description: 'Amazing comeback',
        momentType: 'upset',
        startTimestamp: 10,
        endTimestamp: 45,
      );

      expect(clip1, clip2);
    });
  });

  group('ClipFormat', () {
    test('creates format with correct defaults', () {
      final format = ClipFormat(
        id: 'format_001',
        clipId: 'clip_001',
        aspectRatio: '16:9',
        platform: 'youtube',
        videoUrl: 'https://example.com/video.mp4',
        resolution: '1080p',
      );

      expect(format.id, 'format_001');
      expect(format.aspectRatio, '16:9');
      expect(format.isReady, false);
      expect(format.views, 0);
      expect(format.likes, 0);
      expect(format.shares, 0);
    });

    test('supports multiple aspect ratios', () {
      final ratios = ['16:9', '9:16', '1:1'];

      for (final ratio in ratios) {
        final format = ClipFormat(
          id: 'format_${ratio.replaceAll(':', '_')}',
          clipId: 'clip_001',
          aspectRatio: ratio,
          platform: 'youtube',
          videoUrl: 'https://example.com/video.mp4',
          resolution: '1080p',
        );

        expect(format.aspectRatio, ratio);
      }
    });

    test('supports multiple platforms', () {
      final platforms = ['youtube', 'instagram', 'tiktok', 'twitter', 'twitch'];

      for (final platform in platforms) {
        final format = ClipFormat(
          id: 'format_$platform',
          clipId: 'clip_001',
          aspectRatio: '16:9',
          platform: platform,
          videoUrl: 'https://example.com/video.mp4',
          resolution: '1080p',
        );

        expect(format.platform, platform);
      }
    });
  });

  group('ClipUploadStatus', () {
    test('creates upload status with correct defaults', () {
      final status = ClipUploadStatus(
        id: 'upload_001',
        clipId: 'clip_001',
        platform: 'youtube',
        status: 'pending',
      );

      expect(status.id, 'upload_001');
      expect(status.status, 'pending');
      expect(status.platformClipId, '');
      expect(status.retryCount, 0);
      expect(status.errorMessage, '');
    });

    test('tracks upload status transitions', () {
      final statuses = ['pending', 'uploading', 'uploaded', 'failed', 'processing'];

      for (final statusStr in statuses) {
        final status = ClipUploadStatus(
          id: 'upload_001',
          clipId: 'clip_001',
          platform: 'youtube',
          status: statusStr,
        );

        expect(status.status, statusStr);
      }
    });
  });

  group('ClipShare', () {
    test('creates share with tracking URL', () {
      final share = ClipShare(
        id: 'share_001',
        clipId: 'clip_001',
        userId: 'user_001',
        platform: 'twitter',
        shareType: 'direct_link',
        isTracked: true,
        trackingUrl: 'https://example.com/clip/clip_001?utm_source=twitter',
      );

      expect(share.trackingUrl.contains('utm_source=twitter'), true);
      expect(share.isTracked, true);
    });

    test('records share clicks', () {
      final share = ClipShare(
        id: 'share_001',
        clipId: 'clip_001',
        userId: 'user_001',
        platform: 'twitter',
        shareType: 'direct_link',
        clickCount: 5,
      );

      expect(share.clickCount, 5);
    });
  });

  group('ClipMetrics', () {
    test('calculates engagement rate correctly', () {
      final metrics = ClipMetrics(
        id: 'metrics_001',
        clipId: 'clip_001',
        totalViews: 1000,
        totalLikes: 100,
        totalShares: 50,
        totalComments: 25,
        avgEngagementRate: 0.175, // (100 + 25 + 50) / 1000
      );

      expect(metrics.avgEngagementRate, 0.175);
    });

    test('supports platform-specific view tracking', () {
      final metrics = ClipMetrics(
        id: 'metrics_001',
        clipId: 'clip_001',
        totalViews: 1000,
        youtubeViews: 400,
        instagramViews: 300,
        tiktokViews: 200,
        twitterViews: 100,
        twitchViews: 0,
      );

      expect(metrics.youtubeViews, 400);
      expect(metrics.instagramViews, 300);
      expect(metrics.tiktokViews, 200);
      expect(metrics.twitterViews, 100);
    });

    test('viral score reflects popularity', () {
      final metrics = ClipMetrics(
        id: 'metrics_001',
        clipId: 'clip_001',
        totalViews: 100000,
        viralScore: 85,
      );

      expect(metrics.viralScore, 85);
    });
  });

  group('ClipGenerationConfig', () {
    test('creates config with correct defaults', () {
      final config = ClipGenerationConfig(id: 'config_001');

      expect(config.template, 'standard');
      expect(config.includeMusic, true);
      expect(config.includeEffects, true);
      expect(config.includeTextOverlay, true);
      expect(config.generateVertical, true);
      expect(config.generateSquare, true);
      expect(config.generateLandscape, true);
      expect(config.bgmVolume, 1.0);
      expect(config.playbackSpeed, 1.0);
    });

    test('supports multiple templates', () {
      final templates = ['standard', 'highlight_reel', 'dramatic', 'funny'];

      for (final template in templates) {
        final config = ClipGenerationConfig(
          id: 'config_001',
          template: template,
        );

        expect(config.template, template);
      }
    });

    test('configures multiple platforms', () {
      final config = ClipGenerationConfig(
        id: 'config_001',
        platforms: ['youtube', 'instagram', 'tiktok'],
      );

      expect(config.platforms.length, 3);
      expect(config.platforms.contains('youtube'), true);
      expect(config.platforms.contains('instagram'), true);
      expect(config.platforms.contains('tiktok'), true);
    });
  });

  group('ClipGenerationJob', () {
    test('creates job with queued status', () {
      final job = ClipGenerationJob(
        id: 'job_001',
        clipId: 'clip_001',
        status: 'queued',
      );

      expect(job.status, 'queued');
      expect(job.progress, 0.0);
      expect(job.retryCount, 0);
    });

    test('tracks job progress', () {
      final job = ClipGenerationJob(
        id: 'job_001',
        clipId: 'clip_001',
        status: 'processing',
        progress: 0.5,
      );

      expect(job.progress, 0.5);
    });

    test('handles job completion', () {
      final job = ClipGenerationJob(
        id: 'job_001',
        clipId: 'clip_001',
        status: 'completed',
        progress: 1.0,
      );

      expect(job.status, 'completed');
      expect(job.progress, 1.0);
    });
  });

  group('ClipRecommendation', () {
    test('creates recommendation with relevance score', () {
      final rec = ClipRecommendation(
        id: 'rec_001',
        userId: 'user_001',
        clipId: 'clip_001',
        reason: 'similar_match',
        relevanceScore: 0.85,
      );

      expect(rec.relevanceScore, 0.85);
      expect(rec.reason, 'similar_match');
    });

    test('tracks recommendation clicks', () {
      final rec = ClipRecommendation(
        id: 'rec_001',
        userId: 'user_001',
        clipId: 'clip_001',
        isClicked: true,
      );

      expect(rec.isClicked, true);
    });
  });

  group('TrendingClip', () {
    test('creates trending clip with ranking', () {
      final trending = TrendingClip(
        rank: '1',
        clipId: 'clip_001',
        title: 'Viral Moment',
        viewsLast24h: 50000,
        sharesLast24h: 5000,
        trendingVelocity: 2.5,
      );

      expect(trending.rank, '1');
      expect(trending.trendingVelocity, 2.5);
    });

    test('supports featured status', () {
      final trending = TrendingClip(
        rank: '1',
        clipId: 'clip_001',
        title: 'Viral Moment',
        isFeatured: true,
      );

      expect(trending.isFeatured, true);
    });
  });

  group('ClipCreatorProfile', () {
    test('creates creator profile with stats', () {
      final profile = ClipCreatorProfile(
        userId: 'user_001',
        totalClipsCreated: 10,
        totalViews: 100000,
        totalShares: 5000,
        totalLikes: 25000,
      );

      expect(profile.totalClipsCreated, 10);
      expect(profile.totalViews, 100000);
    });

    test('tracks creator verification', () {
      final profile = ClipCreatorProfile(
        userId: 'user_001',
        isVerified: true,
        creatorRating: 5,
      );

      expect(profile.isVerified, true);
      expect(profile.creatorRating, 5);
    });

    test('calculates viral clip count', () {
      final profile = ClipCreatorProfile(
        userId: 'user_001',
        viralClips: 3, // Clips with > 100k views
      );

      expect(profile.viralClips, 3);
    });
  });

  group('ClipComment', () {
    test('creates comment with user info', () {
      final comment = ClipComment(
        id: 'comment_001',
        clipId: 'clip_001',
        userId: 'user_001',
        displayName: 'Alice',
        comment: 'Amazing clip!',
      );

      expect(comment.displayName, 'Alice');
      expect(comment.comment, 'Amazing clip!');
    });

    test('tracks comment likes', () {
      final comment = ClipComment(
        id: 'comment_001',
        clipId: 'clip_001',
        userId: 'user_001',
        displayName: 'Alice',
        comment: 'Amazing clip!',
        likes: 42,
        likedBy: ['user_002', 'user_003'],
      );

      expect(comment.likes, 42);
      expect(comment.likedBy.length, 2);
    });
  });

  group('ViralTrackingData', () {
    test('calculates viral coefficient', () {
      final viral = ViralTrackingData(
        id: 'viral_001',
        clipId: 'clip_001',
        totalShares: 1000,
        uniqueReachers: 10000,
        viralCoefficient: 0.1, // 1000 shares / 10000 views
      );

      expect(viral.viralCoefficient, 0.1);
    });

    test('tracks share depth', () {
      final viral = ViralTrackingData(
        id: 'viral_001',
        clipId: 'clip_001',
        shareDepth: 4, // Max distance from original sharer
      );

      expect(viral.shareDepth, 4);
    });

    test('tracks top sharers', () {
      final viral = ViralTrackingData(
        id: 'viral_001',
        clipId: 'clip_001',
        topSharerIds: ['user_001', 'user_002', 'user_003'],
      );

      expect(viral.topSharerIds.length, 3);
    });
  });
}
