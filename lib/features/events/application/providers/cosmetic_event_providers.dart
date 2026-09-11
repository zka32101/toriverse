import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cosmetic_model.dart';
import '../../domain/services/cosmetic_event_service.dart';
import 'event_providers.dart';

// Cosmetic Event Service
final cosmeticEventServiceProvider = Provider<CosmeticEventService>((ref) {
  final firestore = ref.watch(firebaseProvider);
  return CosmeticEventService(firestore);
});

// Get all limited cosmetics for an event
final limitedCosmeticsProvider =
    FutureProvider.family<List<LimitedCosmetic>, String>((ref, eventId) {
  final service = ref.watch(cosmeticEventServiceProvider);
  return service.getLimitedCosmetics(eventId);
});

// Get limited cosmetics as a stream
final limitedCosmeticsStreamProvider =
    StreamProvider.family<List<LimitedCosmetic>, String>((ref, eventId) {
  final service = ref.watch(cosmeticEventServiceProvider);
  return service.watchLimitedCosmetics(eventId);
});

// Get single cosmetic details
final cosmeticDetailsProvider = FutureProvider.family<LimitedCosmetic?, String>(
  (ref, params) {
    final service = ref.watch(cosmeticEventServiceProvider);
    final parts = params.split('|');
    final eventId = parts[0];
    final cosmeticId = parts[1];

    return service.getCosmeticDetails(
      eventId: eventId,
      cosmeticId: cosmeticId,
    );
  },
);

// Check if user has unlocked a cosmetic
final hasUnlockedCosmeticProvider = FutureProvider.family<bool, String>(
  (ref, params) {
    final service = ref.watch(cosmeticEventServiceProvider);
    final parts = params.split('|');
    final cosmeticId = parts[0];
    // params[1] is userId from ref.watch(userIdProvider)

    return service.hasUnlockedCosmetic(
      uid: ref.watch(userIdProvider),
      cosmeticId: cosmeticId,
    );
  },
);

// Get user's unlocked cosmetics for an event
final unlockedCosmeticsProvider =
    FutureProvider.family<List<UserEventCosmetic>, String>((ref, eventId) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value([]);
  }

  return service.getUnlockedCosmetics(
    uid: userId,
    eventId: eventId,
  );
});

// Watch user's unlocked cosmetics stream
final unlockedCosmeticsStreamProvider =
    StreamProvider.family<List<UserEventCosmetic>, String>((ref, eventId) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Stream.value([]);
  }

  return service.watchUnlockedCosmetics(
    uid: userId,
    eventId: eventId,
  );
});

// Get currently equipped cosmetic for user
final equippedCosmeticProvider =
    FutureProvider<UserEventCosmetic?>((ref) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(null);
  }

  return service.getEquippedCosmetic(userId);
});

// Check if cosmetic is event exclusive
final isEventExclusiveProvider = FutureProvider.family<bool, String>(
  (ref, params) {
    final service = ref.watch(cosmeticEventServiceProvider);
    final parts = params.split('|');
    final eventId = parts[0];
    final cosmeticId = parts[1];

    return service.isEventExclusive(
      eventId: eventId,
      cosmeticId: cosmeticId,
    );
  },
);

// Get cosmetics by rarity
final cosmeticsByRarityProvider =
    FutureProvider.family<List<LimitedCosmetic>, String>((ref, params) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final rarity = parts[1];

  return service.getCosmeticsByRarity(
    eventId: eventId,
    rarity: rarity,
  );
});

// Get cosmetics by type
final cosmeticsByTypeProvider =
    FutureProvider.family<List<LimitedCosmetic>, String>((ref, params) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final parts = params.split('|');
  final eventId = parts[0];
  final type = parts[1];

  return service.getCosmeticsByType(
    eventId: eventId,
    type: type,
  );
});

// Count unlocked cosmetics for user in event
final unlockedCosmeticCountProvider =
    FutureProvider.family<int, String>((ref, eventId) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final userId = ref.watch(userIdProvider);

  if (userId.isEmpty) {
    return Future.value(0);
  }

  return service.getUnlockedCosmeticCount(
    uid: userId,
    eventId: eventId,
  );
});

// Cosmetic mutation provider
final cosmeticEventNotifierProvider =
    StateNotifierProvider<CosmeticEventNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(cosmeticEventServiceProvider);
  final userId = ref.watch(userIdProvider);
  return CosmeticEventNotifier(service, userId, ref);
});

class CosmeticEventNotifier extends StateNotifier<AsyncValue<void>> {
  final CosmeticEventService _service;
  final String _userId;
  final Ref _ref;

  CosmeticEventNotifier(this._service, this._userId, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> unlockCosmetic({
    required String uid,
    required String cosmeticId,
    required String eventId,
    String method = 'challenge',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.unlockCosmetic(
        uid: uid,
        cosmeticId: cosmeticId,
        eventId: eventId,
        method: method,
      );

      // Invalidate related caches
      _ref.invalidate(hasUnlockedCosmeticProvider('$cosmeticId|$uid'));
      _ref.invalidate(unlockedCosmeticsProvider(eventId));
      _ref.invalidate(unlockedCosmeticsStreamProvider(eventId));
      _ref.invalidate(unlockedCosmeticCountProvider(eventId));
    });
  }

  Future<void> equipCosmetic(String cosmeticId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.equipCosmetic(
        uid: _userId,
        cosmeticId: cosmeticId,
      );

      // Invalidate related caches
      _ref.invalidate(equippedCosmeticProvider);
    });
  }

  Future<void> unequipCosmetic(String cosmeticId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.unequipCosmetic(
        uid: _userId,
        cosmeticId: cosmeticId,
      );

      // Invalidate related caches
      _ref.invalidate(equippedCosmeticProvider);
    });
  }
}
