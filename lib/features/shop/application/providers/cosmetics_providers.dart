import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'package:toriverse/shared/services/revenucat_service.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import '../services/cosmetics_shop_service.dart';

/// Provider for RevenueCat service
final revenuecatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

/// Provider for CosmeticsShopService
final cosmeticsShopServiceProvider =
    Provider((ref) {
  final revenuecatService = ref.watch(revenuecatServiceProvider);
  return CosmeticsShopService(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
    revenuecatService: revenuecatService,
  );
});

/// Provider for available cosmetics list
final availableCosmeticsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  final service = ref.watch(cosmeticsShopServiceProvider);
  return service.fetchAvailableCosmetics();
});

/// Provider for cosmetics filtered by type
final cosmeticsByTypeProvider = FutureProvider.family<List<CosmeticItem>, CosmeticType>(
  (ref, type) async {
    final service = ref.watch(cosmeticsShopServiceProvider);
    return service.fetchCosmeticsByType(type);
  },
);

/// Provider for streaming available cosmetics (real-time updates)
final availableCosmeticsStreamProvider =
    StreamProvider<List<CosmeticItem>>((ref) {
  final service = ref.watch(cosmeticsShopServiceProvider);
  return service.streamAvailableCosmetics();
});

/// Provider for user ID (from auth state)
final userIdProvider = Provider<String>((ref) {
  final uid = ref.watch(userUidProvider);
  return uid ?? 'user_default'; // Fallback for unauthenticated users
});

/// Provider for user's owned cosmetics
final userCosmeticsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  final service = ref.watch(cosmeticsShopServiceProvider);
  final userId = ref.watch(userIdProvider);
  return service.getUserCosmetics(userId);
});

/// Provider for user's cosmetics preferences
final userCosmeticsPreferenceProvider =
    FutureProvider<UserCosmeticsPreference>((ref) async {
  final service = ref.watch(cosmeticsShopServiceProvider);
  final userId = ref.watch(userIdProvider);
  return service.getUserPreferences(userId);
});

/// Provider for featured cosmetics (shop showcase)
final featuredCosmeticsProvider =
    FutureProvider<List<CosmeticItem>>((ref) async {
  final service = ref.watch(cosmeticsShopServiceProvider);
  return service.getFeaturedCosmetics(limit: 3);
});

/// State notifier for cosmetics shop operations
class CosmeticsShopNotifier extends StateNotifier<AsyncValue<void>> {
  final CosmeticsShopService _service;
  final String _userId;

  CosmeticsShopNotifier({
    required CosmeticsShopService service,
    required String userId,
  })  : _service = service,
        _userId = userId,
        super(const AsyncValue.data(null));

  /// Purchase a cosmetic
  Future<bool> purchaseCosmetic(CosmeticItem cosmetic) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.purchaseCosmetic(_userId, cosmetic);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Set active cosmetic for a type
  Future<bool> setActiveCosmectic(
    String cosmeticId,
    CosmeticType type,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.setActiveCosmectic(
        _userId,
        cosmeticId,
        type,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Reset cosmetics to defaults
  Future<bool> resetToDefaults() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.resetCosmeticsToDefaults(_userId);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for cosmetics shop operations
final cosmeticsShopNotifierProvider =
    StateNotifierProvider<CosmeticsShopNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(cosmeticsShopServiceProvider);
  final userId = ref.watch(userIdProvider);
  return CosmeticsShopNotifier(
    service: service,
    userId: userId,
  );
});

/// Helper provider to check if user owns a cosmetic
final userOwnsCosmeticProvider =
    FutureProvider.family<bool, String>((ref, cosmeticId) async {
  final service = ref.watch(cosmeticsShopServiceProvider);
  final userId = ref.watch(userIdProvider);
  return service.userOwnsCosmectic(userId, cosmeticId);
});

/// Helper provider to get cosmetics by rarity
final cosmeticsByRarityProvider =
    Provider.family<List<CosmeticItem>, CosmeticRarity>((ref, rarity) {
  final cosmetics = ref.watch(availableCosmeticsProvider);

  return cosmetics.when(
    data: (items) => items.where((item) => item.rarity == rarity).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider for limited edition cosmetics
final limitedEditionCosmeticsProvider =
    Provider<List<CosmeticItem>>((ref) {
  return ref.watch(cosmeticsByRarityProvider(CosmeticRarity.limited));
});
