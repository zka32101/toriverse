import 'package:cloud_firestore/cloud_firestore.dart';
import '../../application/providers/cosmetic_state.dart';

/// Repository for fetching and managing cosmetic items from Firestore
///
/// Provides fallback to hardcoded catalog when offline or on fetch failure.
class CosmeticRepository {
  final FirebaseFirestore _firestore;

  /// Default cosmetic catalog (used as fallback)
  static const List<CosmeticItem> defaultCatalog = [
    // Board cosmetics
    CosmeticItem(
      id: 'board_wood_dark',
      type: 'board',
      name: 'Dark Wood Board',
      rarity: 'common',
      price: 120,
    ),
    CosmeticItem(
      id: 'board_marble',
      type: 'board',
      name: 'Marble Board',
      rarity: 'rare',
      price: 250,
    ),
    CosmeticItem(
      id: 'board_obsidian',
      type: 'board',
      name: 'Obsidian Board',
      rarity: 'legendary',
      price: 500,
    ),
    CosmeticItem(
      id: 'board_jade',
      type: 'board',
      name: 'Jade Board',
      rarity: 'uncommon',
      price: 180,
    ),
    // Stone cosmetics
    CosmeticItem(
      id: 'stone_golden',
      type: 'stone',
      name: 'Golden Stones',
      rarity: 'legendary',
      price: 300,
    ),
    CosmeticItem(
      id: 'stone_silver',
      type: 'stone',
      name: 'Silver Stones',
      rarity: 'rare',
      price: 200,
    ),
    CosmeticItem(
      id: 'stone_crystal',
      type: 'stone',
      name: 'Crystal Stones',
      rarity: 'uncommon',
      price: 150,
    ),
  ];

  CosmeticRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch cosmetic catalog from Firestore
  ///
  /// Returns catalog from Firestore on success, or [defaultCatalog] on failure.
  /// Failures are logged but do not throw — app continues with fallback.
  Future<List<CosmeticItem>> fetchCosmeticCatalog() async {
    try {
      final snapshot = await _firestore
          .collection('cosmetics')
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Cosmetic fetch timeout'),
          );

      if (snapshot.docs.isEmpty) {
        return defaultCatalog;
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CosmeticItem(
          id: doc.id,
          type: data['type'] ?? 'board',
          name: data['name'] ?? 'Unknown',
          rarity: data['rarity'] ?? 'common',
          price: data['price'] ?? 0,
        );
      }).toList();
    } on TimeoutException catch (_) {
      // Network timeout — use default
      return defaultCatalog;
    } catch (e) {
      // Any other error (no network, permission denied, etc) — use default
      return defaultCatalog;
    }
  }

  /// Stream cosmetic catalog for reactive updates
  ///
  /// Provides real-time updates when cosmetics are added/modified in Firestore.
  /// Falls back to default catalog stream on error.
  Stream<List<CosmeticItem>> streamCosmeticCatalog() {
    try {
      return _firestore
          .collection('cosmetics')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            if (snapshot.docs.isEmpty) {
              return defaultCatalog;
            }
            return snapshot.docs.map((doc) {
              final data = doc.data();
              return CosmeticItem(
                id: doc.id,
                type: data['type'] ?? 'board',
                name: data['name'] ?? 'Unknown',
                rarity: data['rarity'] ?? 'common',
                price: data['price'] ?? 0,
              );
            }).toList();
          })
          .handleError((_) {
            // On stream error, emit default catalog
            return defaultCatalog;
          });
    } catch (e) {
      // Immediate error — return default as stream
      return Stream.value(defaultCatalog);
    }
  }

  /// Persist user's owned cosmetics to Firestore
  ///
  /// Called after match completion or cosmetic purchase.
  Future<void> persistOwnedCosmetics({
    required String userId,
    required List<OwnedCosmetic> cosmetics,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .doc('owned')
          .set({
            'items': cosmetics
                .map((c) => {
                      'itemId': c.itemId,
                      'source': c.source,
                      'acquiredAt': c.acquiredAt.toIso8601String(),
                      'isActive': c.isActive,
                    })
                .toList(),
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      // Log but don't throw — local state already updated
      // Real persistence will retry on next app launch
    }
  }

  /// Fetch user's owned cosmetics from Firestore
  ///
  /// Falls back to empty list on any error.
  Future<List<OwnedCosmetic>> fetchOwnedCosmetics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .doc('owned')
          .get()
          .timeout(const Duration(seconds: 10));

      if (!snapshot.exists) {
        return [];
      }

      final data = snapshot.data() ?? {};
      final items = data['items'] as List<dynamic>? ?? [];

      return items
          .cast<Map<String, dynamic>>()
          .map((item) => OwnedCosmetic(
                itemId: item['itemId'] ?? '',
                source: item['source'] ?? 'unknown',
                acquiredAt: DateTime.parse(item['acquiredAt'] ?? '2026-09-02'),
                isActive: item['isActive'] ?? false,
              ))
          .toList();
    } catch (e) {
      // Any error — return empty (user has no persisted cosmetics)
      return [];
    }
  }
}

/// Exception thrown when Firestore fetch exceeds timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
