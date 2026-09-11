import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/friend_model.dart';
import '../../domain/services/friend_service.dart';

// Service provider
final friendServiceProvider = Provider<FriendService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return FriendService(firestore);
});

// Current user UID provider (assuming this is injected elsewhere)
final currentUserUidProvider = StateProvider<String?>((ref) => null);

// Friends list stream
final friendsListProvider = StreamProvider<List<Friend>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(friendServiceProvider);
  return service.getFriendsListStream(uid);
});

// Pending friend requests stream
final pendingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(friendServiceProvider);
  return service.getPendingRequestsStream(uid);
});

// Friend count provider
final friendCountProvider = FutureProvider<int>((ref) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return 0;
  }

  final service = ref.watch(friendServiceProvider);
  return service.getFriendCount(uid);
});

// Check if specific user is friend (family provider)
final isFriendProvider =
    FutureProvider.family<bool, String>((ref, potentialFriendUid) async {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return false;
  }

  final service = ref.watch(friendServiceProvider);
  return service.isFriend(uid: uid, potentialFriendUid: potentialFriendUid);
});

// Friend notifier for state management
class FriendNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendService _service;
  final Ref _ref;

  FriendNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<void> sendFriendRequest({
    required String fromUid,
    required String toUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.sendFriendRequest(fromUid: fromUid, toUid: toUid);
      // Invalidate cached data
      _ref.invalidate(pendingRequestsProvider);
      _ref.invalidate(isFriendProvider(toUid));
    });
  }

  Future<void> acceptFriendRequest({
    required String requestId,
    required String acceptingUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.acceptFriendRequest(
        requestId: requestId,
        acceptingUid: acceptingUid,
      );
      // Invalidate cached data
      _ref.invalidate(friendsListProvider);
      _ref.invalidate(pendingRequestsProvider);
      _ref.invalidate(friendCountProvider);
    });
  }

  Future<void> declineFriendRequest({
    required String requestId,
    required String decliningUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.declineFriendRequest(
        requestId: requestId,
        decliningUid: decliningUid,
      );
      // Invalidate cached data
      _ref.invalidate(pendingRequestsProvider);
    });
  }

  Future<void> removeFriend({
    required String uid,
    required String friendUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.removeFriend(uid: uid, friendUid: friendUid);
      // Invalidate cached data
      _ref.invalidate(friendsListProvider);
      _ref.invalidate(friendCountProvider);
      _ref.invalidate(isFriendProvider(friendUid));
    });
  }

  Future<void> blockUser({
    required String uid,
    required String blockedUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.blockUser(uid: uid, blockedUid: blockedUid);
      // Invalidate cached data
      _ref.invalidate(friendsListProvider);
      _ref.invalidate(friendCountProvider);
    });
  }

  Future<void> toggleFavoriteFriend({
    required String uid,
    required String friendUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.toggleFavoriteFriend(uid: uid, friendUid: friendUid);
      // Invalidate friends list to reflect favorite change
      _ref.invalidate(friendsListProvider);
    });
  }

  Future<void> updateFriendNotes({
    required String uid,
    required String friendUid,
    required String notes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateFriendNotes(
        uid: uid,
        friendUid: friendUid,
        notes: notes,
      );
      _ref.invalidate(friendsListProvider);
    });
  }
}

final friendNotifierProvider =
    StateNotifierProvider<FriendNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(friendServiceProvider);
  return FriendNotifier(service, ref);
});
