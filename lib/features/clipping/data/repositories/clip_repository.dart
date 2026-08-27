import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/clipping/domain/models/clip.dart';

/// Repository for clip generation and social sharing operations
///
/// Handles clip generation, format management, social platform uploads,
/// engagement tracking, and viral growth monitoring.
class ClipRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;

  ClipRepository({
    FirebaseFirestore? firestore,
    FirebaseAnalytics? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? FirebaseAnalytics.instance;

  // ============ CLIP MANAGEMENT ============

  /// Create new clip from highlight moment
  Future<MatchClip> createClip({
    required String matchId,
    required String highlightId,
    required String creatorId,
    required String title,
    required String description,
    required String momentType,
    required int startTimestamp,
    required int endTimestamp,
  }) async {
    final clipId = 'clip_${matchId}_${DateTime.now().millisecondsSinceEpoch}';

    final clip = MatchClip(
      id: clipId,
      matchId: matchId,
      highlightId: highlightId,
      creatorId: creatorId,
      title: title,
      description: description,
      durationSeconds: endTimestamp - startTimestamp,
      startTimestamp: startTimestamp,
      endTimestamp: endTimestamp,
      momentType: momentType,
      isGenerated: false,
      isProcessing: false,
    );

    await _firestore
        .collection('clips')
        .doc(clipId)
        .set(clip.toJson());

    await _analytics.logEvent(
      name: 'clip_created',
      parameters: {
        'clip_id': clipId,
        'match_id': matchId,
        'moment_type': momentType,
      },
    );

    return clip;
  }

  /// Get clip by ID
  Future<MatchClip?> getClip(String clipId) async {
    final doc = await _firestore.collection('clips').doc(clipId).get();
    if (doc.exists) {
      return MatchClip.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Watch clip in real-time
  Stream<MatchClip?> watchClip(String clipId) {
    return _firestore
        .collection('clips')
        .doc(clipId)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return MatchClip.fromJson(snap.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get clips by match
  Future<List<MatchClip>> getClipsByMatch(String matchId) async {
    final snap = await _firestore
        .collection('clips')
        .where('matchId', isEqualTo: matchId)
        .orderBy('publishedAt', descending: true)
        .get();

    return snap.docs
        .map((doc) => MatchClip.fromJson(doc.data()))
        .toList();
  }

  /// Get creator's clips
  Future<List<MatchClip>> getCreatorClips(String creatorId) async {
    final snap = await _firestore
        .collection('clips')
        .where('creatorId', isEqualTo: creatorId)
        .orderBy('publishedAt', descending: true)
        .limit(50)
        .get();

    return snap.docs
        .map((doc) => MatchClip.fromJson(doc.data()))
        .toList();
  }

  /// Update clip metadata
  Future<void> updateClip(String clipId, Map<String, dynamic> updates) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .update(updates);

    await _analytics.logEvent(
      name: 'clip_updated',
      parameters: {'clip_id': clipId},
    );
  }

  /// Delete clip
  Future<void> deleteClip(String clipId) async {
    await _firestore.collection('clips').doc(clipId).delete();

    // Clean up related documents
    final formatsSnap = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('formats')
        .get();

    for (final doc in formatsSnap.docs) {
      await doc.reference.delete();
    }

    await _analytics.logEvent(
      name: 'clip_deleted',
      parameters: {'clip_id': clipId},
    );
  }

  // ============ CLIP GENERATION ============

  /// Submit clip for generation
  Future<ClipGenerationJob> submitForGeneration(
    String clipId,
    ClipGenerationConfig config,
  ) async {
    final jobId = 'job_$clipId';

    final job = ClipGenerationJob(
      id: jobId,
      clipId: clipId,
      status: 'queued',
      progress: 0.0,
    );

    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('generation_jobs')
        .doc(jobId)
        .set(job.toJson());

    // Store config
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('config')
        .doc('current')
        .set(config.toJson());

    // Update clip status
    await updateClip(clipId, {
      'isProcessing': true,
      'isGenerated': false,
    });

    await _analytics.logEvent(
      name: 'clip_generation_submitted',
      parameters: {
        'clip_id': clipId,
        'platforms': config.platforms.join(','),
      },
    );

    return job;
  }

  /// Watch generation job progress
  Stream<ClipGenerationJob?> watchGenerationJob(String clipId, String jobId) {
    return _firestore
        .collection('clips')
        .doc(clipId)
        .collection('generation_jobs')
        .doc(jobId)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return ClipGenerationJob.fromJson(snap.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Mark generation job as completed
  Future<void> completeGenerationJob(String clipId, String jobId) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('generation_jobs')
        .doc(jobId)
        .update({
      'status': 'completed',
      'progress': 1.0,
      'completedAt': FieldValue.serverTimestamp(),
    });

    // Update clip
    await updateClip(clipId, {
      'isProcessing': false,
      'isGenerated': true,
      'generatedAt': FieldValue.serverTimestamp(),
    });

    await _analytics.logEvent(
      name: 'clip_generation_completed',
      parameters: {'clip_id': clipId},
    );
  }

  // ============ CLIP FORMATS ============

  /// Add clip format (aspect ratio/platform variant)
  Future<void> addClipFormat(String clipId, ClipFormat format) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('formats')
        .doc(format.id)
        .set(format.toJson());

    // Update clip formatIds list
    await _firestore
        .collection('clips')
        .doc(clipId)
        .update({
      'formatIds': FieldValue.arrayUnion([format.id]),
    });
  }

  /// Get all formats for clip
  Future<List<ClipFormat>> getClipFormats(String clipId) async {
    final snap = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('formats')
        .get();

    return snap.docs
        .map((doc) => ClipFormat.fromJson(doc.data()))
        .toList();
  }

  /// Get format by aspect ratio
  Future<ClipFormat?> getClipFormatByAspectRatio(
    String clipId,
    String aspectRatio,
  ) async {
    final snap = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('formats')
        .where('aspectRatio', isEqualTo: aspectRatio)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      return ClipFormat.fromJson(snap.docs.first.data());
    }
    return null;
  }

  /// Update format status
  Future<void> updateClipFormat(
    String clipId,
    String formatId,
    Map<String, dynamic> updates,
  ) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('formats')
        .doc(formatId)
        .update(updates);
  }

  // ============ SOCIAL UPLOADS ============

  /// Record clip upload to platform
  Future<void> recordUploadStatus(String clipId, ClipUploadStatus status) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('uploads')
        .doc(status.id)
        .set(status.toJson(), SetOptions(merge: true));

    await _analytics.logEvent(
      name: 'clip_uploaded_to_platform',
      parameters: {
        'clip_id': clipId,
        'platform': status.platform,
        'status': status.status,
      },
    );
  }

  /// Watch upload status
  Stream<ClipUploadStatus?> watchUploadStatus(
    String clipId,
    String uploadStatusId,
  ) {
    return _firestore
        .collection('clips')
        .doc(clipId)
        .collection('uploads')
        .doc(uploadStatusId)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return ClipUploadStatus.fromJson(snap.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Get upload status for platform
  Future<ClipUploadStatus?> getUploadStatusForPlatform(
    String clipId,
    String platform,
  ) async {
    final snap = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('uploads')
        .where('platform', isEqualTo: platform)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      return ClipUploadStatus.fromJson(snap.docs.first.data());
    }
    return null;
  }

  // ============ SHARING ============

  /// Record clip share
  Future<void> shareClip(
    String clipId,
    String userId,
    String platform,
    String shareType,
  ) async {
    final shareId = 'share_${clipId}_${userId}_${DateTime.now().millisecondsSinceEpoch}';

    final share = ClipShare(
      id: shareId,
      clipId: clipId,
      userId: userId,
      platform: platform,
      shareType: shareType,
      sharedAt: DateTime.now(),
      isTracked: true,
      trackingUrl: _generateTrackingUrl(clipId, userId, platform),
    );

    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('shares')
        .doc(shareId)
        .set(share.toJson());

    // Increment share count
    await _firestore
        .collection('clips')
        .doc(clipId)
        .update({
      'totalShares': FieldValue.increment(1),
    });

    await _analytics.logEvent(
      name: 'clip_shared',
      parameters: {
        'clip_id': clipId,
        'platform': platform,
        'share_type': shareType,
      },
    );
  }

  /// Get clip shares
  Future<List<ClipShare>> getClipShares(String clipId) async {
    final snap = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('shares')
        .orderBy('sharedAt', descending: true)
        .get();

    return snap.docs
        .map((doc) => ClipShare.fromJson(doc.data()))
        .toList();
  }

  /// Track share click
  Future<void> trackShareClick(String clipId, String shareId) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('shares')
        .doc(shareId)
        .update({
      'clickCount': FieldValue.increment(1),
    });
  }

  /// Generate tracking URL
  String _generateTrackingUrl(String clipId, String userId, String platform) {
    return 'https://toriverse.app/clip/$clipId?utm_source=$platform&utm_medium=share&utm_content=$userId';
  }

  // ============ METRICS ============

  /// Record view
  Future<void> recordView(String clipId, String viewerId) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .update({
      'totalViews': FieldValue.increment(1),
    });

    // Add to metrics
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('views')
        .doc('view_${DateTime.now().millisecondsSinceEpoch}')
        .set({
      'viewerId': viewerId,
      'viewedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Record like
  Future<void> recordLike(String clipId, String userId) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .update({
      'totalLikes': FieldValue.increment(1),
    });
  }

  /// Get clip metrics
  Future<ClipMetrics?> getClipMetrics(String clipId) async {
    final doc = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('metrics')
        .doc('current')
        .get();

    if (doc.exists) {
      return ClipMetrics.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Update clip metrics
  Future<void> updateClipMetrics(String clipId, ClipMetrics metrics) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('metrics')
        .doc('current')
        .set(metrics.toJson(), SetOptions(merge: true));
  }

  // ============ RECOMMENDATIONS ============

  /// Add recommendation
  Future<void> addRecommendation(ClipRecommendation recommendation) async {
    await _firestore
        .collection('users')
        .doc(recommendation.userId)
        .collection('clip_recommendations')
        .doc(recommendation.id)
        .set(recommendation.toJson());
  }

  /// Get recommendations for user
  Future<List<ClipRecommendation>> getRecommendations(
    String userId, {
    int limit = 20,
  }) async {
    final snap = await _firestore
        .collection('users')
        .doc(userId)
        .collection('clip_recommendations')
        .orderBy('recommendedAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => ClipRecommendation.fromJson(doc.data()))
        .toList();
  }

  /// Mark recommendation as clicked
  Future<void> markRecommendationClicked(
    String userId,
    String recommendationId,
  ) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('clip_recommendations')
        .doc(recommendationId)
        .update({
      'isClicked': true,
      'clickedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============ TRENDING ============

  /// Get trending clips
  Future<List<TrendingClip>> getTrendingClips({int limit = 20}) async {
    final snap = await _firestore
        .collection('trending_clips')
        .orderBy('rank', descending: false)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => TrendingClip.fromJson(doc.data()))
        .toList();
  }

  /// Watch trending clips
  Stream<List<TrendingClip>> watchTrendingClips({int limit = 20}) {
    return _firestore
        .collection('trending_clips')
        .orderBy('rank', descending: false)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TrendingClip.fromJson(doc.data()))
            .toList());
  }

  /// Update trending status
  Future<void> updateTrendingStatus(String clipId, TrendingClip trending) async {
    await _firestore
        .collection('trending_clips')
        .doc(clipId)
        .set(trending.toJson(), SetOptions(merge: true));
  }

  // ============ CREATOR PROFILES ============

  /// Get creator profile
  Future<ClipCreatorProfile?> getCreatorProfile(String userId) async {
    final doc = await _firestore
        .collection('clip_creators')
        .doc(userId)
        .get();

    if (doc.exists) {
      return ClipCreatorProfile.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Update creator profile
  Future<void> updateCreatorProfile(
    String userId,
    ClipCreatorProfile profile,
  ) async {
    await _firestore
        .collection('clip_creators')
        .doc(userId)
        .set(profile.toJson(), SetOptions(merge: true));
  }

  /// Watch creator profile
  Stream<ClipCreatorProfile?> watchCreatorProfile(String userId) {
    return _firestore
        .collection('clip_creators')
        .doc(userId)
        .snapshots()
        .map((snap) {
      if (snap.exists) {
        return ClipCreatorProfile.fromJson(snap.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // ============ VIRAL TRACKING ============

  /// Get viral tracking data
  Future<ViralTrackingData?> getViralTrackingData(String clipId) async {
    final doc = await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('viral_tracking')
        .doc('current')
        .get();

    if (doc.exists) {
      return ViralTrackingData.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  /// Update viral tracking data
  Future<void> updateViralTrackingData(
    String clipId,
    ViralTrackingData data,
  ) async {
    await _firestore
        .collection('clips')
        .doc(clipId)
        .collection('viral_tracking')
        .doc('current')
        .set(data.toJson(), SetOptions(merge: true));
  }

  /// Calculate viral coefficient
  double calculateViralCoefficient(int shares, int views) {
    if (views == 0) return 0.0;
    return shares / views;
  }
}
