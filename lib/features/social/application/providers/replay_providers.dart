import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/replay_model.dart';
import '../../domain/services/replay_service.dart';
import 'friend_providers.dart';

// Service provider
final replayServiceProvider = Provider<ReplayService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return ReplayService(firestore);
});

// User's replays stream
final myReplaysProvider = StreamProvider<List<Replay>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(replayServiceProvider);
  return service.getUserReplaysStream(uid);
});

// Public replays discovery stream
final publicReplaysProvider = StreamProvider<List<Replay>>((ref) {
  final service = ref.watch(replayServiceProvider);
  return service.getPublicReplaysStream(limit: 50);
});

// Trending replays
final trendingReplaysProvider = FutureProvider<List<Replay>>((ref) async {
  final service = ref.watch(replayServiceProvider);
  return service.getTrendingReplays(limit: 20);
});

// Replay details by ID
final replayDetailsProvider =
    FutureProvider.family<Replay?, String>((ref, replayId) async {
  final service = ref.watch(replayServiceProvider);
  return service.getReplayDetails(replayId);
});

// Watch replay details stream
final watchReplayProvider = StreamProvider.family<Replay?, String>(
  (ref, replayId) {
    final service = ref.watch(replayServiceProvider);
    return service.watchReplayDetails(replayId);
  },
);

// Search replays by tag
final searchReplaysByTagProvider =
    FutureProvider.family<List<Replay>, String>((ref, tag) async {
  final service = ref.watch(replayServiceProvider);
  return service.searchByTag(tag);
});

// Check if replay is favorited
final isFavoritedProvider =
    FutureProvider.family<bool, String>((ref, replayId) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return false;
  }

  final service = ref.watch(replayServiceProvider);
  return service.isFavorited(replayId: replayId, userUid: uid);
});

// Replay notifier
class ReplayNotifier extends StateNotifier<AsyncValue<void>> {
  final ReplayService _service;
  final Ref _ref;

  ReplayNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<String> saveReplayMetadata({
    required String matchId,
    required String creatorUid,
    required String videoUrl,
    String? title,
    String? description,
    String? thumbnail,
    int? duration,
    bool isPublic = true,
  }) async {
    state = const AsyncValue.loading();
    late String replayId;

    state = await AsyncValue.guard(() async {
      replayId = await _service.saveReplayMetadata(
        matchId: matchId,
        creatorUid: creatorUid,
        videoUrl: videoUrl,
        title: title,
        description: description,
        thumbnail: thumbnail,
        duration: duration,
        isPublic: isPublic,
      );
      _ref.invalidate(myReplaysProvider);
      _ref.invalidate(publicReplaysProvider);
    });

    return replayId;
  }

  Future<void> toggleReplayVisibility({
    required String replayId,
    required String ownerUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.toggleReplayVisibility(
        replayId: replayId,
        ownerUid: ownerUid,
      );
      _ref.invalidate(watchReplayProvider(replayId));
      _ref.invalidate(myReplaysProvider);
      _ref.invalidate(publicReplaysProvider);
    });
  }

  Future<void> recordReplayView({
    required String replayId,
    required String viewerUid,
    int? durationWatched,
  }) async {
    // Don't set loading state for view tracking - let it happen in background
    await AsyncValue.guard(() async {
      await _service.recordReplayView(
        replayId: replayId,
        viewerUid: viewerUid,
        durationWatched: durationWatched,
      );
      // Invalidate replay details to show updated view count
      _ref.invalidate(watchReplayProvider(replayId));
      _ref.invalidate(publicReplaysProvider);
    });
  }

  Future<void> toggleFavoriteReplay({
    required String replayId,
    required String userUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.toggleFavoriteReplay(
        replayId: replayId,
        userUid: userUid,
      );
      _ref.invalidate(isFavoritedProvider(replayId));
      _ref.invalidate(watchReplayProvider(replayId));
    });
  }

  Future<void> incrementShareCount(String replayId) async {
    // Fire and forget - don't wait for this
    await AsyncValue.guard(() async {
      await _service.incrementShareCount(replayId);
      _ref.invalidate(watchReplayProvider(replayId));
    });
  }

  Future<void> addTagsToReplay({
    required String replayId,
    required List<String> tags,
    required String ownerUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.addTagsToReplay(
        replayId: replayId,
        tags: tags,
        ownerUid: ownerUid,
      );
      _ref.invalidate(watchReplayProvider(replayId));
      _ref.invalidate(myReplaysProvider);
    });
  }

  Future<void> deleteReplay({
    required String replayId,
    required String ownerUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteReplay(replayId: replayId, ownerUid: ownerUid);
      _ref.invalidate(myReplaysProvider);
      _ref.invalidate(publicReplaysProvider);
    });
  }
}

final replayNotifierProvider =
    StateNotifierProvider<ReplayNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(replayServiceProvider);
  return ReplayNotifier(service, ref);
});
