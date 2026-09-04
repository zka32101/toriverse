import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/features/shop/domain/services/cosmetic_showcase_service.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'cosmetics_providers.dart';

/// Provider for CosmeticShowcaseService
final cosmeticShowcaseServiceProvider = Provider<CosmeticShowcaseService>((ref) {
  return CosmeticShowcaseService();
});

/// Provider for user's collection statistics
final collectionStatsProvider = FutureProvider<CosmeticCollectionStats>((ref) async {
  final service = ref.watch(cosmeticShowcaseServiceProvider);
  final userCosmetics = await ref.watch(userCosmeticsProvider.future);

  return service.calculateStats(userCosmetics);
});

/// Provider for showcase display (organized by rarity)
final showcaseDisplayProvider = FutureProvider<CosmeticShowcaseDisplay>((ref) async {
  final service = ref.watch(cosmeticShowcaseServiceProvider);
  final userCosmetics = await ref.watch(userCosmeticsProvider.future);
  final allCosmetics = await ref.watch(availableCosmeticsProvider.future);

  return service.getShowcaseDisplay(userCosmetics, allCosmetics);
});

/// Provider for collection completion percentage
final completionPercentageProvider = FutureProvider<double>((ref) async {
  final display = await ref.watch(showcaseDisplayProvider.future);
  return display.getCompletionPercentage();
});

/// Provider for collection achievements
final collectionAchievementsProvider =
    FutureProvider<List<CollectionAchievement>>((ref) async {
  final service = ref.watch(cosmeticShowcaseServiceProvider);
  final userCosmetics = await ref.watch(userCosmeticsProvider.future);
  final allCosmetics = await ref.watch(availableCosmeticsProvider.future);

  return service.getAchievements(userCosmetics, allCosmetics);
});

/// Provider for comparing two users' collections
final collectionComparisonProvider = FutureProvider.family<
    CollectionComparison,
    String>((ref, otherUserId) async {
  final service = ref.watch(cosmeticShowcaseServiceProvider);
  final userId = ref.watch(userIdProvider);
  final firestore = FirebaseFirestore.instance;

  // Get both users' cosmetics
  final userCosmetics = await ref.watch(userCosmeticsProvider.future);

  final otherUserCosmetics = await _getUserCosmetics(firestore, otherUserId);

  return service.compareCollections(userCosmetics, otherUserCosmetics);
});

/// Helper function to fetch another user's cosmetics
Future<List<CosmeticItem>> _getUserCosmetics(
  FirebaseFirestore firestore,
  String userId,
) async {
  final snapshot = await firestore
      .collection('users')
      .doc(userId)
      .collection('inventory')
      .get();

  final cosmetics = <CosmeticItem>[];
  for (final doc in snapshot.docs) {
    final cosmeticId = doc.id;
    // Fetch cosmetic details from catalog
    // This is a simplified version; in production, batch these queries
    try {
      final catalogDoc = await firestore.collection('cosmetics').doc(cosmeticId).get();
      if (catalogDoc.exists) {
        // Convert to CosmeticItem (simplified)
        cosmetics.add(CosmeticItem(
          id: cosmeticId,
          name: catalogDoc['name'] ?? cosmeticId,
          description: catalogDoc['description'],
          type: _parseType(catalogDoc['type']),
          rarity: _parseRarity(catalogDoc['rarity']),
          priceJpy: catalogDoc['price_jpy'] ?? 120,
          purchasedAt: catalogDoc['purchased_at'] != null
              ? (catalogDoc['purchased_at'] as Timestamp).toDate()
              : null,
        ));
      }
    } catch (_) {
      // Skip cosmetics that can't be fetched
    }
  }

  return cosmetics;
}

/// Parse cosmetic type from string
CosmeticType _parseType(String? value) {
  switch (value) {
    case 'board':
      return CosmeticType.board;
    case 'stone_black':
      return CosmeticType.stoneBlack;
    case 'stone_white':
      return CosmeticType.stoneWhite;
    case 'stone_red':
      return CosmeticType.stoneRed;
    default:
      return CosmeticType.board;
  }
}

/// Parse cosmetic rarity from string
CosmeticRarity _parseRarity(String? value) {
  switch (value) {
    case 'common':
      return CosmeticRarity.common;
    case 'rare':
      return CosmeticRarity.rare;
    case 'limited':
      return CosmeticRarity.limited;
    default:
      return CosmeticRarity.common;
  }
}

/// State notifier for showcase operations
class ShowcaseNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseAnalytics _analytics;
  final String _userId;
  final CosmeticShowcaseService _showcaseService;

  ShowcaseNotifier({
    required FirebaseAnalytics analytics,
    required String userId,
    required CosmeticShowcaseService showcaseService,
  })  : _analytics = analytics,
        _userId = userId,
        _showcaseService = showcaseService,
        super(const AsyncValue.data(null));

  /// Log collection view event
  Future<void> logCollectionViewed({
    required int totalOwned,
    required double completionPercentage,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'collection_viewed',
        parameters: {
          'user_id': _userId,
          'total_owned': totalOwned,
          'completion_percentage': completionPercentage.toInt(),
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log collection comparison event
  Future<void> logCollectionCompared({
    required String otherUserId,
    required int leadSize,
    required int sharedCount,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'collection_compared',
        parameters: {
          'user_a': _userId,
          'user_b': otherUserId,
          'lead_size': leadSize,
          'shared_count': sharedCount,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log achievement earned event
  Future<void> logAchievementEarned({
    required String achievementId,
    required int cosmeticsOwned,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'achievement_earned',
        parameters: {
          'achievement_id': achievementId,
          'at_tier': cosmeticsOwned,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Log collection shared event
  Future<void> logCollectionShared({
    required String platform,
    required int cosmeticCount,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _analytics.logEvent(
        name: 'collection_shared',
        parameters: {
          'platform': platform,
          'cosmetic_count': cosmeticCount,
        },
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for showcase operations
final showcaseNotifierProvider =
    StateNotifierProvider<ShowcaseNotifier, AsyncValue<void>>((ref) {
  return ShowcaseNotifier(
    analytics: FirebaseAnalytics.instance,
    userId: ref.watch(userIdProvider),
    showcaseService: ref.watch(cosmeticShowcaseServiceProvider),
  );
});
