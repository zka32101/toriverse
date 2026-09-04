import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:toriverse/shared/models/cosmetic_item.dart';
import 'package:toriverse/shared/services/revenucat_service.dart';

/// Service for managing cosmetics shop operations
class CosmeticsShopService {
  final FirebaseFirestore _firestore;
  final FirebaseAnalytics _analytics;
  final RevenueCatService _revenuecatService;

  CosmeticsShopService({
    required FirebaseFirestore firestore,
    required FirebaseAnalytics analytics,
    required RevenueCatService revenuecatService,
  })  : _firestore = firestore,
        _analytics = analytics,
        _revenuecatService = revenuecatService;

  /// Fetch all available cosmetics (including limited edition)
  Future<List<CosmeticItem>> fetchAvailableCosmetics() async {
    try {
      final now = DateTime.now();
      final snap = await _firestore
          .collection('cosmetics')
          .where('release_date', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('release_date', descending: true)
          .get();

      final cosmetics = snap.docs
          .map((doc) => CosmeticItem.fromMap(doc.data()))
          .toList();

      // Filter out expired limited editions
      return cosmetics.where((item) {
        if (item.limitedEditionEndDate != null) {
          return item.limitedEditionEndDate!.isAfter(now);
        }
        return true;
      }).toList();
    } catch (e) {
      print('Error fetching cosmetics: $e');
      return [];
    }
  }

  /// Fetch cosmetics filtered by type
  Future<List<CosmeticItem>> fetchCosmeticsByType(CosmeticType type) async {
    try {
      final typeStr = type == CosmeticType.board ? 'board' : 'stone_${type.name.split('_').last}';
      final now = DateTime.now();

      final snap = await _firestore
          .collection('cosmetics')
          .where('type', isEqualTo: typeStr)
          .where('release_date', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('release_date', descending: true)
          .get();

      return snap.docs
          .map((doc) => CosmeticItem.fromMap(doc.data()))
          .where((item) {
        if (item.limitedEditionEndDate != null) {
          return item.limitedEditionEndDate!.isAfter(now);
        }
        return true;
      }).toList();
    } catch (e) {
      print('Error fetching cosmetics by type: $e');
      return [];
    }
  }

  /// Get user's owned cosmetics
  Future<List<CosmeticItem>> getUserCosmetics(String userId) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .get();

      if (snap.docs.isEmpty) return [];

      // Fetch full cosmetic details for each owned cosmetic
      final cosmetics = <CosmeticItem>[];
      for (final doc in snap.docs) {
        try {
          final cosmeticId = doc['cosmetic_id'] as String;
          final cosmeticSnap =
              await _firestore.collection('cosmetics').doc(cosmeticId).get();

          if (cosmeticSnap.exists) {
            cosmetics.add(CosmeticItem.fromMap(cosmeticSnap.data()!));
          }
        } catch (e) {
          print('Error fetching cosmetic details: $e');
        }
      }
      return cosmetics;
    } catch (e) {
      print('Error fetching user cosmetics: $e');
      return [];
    }
  }

  /// Check if user owns a specific cosmetic
  Future<bool> userOwnsCosmectic(
    String userId,
    String cosmeticId,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .doc(cosmeticId)
          .get();

      return doc.exists;
    } catch (e) {
      print('Error checking cosmetic ownership: $e');
      return false;
    }
  }

  /// Purchase cosmetic with RevenueCat payment validation
  ///
  /// Validates purchase through RevenueCat backend, then records in Firestore.
  /// This prevents fraud and ensures purchases are genuine.
  Future<bool> purchaseCosmetic(
    String userId,
    CosmeticItem cosmetic,
  ) async {
    try {
      // Check if already owned
      final alreadyOwned = await userOwnsCosmectic(userId, cosmetic.id);
      if (alreadyOwned) {
        return false; // Already owned
      }

      // Initialize RevenueCat if not already done
      await _revenuecatService.initialize();

      // Fetch product from app store via RevenueCat
      final products = await _revenuecatService.getShopProducts(
        offering: 'cosmetics_shop',
      );

      // Find matching product by cosmetic ID
      final product = products.firstWhere(
        (p) => p.identifier == cosmetic.id,
        orElse: () => throw Exception('Product not found: ${cosmetic.id}'),
      );

      // Execute purchase through app store (RevenueCat handles receipt validation)
      final customerInfo = await _revenuecatService.purchaseCosmeticItem(
        product: product,
      );

      // Verify purchase was successful via RevenueCat backend validation
      final ownsCosmetic = await _revenuecatService.userOwnsCosmetic(
        cosmeticId: cosmetic.id,
      );

      if (!ownsCosmetic) {
        throw Exception('Purchase validation failed');
      }

      // Record purchase in Firestore for app state
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .doc(cosmetic.id)
          .set({
            'cosmetic_id': cosmetic.id,
            'purchased_at': FieldValue.serverTimestamp(),
            'purchase_source': 'shop',
            'revenucat_product_id': cosmetic.id,
            'revenucat_transaction_id': customerInfo.originalAppUserId,
          });

      // Track analytics
      await _analytics.logEvent(
        name: 'cosmetics_purchased',
        parameters: {
          'cosmetic_id': cosmetic.id,
          'cosmetic_name': cosmetic.name,
          'price_yen': cosmetic.priceJpy,
          'type': cosmetic.typeString,
          'rarity': cosmetic.rarity.name,
          'payment_method': 'revenucat_validated',
        },
      );

      return true;
    } catch (e) {
      print('Purchase failed: $e');

      // Track failed purchase
      await _analytics.logEvent(
        name: 'cosmetics_purchase_failed',
        parameters: {
          'cosmetic_id': cosmetic.id,
          'reason': e.toString(),
        },
      );

      return false;
    }
  }

  /// Get user's active cosmetics preferences
  Future<UserCosmeticsPreference> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('cosmetics')
          .get();

      if (!doc.exists) {
        return const UserCosmeticsPreference();
      }

      return UserCosmeticsPreference.fromMap(doc.data()!);
    } catch (e) {
      print('Error fetching user preferences: $e');
      return const UserCosmeticsPreference();
    }
  }

  /// Set active cosmetic for a type
  Future<bool> setActiveCosmectic(
    String userId,
    String cosmeticId,
    CosmeticType type,
  ) async {
    try {
      final prefsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('cosmetics');

      final typeKey = _getPreferenceKey(type);

      await prefsRef.set(
        {typeKey: cosmeticId},
        SetOptions(merge: true),
      );

      // Track usage
      await _analytics.logEvent(
        name: 'cosmetic_applied_to_match',
        parameters: {
          'cosmetic_id': cosmeticId,
          'type': type.toString(),
        },
      );

      return true;
    } catch (e) {
      print('Error setting active cosmetic: $e');
      return false;
    }
  }

  /// Reset cosmetics to defaults
  Future<bool> resetCosmeticsToDefaults(String userId) async {
    try {
      final prefsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('cosmetics');

      await prefsRef.set(
        {
          'active_board': 'default',
          'active_stone_black': 'default',
          'active_stone_white': 'default',
          'active_stone_red': 'default',
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (e) {
      print('Error resetting cosmetics: $e');
      return false;
    }
  }

  /// Stream available cosmetics (for real-time updates)
  Stream<List<CosmeticItem>> streamAvailableCosmetics() {
    final now = DateTime.now();

    return _firestore
        .collection('cosmetics')
        .where('release_date', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('release_date', descending: true)
        .snapshots()
        .map((snap) {
      final cosmetics = snap.docs
          .map((doc) => CosmeticItem.fromMap(doc.data()))
          .toList();

      // Filter out expired limited editions
      return cosmetics.where((item) {
        if (item.limitedEditionEndDate != null) {
          return item.limitedEditionEndDate!.isAfter(now);
        }
        return true;
      }).toList();
    }).handleError((error) {
      print('Error streaming cosmetics: $error');
      return <CosmeticItem>[];
    });
  }

  String _getPreferenceKey(CosmeticType type) {
    switch (type) {
      case CosmeticType.board:
        return 'active_board';
      case CosmeticType.stoneBlack:
        return 'active_stone_black';
      case CosmeticType.stoneWhite:
        return 'active_stone_white';
      case CosmeticType.stoneRed:
        return 'active_stone_red';
    }
  }

  /// Get featured cosmetics (for UI showcase)
  Future<List<CosmeticItem>> getFeaturedCosmetics({int limit = 3}) async {
    try {
      final now = DateTime.now();
      final cosmetics = await fetchAvailableCosmetics();

      // Sort by rarity (limited > rare > common) and date
      cosmetics.sort((a, b) {
        final rarityOrder = {'limited': 0, 'rare': 1, 'common': 2};
        final aRarity = rarityOrder[a.rarity.name] ?? 2;
        final bRarity = rarityOrder[b.rarity.name] ?? 2;

        if (aRarity != bRarity) return aRarity.compareTo(bRarity);
        return b.releaseDate.compareTo(a.releaseDate);
      });

      return cosmetics.take(limit).toList();
    } catch (e) {
      print('Error getting featured cosmetics: $e');
      return [];
    }
  }
}
