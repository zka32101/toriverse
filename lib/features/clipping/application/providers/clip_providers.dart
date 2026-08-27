import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/clipping/data/repositories/clip_repository.dart';
import 'package:toriverse/features/clipping/domain/models/clip.dart';

// ============ REPOSITORY PROVIDER ============

final clipRepositoryProvider = Provider<ClipRepository>((ref) {
  return ClipRepository();
});

// ============ PARAMETER CLASSES ============

class ClipIdParam {
  final String clipId;

  ClipIdParam(this.clipId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipIdParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId;

  @override
  int get hashCode => clipId.hashCode;
}

class MatchIdParam {
  final String matchId;

  MatchIdParam(this.matchId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchIdParam &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId;

  @override
  int get hashCode => matchId.hashCode;
}

class CreatorIdParam {
  final String creatorId;

  CreatorIdParam(this.creatorId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatorIdParam &&
          runtimeType == other.runtimeType &&
          creatorId == other.creatorId;

  @override
  int get hashCode => creatorId.hashCode;
}

class UserIdParam {
  final String userId;

  UserIdParam(this.userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdParam &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

class GenerationJobParam {
  final String clipId;
  final String jobId;

  GenerationJobParam({required this.clipId, required this.jobId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerationJobParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          jobId == other.jobId;

  @override
  int get hashCode => Object.hash(clipId, jobId);
}

class UploadStatusParam {
  final String clipId;
  final String uploadStatusId;

  UploadStatusParam({required this.clipId, required this.uploadStatusId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadStatusParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          uploadStatusId == other.uploadStatusId;

  @override
  int get hashCode => Object.hash(clipId, uploadStatusId);
}

class AspectRatioParam {
  final String clipId;
  final String aspectRatio;

  AspectRatioParam({required this.clipId, required this.aspectRatio});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AspectRatioParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          aspectRatio == other.aspectRatio;

  @override
  int get hashCode => Object.hash(clipId, aspectRatio);
}

class PlatformParam {
  final String clipId;
  final String platform;

  PlatformParam({required this.clipId, required this.platform});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          platform == other.platform;

  @override
  int get hashCode => Object.hash(clipId, platform);
}

// ============ STREAM PROVIDERS (Real-time) ============

/// Watch a single clip in real-time
final watchClipProvider = StreamProvider.family<MatchClip?, ClipIdParam>(
  (ref, param) {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.watchClip(param.clipId);
  },
).autoDispose;

/// Watch trending clips in real-time
final watchTrendingClipsProvider =
    StreamProvider<List<TrendingClip>>((ref) {
  final repo = ref.watch(clipRepositoryProvider);
  return repo.watchTrendingClips(limit: 20);
}).autoDispose;

/// Watch creator profile in real-time
final watchCreatorProfileProvider =
    StreamProvider.family<ClipCreatorProfile?, UserIdParam>(
  (ref, param) {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.watchCreatorProfile(param.userId);
  },
).autoDispose;

/// Watch clip generation job progress
final watchGenerationJobProvider =
    StreamProvider.family<ClipGenerationJob?, GenerationJobParam>(
  (ref, param) {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.watchGenerationJob(param.clipId, param.jobId);
  },
).autoDispose;

/// Watch clip upload status
final watchUploadStatusProvider =
    StreamProvider.family<ClipUploadStatus?, UploadStatusParam>(
  (ref, param) {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.watchUploadStatus(param.clipId, param.uploadStatusId);
  },
).autoDispose;

// ============ FUTURE PROVIDERS (Async Operations) ============

/// Get single clip
final getClipProvider = FutureProvider.family<MatchClip?, ClipIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClip(param.clipId);
  },
).autoDispose;

/// Get clips by match
final clipsByMatchProvider = FutureProvider.family<List<MatchClip>, MatchIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClipsByMatch(param.matchId);
  },
).autoDispose;

/// Get creator's clips
final creatorClipsProvider = FutureProvider.family<List<MatchClip>, CreatorIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getCreatorClips(param.creatorId);
  },
).autoDispose;

/// Get all formats for a clip
final clipFormatsProvider = FutureProvider.family<List<ClipFormat>, ClipIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClipFormats(param.clipId);
  },
).autoDispose;

/// Get specific format by aspect ratio
final clipFormatByAspectRatioProvider =
    FutureProvider.family<ClipFormat?, AspectRatioParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClipFormatByAspectRatio(param.clipId, param.aspectRatio);
  },
).autoDispose;

/// Get all shares for a clip
final clipSharesProvider = FutureProvider.family<List<ClipShare>, ClipIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClipShares(param.clipId);
  },
).autoDispose;

/// Get recommendations for user
final recommendationsProvider = FutureProvider.family<List<ClipRecommendation>, UserIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getRecommendations(param.userId, limit: 20);
  },
).autoDispose;

/// Get clip metrics
final clipMetricsProvider = FutureProvider.family<ClipMetrics?, ClipIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getClipMetrics(param.clipId);
  },
).autoDispose;

/// Get creator profile
final creatorProfileProvider =
    FutureProvider.family<ClipCreatorProfile?, UserIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getCreatorProfile(param.userId);
  },
).autoDispose;

/// Get viral tracking data
final viralTrackingDataProvider = FutureProvider.family<ViralTrackingData?, ClipIdParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getViralTrackingData(param.clipId);
  },
).autoDispose;

/// Get upload status for platform
final uploadStatusForPlatformProvider =
    FutureProvider.family<ClipUploadStatus?, PlatformParam>(
  (ref, param) async {
    final repo = ref.watch(clipRepositoryProvider);
    return repo.getUploadStatusForPlatform(param.clipId, param.platform);
  },
).autoDispose;

// ============ MUTATION PROVIDERS (State Changes) ============

/// Create new clip from highlight moment
final createClipProvider =
    FutureProvider.family<MatchClip, CreateClipParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  final clip = await repo.createClip(
    matchId: param.matchId,
    highlightId: param.highlightId,
    creatorId: param.creatorId,
    title: param.title,
    description: param.description,
    momentType: param.momentType,
    startTimestamp: param.startTimestamp,
    endTimestamp: param.endTimestamp,
  );

  // Invalidate related providers
  ref.invalidate(
    creatorClipsProvider(CreatorIdParam(param.creatorId)),
  );
  ref.invalidate(
    clipsByMatchProvider(MatchIdParam(param.matchId)),
  );

  return clip;
});

class CreateClipParam {
  final String matchId;
  final String highlightId;
  final String creatorId;
  final String title;
  final String description;
  final String momentType;
  final int startTimestamp;
  final int endTimestamp;

  CreateClipParam({
    required this.matchId,
    required this.highlightId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.momentType,
    required this.startTimestamp,
    required this.endTimestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateClipParam &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          highlightId == other.highlightId &&
          creatorId == other.creatorId &&
          title == other.title &&
          description == other.description &&
          momentType == other.momentType &&
          startTimestamp == other.startTimestamp &&
          endTimestamp == other.endTimestamp;

  @override
  int get hashCode => Object.hashAll([
    matchId,
    highlightId,
    creatorId,
    title,
    description,
    momentType,
    startTimestamp,
    endTimestamp,
  ]);
}

/// Submit clip for generation
final submitForGenerationProvider = FutureProvider.family<ClipGenerationJob, SubmitForGenerationParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  final job = await repo.submitForGeneration(param.clipId, param.config);

  // Invalidate generation job provider
  ref.invalidate(
    watchGenerationJobProvider(
      GenerationJobParam(clipId: param.clipId, jobId: job.id),
    ),
  );

  // Invalidate clip provider
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));

  return job;
});

class SubmitForGenerationParam {
  final String clipId;
  final ClipGenerationConfig config;

  SubmitForGenerationParam({required this.clipId, required this.config});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitForGenerationParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          config == other.config;

  @override
  int get hashCode => Object.hash(clipId, config);
}

/// Add clip format
final addClipFormatProvider = FutureProvider.family<void, AddClipFormatParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.addClipFormat(param.clipId, param.format);

  // Invalidate formats provider
  ref.invalidate(clipFormatsProvider(ClipIdParam(param.clipId)));
  ref.invalidate(
    clipFormatByAspectRatioProvider(
      AspectRatioParam(clipId: param.clipId, aspectRatio: param.format.aspectRatio),
    ),
  );
});

class AddClipFormatParam {
  final String clipId;
  final ClipFormat format;

  AddClipFormatParam({required this.clipId, required this.format});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddClipFormatParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          format == other.format;

  @override
  int get hashCode => Object.hash(clipId, format);
}

/// Share clip
final shareClipProvider = FutureProvider.family<void, ShareClipParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.shareClip(param.clipId, param.userId, param.platform, param.shareType);

  // Invalidate related providers
  ref.invalidate(clipSharesProvider(ClipIdParam(param.clipId)));
  ref.invalidate(clipMetricsProvider(ClipIdParam(param.clipId)));
  ref.invalidate(viralTrackingDataProvider(ClipIdParam(param.clipId)));
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class ShareClipParam {
  final String clipId;
  final String userId;
  final String platform;
  final String shareType;

  ShareClipParam({
    required this.clipId,
    required this.userId,
    required this.platform,
    required this.shareType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShareClipParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          userId == other.userId &&
          platform == other.platform &&
          shareType == other.shareType;

  @override
  int get hashCode => Object.hash(clipId, userId, platform, shareType);
}

/// Record view
final recordViewProvider = FutureProvider.family<void, RecordViewParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.recordView(param.clipId, param.viewerId);

  // Invalidate metrics provider
  ref.invalidate(clipMetricsProvider(ClipIdParam(param.clipId)));
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class RecordViewParam {
  final String clipId;
  final String viewerId;

  RecordViewParam({required this.clipId, required this.viewerId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordViewParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          viewerId == other.viewerId;

  @override
  int get hashCode => Object.hash(clipId, viewerId);
}

/// Record like
final recordLikeProvider = FutureProvider.family<void, RecordLikeParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.recordLike(param.clipId, param.userId);

  // Invalidate metrics provider
  ref.invalidate(clipMetricsProvider(ClipIdParam(param.clipId)));
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class RecordLikeParam {
  final String clipId;
  final String userId;

  RecordLikeParam({required this.clipId, required this.userId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordLikeParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(clipId, userId);
}

/// Complete generation job
final completeGenerationJobProvider = FutureProvider.family<void, CompleteGenerationJobParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.completeGenerationJob(param.clipId, param.jobId);

  // Invalidate generation and clip providers
  ref.invalidate(
    watchGenerationJobProvider(
      GenerationJobParam(clipId: param.clipId, jobId: param.jobId),
    ),
  );
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class CompleteGenerationJobParam {
  final String clipId;
  final String jobId;

  CompleteGenerationJobParam({required this.clipId, required this.jobId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompleteGenerationJobParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          jobId == other.jobId;

  @override
  int get hashCode => Object.hash(clipId, jobId);
}

/// Update clip
final updateClipProvider = FutureProvider.family<void, UpdateClipParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateClip(param.clipId, param.updates);

  // Invalidate clip provider
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class UpdateClipParam {
  final String clipId;
  final Map<String, dynamic> updates;

  UpdateClipParam({required this.clipId, required this.updates});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateClipParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          updates == other.updates;

  @override
  int get hashCode => Object.hash(clipId, updates);
}

/// Delete clip
final deleteClipProvider = FutureProvider.family<void, ClipIdParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.deleteClip(param.clipId);

  // Invalidate related providers
  ref.invalidate(watchClipProvider(param));
  ref.invalidate(getClipProvider(param));
  ref.invalidate(clipFormatsProvider(param));
  ref.invalidate(clipSharesProvider(param));
  ref.invalidate(clipMetricsProvider(param));
  ref.invalidate(viralTrackingDataProvider(param));
});

/// Add recommendation
final addRecommendationProvider = FutureProvider.family<void, AddRecommendationParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.addRecommendation(param.recommendation);

  // Invalidate recommendations provider
  ref.invalidate(
    recommendationsProvider(UserIdParam(param.recommendation.userId)),
  );
});

class AddRecommendationParam {
  final ClipRecommendation recommendation;

  AddRecommendationParam({required this.recommendation});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddRecommendationParam &&
          runtimeType == other.runtimeType &&
          recommendation == other.recommendation;

  @override
  int get hashCode => recommendation.hashCode;
}

/// Mark recommendation as clicked
final markRecommendationClickedProvider = FutureProvider.family<void, MarkRecommendationClickedParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.markRecommendationClicked(param.userId, param.recommendationId);

  // Invalidate recommendations provider
  ref.invalidate(recommendationsProvider(UserIdParam(param.userId)));
});

class MarkRecommendationClickedParam {
  final String userId;
  final String recommendationId;

  MarkRecommendationClickedParam({
    required this.userId,
    required this.recommendationId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkRecommendationClickedParam &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          recommendationId == other.recommendationId;

  @override
  int get hashCode => Object.hash(userId, recommendationId);
}

/// Update trending status
final updateTrendingStatusProvider = FutureProvider.family<void, UpdateTrendingStatusParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateTrendingStatus(param.clipId, param.trending);

  // Invalidate trending provider
  ref.invalidate(watchTrendingClipsProvider);
});

class UpdateTrendingStatusParam {
  final String clipId;
  final TrendingClip trending;

  UpdateTrendingStatusParam({required this.clipId, required this.trending});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateTrendingStatusParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          trending == other.trending;

  @override
  int get hashCode => Object.hash(clipId, trending);
}

/// Record upload status
final recordUploadStatusProvider = FutureProvider.family<void, RecordUploadStatusParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.recordUploadStatus(param.clipId, param.status);

  // Invalidate upload status provider
  ref.invalidate(
    watchUploadStatusProvider(
      UploadStatusParam(
        clipId: param.clipId,
        uploadStatusId: param.status.id,
      ),
    ),
  );
  ref.invalidate(
    uploadStatusForPlatformProvider(
      PlatformParam(clipId: param.clipId, platform: param.status.platform),
    ),
  );
  ref.invalidate(watchClipProvider(ClipIdParam(param.clipId)));
  ref.invalidate(getClipProvider(ClipIdParam(param.clipId)));
});

class RecordUploadStatusParam {
  final String clipId;
  final ClipUploadStatus status;

  RecordUploadStatusParam({required this.clipId, required this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordUploadStatusParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(clipId, status);
}

/// Track share click
final trackShareClickProvider = FutureProvider.family<void, TrackShareClickParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.trackShareClick(param.clipId, param.shareId);

  // Invalidate shares provider
  ref.invalidate(clipSharesProvider(ClipIdParam(param.clipId)));
});

class TrackShareClickParam {
  final String clipId;
  final String shareId;

  TrackShareClickParam({required this.clipId, required this.shareId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackShareClickParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          shareId == other.shareId;

  @override
  int get hashCode => Object.hash(clipId, shareId);
}

/// Update clip format
final updateClipFormatProvider = FutureProvider.family<void, UpdateClipFormatParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateClipFormat(param.clipId, param.formatId, param.updates);

  // Invalidate formats provider
  ref.invalidate(clipFormatsProvider(ClipIdParam(param.clipId)));
});

class UpdateClipFormatParam {
  final String clipId;
  final String formatId;
  final Map<String, dynamic> updates;

  UpdateClipFormatParam({
    required this.clipId,
    required this.formatId,
    required this.updates,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateClipFormatParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          formatId == other.formatId &&
          updates == other.updates;

  @override
  int get hashCode => Object.hash(clipId, formatId, updates);
}

/// Update clip metrics
final updateClipMetricsProvider = FutureProvider.family<void, UpdateClipMetricsParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateClipMetrics(param.clipId, param.metrics);

  // Invalidate metrics provider
  ref.invalidate(clipMetricsProvider(ClipIdParam(param.clipId)));
});

class UpdateClipMetricsParam {
  final String clipId;
  final ClipMetrics metrics;

  UpdateClipMetricsParam({required this.clipId, required this.metrics});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateClipMetricsParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          metrics == other.metrics;

  @override
  int get hashCode => Object.hash(clipId, metrics);
}

/// Update creator profile
final updateCreatorProfileProvider = FutureProvider.family<void, UpdateCreatorProfileParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateCreatorProfile(param.userId, param.profile);

  // Invalidate creator profile provider
  ref.invalidate(
    watchCreatorProfileProvider(UserIdParam(param.userId)),
  );
  ref.invalidate(creatorProfileProvider(UserIdParam(param.userId)));
});

class UpdateCreatorProfileParam {
  final String userId;
  final ClipCreatorProfile profile;

  UpdateCreatorProfileParam({required this.userId, required this.profile});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateCreatorProfileParam &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          profile == other.profile;

  @override
  int get hashCode => Object.hash(userId, profile);
}

/// Update viral tracking data
final updateViralTrackingDataProvider = FutureProvider.family<void, UpdateViralTrackingDataParam>((ref, param) async {
  final repo = ref.watch(clipRepositoryProvider);
  await repo.updateViralTrackingData(param.clipId, param.data);

  // Invalidate viral tracking provider
  ref.invalidate(viralTrackingDataProvider(ClipIdParam(param.clipId)));
});

class UpdateViralTrackingDataParam {
  final String clipId;
  final ViralTrackingData data;

  UpdateViralTrackingDataParam({required this.clipId, required this.data});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateViralTrackingDataParam &&
          runtimeType == other.runtimeType &&
          clipId == other.clipId &&
          data == other.data;

  @override
  int get hashCode => Object.hash(clipId, data);
}
