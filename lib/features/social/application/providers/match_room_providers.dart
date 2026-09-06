import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../../data/models/match_room_model.dart';
import '../../domain/services/match_room_service.dart';
import 'friend_providers.dart';

// Service provider
final matchRoomServiceProvider = Provider<MatchRoomService>((ref) {
  final firestore = FirebaseFirestore.instance;
  return MatchRoomService(firestore);
});

// Active rooms for current user
final activeRoomsProvider = StreamProvider<List<MatchRoom>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(matchRoomServiceProvider);
  return service.getActiveRoomsStream(uid);
});

// Room details by room ID
final roomDetailsProvider =
    FutureProvider.family<MatchRoom?, String>((ref, roomId) async {
  final service = ref.watch(matchRoomServiceProvider);
  return service.getRoomStatus(roomId);
});

// Watch room details as a stream
final watchRoomProvider = StreamProvider.family<MatchRoom?, String>(
  (ref, roomId) {
    final service = ref.watch(matchRoomServiceProvider);
    return service.watchRoomStatus(roomId);
  },
);

// User's invitations
final myInvitationsProvider = StreamProvider<List<Invitation>>((ref) {
  final uid = ref.watch(currentUserUidProvider);
  if (uid == null) {
    return Stream.value([]);
  }

  final service = ref.watch(matchRoomServiceProvider);
  return service.getInvitationsStream(uid);
});

// Invitation count
final invitationCountProvider = StreamProvider<int>((ref) {
  final invitations = ref.watch(myInvitationsProvider);

  return invitations.when(
    data: (invites) => Stream.value(invites.length),
    loading: () => Stream.value(0),
    error: (_, __) => Stream.value(0),
  );
});

// Match room notifier
class MatchRoomNotifier extends StateNotifier<AsyncValue<void>> {
  final MatchRoomService _service;
  final Ref _ref;

  MatchRoomNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<String> createMatchRoom({
    required String creatorUid,
    bool isPrivate = true,
    int maxPlayers = 3,
  }) async {
    state = const AsyncValue.loading();
    late String roomId;

    state = await AsyncValue.guard(() async {
      roomId = await _service.createMatchRoom(
        creatorUid: creatorUid,
        isPrivate: isPrivate,
        maxPlayers: maxPlayers,
      );
      _ref.invalidate(activeRoomsProvider);
    });

    return roomId;
  }

  Future<String> inviteFriendToRoom({
    required String roomId,
    required String fromUid,
    required String toUid,
  }) async {
    state = const AsyncValue.loading();
    late String invitationId;

    state = await AsyncValue.guard(() async {
      invitationId = await _service.inviteFriendToRoom(
        roomId: roomId,
        fromUid: fromUid,
        toUid: toUid,
      );
      _ref.invalidate(watchRoomProvider(roomId));
    });

    return invitationId;
  }

  Future<void> acceptInvitation({
    required String invitationId,
    required String acceptingUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.acceptInvitation(
        invitationId: invitationId,
        acceptingUid: acceptingUid,
      );
      _ref.invalidate(myInvitationsProvider);
      _ref.invalidate(activeRoomsProvider);
    });
  }

  Future<void> declineInvitation({
    required String invitationId,
    required String decliningUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.declineInvitation(
        invitationId: invitationId,
        decliningUid: decliningUid,
      );
      _ref.invalidate(myInvitationsProvider);
    });
  }

  Future<void> startMatchFromRoom({
    required String roomId,
    required String matchId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.startMatchFromRoom(roomId: roomId, matchId: matchId);
      _ref.invalidate(watchRoomProvider(roomId));
      _ref.invalidate(activeRoomsProvider);
    });
  }

  Future<void> finishRoom(String roomId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.finishRoom(roomId);
      _ref.invalidate(watchRoomProvider(roomId));
      _ref.invalidate(activeRoomsProvider);
    });
  }

  Future<void> cancelRoom({
    required String roomId,
    required String creatorUid,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.cancelRoom(roomId: roomId, creatorUid: creatorUid);
      _ref.invalidate(activeRoomsProvider);
      _ref.invalidate(myInvitationsProvider);
    });
  }
}

final matchRoomNotifierProvider =
    StateNotifierProvider<MatchRoomNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(matchRoomServiceProvider);
  return MatchRoomNotifier(service, ref);
});
