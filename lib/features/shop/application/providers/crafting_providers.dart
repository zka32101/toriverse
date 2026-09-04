import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/shop/domain/services/cosmetics_crafting_service.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'cosmetics_providers.dart';

/// Provider for CosmeticsCraftingService
final cosmeticsCraftingServiceProvider = Provider<CosmeticsCraftingService>((ref) {
  return CosmeticsCraftingService();
});

/// Provider for user's current crafting progress
final userCraftingProgressProvider = StreamProvider<CraftingProgress?>((ref) {
  final userId = ref.watch(userIdProvider);
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('crafting')
      .doc('activeSlot')
      .snapshots()
      .map((snapshot) {
        if (!snapshot.exists) return null;
        final data = snapshot.data()!;
        return CraftingProgress(
          cosmeticId: data['cosmetic_id'] as String,
          startedAt: (data['started_at'] as Timestamp).toDate(),
          completesAt: (data['completes_at'] as Timestamp).toDate(),
          status: data['status'] as String,
        );
      });
});

/// Provider for user's inventory (owned cosmetics count)
final userInventoryProvider = FutureProvider<Map<String, int>>((ref) async {
  final userId = ref.watch(userIdProvider);
  final userCosmetics = await ref.watch(userCosmeticsProvider.future);

  // Count cosmetics by ID
  final inventory = <String, int>{};
  for (final cosmetic in userCosmetics) {
    inventory[cosmetic.id] = (inventory[cosmetic.id] ?? 0) + 1;
  }

  return inventory;
});

/// Provider for available crafting recipes (based on user inventory)
final availableCraftingRecipesProvider =
    FutureProvider<List<CraftingRecipe>>((ref) async {
  final craftingService = ref.watch(cosmeticsCraftingServiceProvider);
  final inventory = await ref.watch(userInventoryProvider.future);

  return craftingService.getAvailableRecipes(inventory);
});

/// Provider for all crafting recipes
final allCraftingRecipesProvider = Provider<List<CraftingRecipe>>((ref) {
  final craftingService = ref.watch(cosmeticsCraftingServiceProvider);
  return craftingService.getAllRecipes();
});

/// Provider to check if user can craft specific cosmetic
final canCraftCosmeticProvider = FutureProvider.family<bool, String>((ref, cosmeticId) async {
  final craftingService = ref.watch(cosmeticsCraftingServiceProvider);
  final inventory = await ref.watch(userInventoryProvider.future);

  return craftingService.canCraftCosmetic(cosmeticId, inventory);
});

/// State notifier for crafting operations
class CraftingNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final String _userId;
  final CosmeticsCraftingService _craftingService;

  CraftingNotifier({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
    required String userId,
    required CosmeticsCraftingService craftingService,
  })  : _firestore = firestore,
        _analytics = analytics,
        _userId = userId,
        _craftingService = craftingService,
        super(const AsyncValue.data(null));

  /// Start crafting a cosmetic
  Future<bool> startCrafting(String cosmeticId) async {
    state = const AsyncValue.loading();
    try {
      final recipe = _craftingService.getRecipe(cosmeticId);
      if (recipe == null) {
        throw Exception('Recipe not found for: $cosmeticId');
      }

      final completesAt = _craftingService.calculateCompletionTime(cosmeticId);
      final now = DateTime.now();

      // Write to Firestore
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crafting')
          .doc('activeSlot')
          .set({
        'cosmetic_id': cosmeticId,
        'started_at': Timestamp.fromDate(now),
        'completes_at': Timestamp.fromDate(completesAt),
        'status': 'crafting',
      });

      // Log analytics event
      await _analytics.logEvent(
        name: 'craft_started',
        parameters: {
          'cosmetic_id': cosmeticId,
          'recipe_id': cosmeticId,
          'crafting_time_minutes': recipe.craftingTimeMinutes,
        },
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Claim completed craft
  Future<bool> claimCraft() async {
    state = const AsyncValue.loading();
    try {
      final activeSlot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crafting')
          .doc('activeSlot')
          .get();

      if (!activeSlot.exists) {
        throw Exception('No active craft to claim');
      }

      final data = activeSlot.data()!;
      final cosmeticId = data['cosmetic_id'] as String;
      final completesAt = (data['completes_at'] as Timestamp).toDate();
      final now = DateTime.now();

      if (now.isBefore(completesAt)) {
        throw Exception('Craft not yet complete');
      }

      // Add to user inventory
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('inventory')
          .doc(cosmeticId)
          .set({
        'count': FieldValue.increment(1),
        'last_added': Timestamp.fromDate(now),
      }, SetOptions(merge: true));

      // Add to crafting history
      final historyId = _firestore.collection('dummy').doc().id;
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crafting')
          .collection('history')
          .doc(historyId)
          .set({
        'cosmetic_id': cosmeticId,
        'completed_at': Timestamp.fromDate(now),
        'recipe_id': cosmeticId,
      });

      // Clear active slot
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crafting')
          .doc('activeSlot')
          .delete();

      // Log analytics event
      await _analytics.logEvent(
        name: 'craft_claimed',
        parameters: {
          'cosmetic_id': cosmeticId,
          'claimed_at': now.toIso8601String(),
          'time_waited_seconds': now.difference(completesAt).inSeconds.abs(),
        },
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Cancel current craft (if any)
  Future<bool> cancelCraft() async {
    state = const AsyncValue.loading();
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('crafting')
          .doc('activeSlot')
          .delete();

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for crafting operations
final craftingNotifierProvider =
    StateNotifierProvider<CraftingNotifier, AsyncValue<void>>((ref) {
  return CraftingNotifier(
    firestore: FirebaseFirestore.instance,
    analytics: FirebaseAnalytics.instance,
    userId: ref.watch(userIdProvider),
    craftingService: ref.watch(cosmeticsCraftingServiceProvider),
  );
});

/// Model for user's current crafting progress
class CraftingProgress {
  final String cosmeticId;
  final DateTime startedAt;
  final DateTime completesAt;
  final String status; // 'crafting' | 'ready' | 'claimed'

  CraftingProgress({
    required this.cosmeticId,
    required this.startedAt,
    required this.completesAt,
    required this.status,
  });

  /// Time remaining until completion
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(completesAt)) {
      return Duration.zero;
    }
    return completesAt.difference(now);
  }

  /// Progress percentage (0.0 - 1.0)
  double get progressPercentage {
    final total = completesAt.difference(startedAt).inSeconds;
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Whether craft is ready to claim
  bool get isReady {
    return DateTime.now().isAfter(completesAt);
  }
}
