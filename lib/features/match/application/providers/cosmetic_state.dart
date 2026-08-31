import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents a cosmetic item (board design, stone appearance, etc.)
class CosmeticItem {
  /// Unique cosmetic ID (e.g., "board_wood_dark", "stone_golden")
  final String id;

  /// Cosmetic type: 'board' | 'stone'
  final String type;

  /// Display name in Japanese
  final String name;

  /// Rarity: 'common' | 'uncommon' | 'rare' | 'legendary'
  final String rarity;

  /// Price in JPY (null = not purchasable / event only)
  final int? price;

  /// When cosmetic becomes available (null = always available)
  final DateTime? availableFrom;

  /// When seasonal cosmetic expires (null = permanent)
  final DateTime? availableUntil;

  /// URL to preview image
  final String? previewImageUrl;

  /// Flavor text / description
  final String? description;

  const CosmeticItem({
    required this.id,
    required this.type,
    required this.name,
    required this.rarity,
    this.price,
    this.availableFrom,
    this.availableUntil,
    this.previewImageUrl,
    this.description,
  });

  /// Check if cosmetic is currently available for purchase
  bool get isCurrentlyAvailable {
    final now = DateTime.now();
    if (availableFrom != null && now.isBefore(availableFrom!)) {
      return false; // Not yet available
    }
    if (availableUntil != null && now.isAfter(availableUntil!)) {
      return false; // Seasonal period ended
    }
    return true;
  }

  /// Check if cosmetic is purchasable (has price and available)
  bool get isPurchasable => price != null && isCurrentlyAvailable;

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'rarity': rarity,
      'price': price,
      'availableFrom': availableFrom?.toIso8601String(),
      'availableUntil': availableUntil?.toIso8601String(),
      'previewImageUrl': previewImageUrl,
      'description': description,
    };
  }

  static CosmeticItem fromMap(Map<String, dynamic> map) {
    return CosmeticItem(
      id: map['id'] as String,
      type: map['type'] as String,
      name: map['name'] as String,
      rarity: map['rarity'] as String,
      price: map['price'] as int?,
      availableFrom: map['availableFrom'] != null
          ? DateTime.parse(map['availableFrom'] as String)
          : null,
      availableUntil: map['availableUntil'] != null
          ? DateTime.parse(map['availableUntil'] as String)
          : null,
      previewImageUrl: map['previewImageUrl'] as String?,
      description: map['description'] as String?,
    );
  }

  @override
  String toString() => 'CosmeticItem($id - $name, $rarity)';
}

/// Represents a cosmetic item owned by player
class OwnedCosmetic {
  /// Cosmetic item ID
  final String itemId;

  /// How player acquired it
  /// 'starter_kit', 'match_reward', 'milestone_reward', 'shop_purchase', 'seasonal_event'
  final String source;

  /// When player acquired it
  final DateTime acquiredAt;

  /// Is this the currently active cosmetic?
  final bool isActive;

  const OwnedCosmetic({
    required this.itemId,
    required this.source,
    required this.acquiredAt,
    required this.isActive,
  });

  /// Create a copy with optional field updates
  OwnedCosmetic copyWith({
    String? itemId,
    String? source,
    DateTime? acquiredAt,
    bool? isActive,
  }) {
    return OwnedCosmetic(
      itemId: itemId ?? this.itemId,
      source: source ?? this.source,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'source': source,
      'acquiredAt': acquiredAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  static OwnedCosmetic fromMap(Map<String, dynamic> map) {
    return OwnedCosmetic(
      itemId: map['itemId'] as String,
      source: map['source'] as String,
      acquiredAt: DateTime.parse(map['acquiredAt'] as String),
      isActive: map['isActive'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'OwnedCosmetic($itemId, active=$isActive)';
}

/// Represents player's cosmetic collection and preferences
class CosmeticState {
  /// List of cosmetics player owns
  final List<OwnedCosmetic> ownedCosmetics;

  /// ID of currently active board cosmetic
  final String? activeBoardId;

  /// Catalog of available cosmetics (for purchase/preview)
  final List<CosmeticItem> catalogItems;

  const CosmeticState({
    required this.ownedCosmetics,
    this.activeBoardId,
    required this.catalogItems,
  });

  /// Get cosmetic item details by ID
  CosmeticItem? getCosmeticById(String id) {
    try {
      return catalogItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if player owns a cosmetic
  bool isOwned(String cosmeticId) {
    return ownedCosmetics.any((owned) => owned.itemId == cosmeticId);
  }

  /// Check if player is actively using a cosmetic
  bool isActive(String cosmeticId) {
    try {
      return ownedCosmetics
          .firstWhere((owned) => owned.itemId == cosmeticId)
          .isActive;
    } catch (e) {
      // Cosmetic not owned - return false to distinguish from "owned but inactive"
      return false;
    }
  }

  /// Get list of cosmetics player owns of specific type
  List<CosmeticItem> getOwnedByType(String type) {
    return ownedCosmetics
        .where((owned) => getCosmeticById(owned.itemId)?.type == type)
        .map((owned) => getCosmeticById(owned.itemId)!)
        .whereType<CosmeticItem>()
        .toList();
  }

  /// Get list of cosmetics available for purchase
  List<CosmeticItem> getAvailableForPurchase() {
    return catalogItems.where((item) => item.isPurchasable && !isOwned(item.id)).toList();
  }

  /// Initialize for new player (with starter kit)
  static CosmeticState create({
    List<CosmeticItem> starterKit = const [],
    List<CosmeticItem> catalog = const [],
  }) {
    // Find the first board item (if any)
    CosmeticItem? firstBoard;
    try {
      firstBoard = starterKit.firstWhere((item) => item.type == 'board');
    } catch (e) {
      // No board in starter kit - that's OK
    }

    // Convert starter kit items to owned cosmetics
    final ownedItems = starterKit
        .map((item) => OwnedCosmetic(
              itemId: item.id,
              source: 'starter_kit',
              acquiredAt: DateTime.now(),
              isActive: firstBoard != null && item.id == firstBoard.id, // Only the first board is active
            ))
        .toList();

    return CosmeticState(
      ownedCosmetics: ownedItems,
      activeBoardId: firstBoard?.id, // Only set if a board was found
      catalogItems: catalog,
    );
  }

  /// Add cosmetic to collection
  CosmeticState addCosmetic(String cosmeticId, String source) {
    // Don't add if already owned
    if (isOwned(cosmeticId)) {
      return this;
    }

    final newOwned = OwnedCosmetic(
      itemId: cosmeticId,
      source: source,
      acquiredAt: DateTime.now(),
      isActive: false, // New cosmetics start inactive
    );

    return CosmeticState(
      ownedCosmetics: [...ownedCosmetics, newOwned],
      activeBoardId: activeBoardId,
      catalogItems: catalogItems,
    );
  }

  /// Activate a cosmetic (set as currently using)
  CosmeticState activateCosmetic(String cosmeticId) {
    // Check if player owns it
    if (!isOwned(cosmeticId)) {
      return this;
    }

    // Deactivate others of same type, activate this one
    final cosmetic = getCosmeticById(cosmeticId);
    if (cosmetic == null) return this;

    final updated = ownedCosmetics.map((owned) {
      final item = getCosmeticById(owned.itemId);
      if (item?.type == cosmetic.type) {
        // Same type: set active/inactive based on ID match
        return owned.copyWith(isActive: owned.itemId == cosmeticId);
      }
      // Different type: leave as is
      return owned;
    }).toList();

    return CosmeticState(
      ownedCosmetics: updated,
      activeBoardId: cosmetic.type == 'board' ? cosmeticId : activeBoardId,
      catalogItems: catalogItems,
    );
  }

  /// Merge with server state (for sync)
  CosmeticState mergeWithServer(CosmeticState remote) {
    // Combine owned cosmetics (server as source of truth for ownership)
    final merged = <String, OwnedCosmetic>{};

    // Add all remote owned cosmetics
    for (final owned in remote.ownedCosmetics) {
      merged[owned.itemId] = owned;
    }

    // Add any local-only cosmetics that aren't on server yet
    // (might be pending cloud write)
    for (final owned in ownedCosmetics) {
      if (!merged.containsKey(owned.itemId)) {
        merged[owned.itemId] = owned;
      }
    }

    // Use remote active board preference
    return CosmeticState(
      ownedCosmetics: merged.values.toList(),
      activeBoardId: remote.activeBoardId ?? activeBoardId,
      catalogItems: remote.catalogItems.isNotEmpty ? remote.catalogItems : catalogItems,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'ownedCosmetics': ownedCosmetics.map((owned) => owned.toMap()).toList(),
      'activeBoardId': activeBoardId,
    };
  }

  /// Create from Firestore document
  static CosmeticState fromFirestore(
    Map<String, dynamic> data,
    List<CosmeticItem> catalog,
  ) {
    final ownedList = (data['ownedCosmetics'] as List<dynamic>?)
            ?.map((item) => OwnedCosmetic.fromMap(item as Map<String, dynamic>))
            .toList() ??
        [];

    return CosmeticState(
      ownedCosmetics: ownedList,
      activeBoardId: data['activeBoardId'] as String?,
      catalogItems: catalog,
    );
  }

  @override
  String toString() =>
      'CosmeticState(owned=${ownedCosmetics.length}, activeBoard=$activeBoardId)';
}

/// Notifier for managing cosmetic collection state
class CosmeticNotifier extends StateNotifier<CosmeticState> {
  CosmeticNotifier(CosmeticState initial) : super(initial);

  /// Add cosmetic to collection (from reward)
  void grantCosmetic(String cosmeticId, String source) {
    state = state.addCosmetic(cosmeticId, source);
  }

  /// Activate a cosmetic for use
  void activateCosmetic(String cosmeticId) {
    state = state.activateCosmetic(cosmeticId);
  }

  /// Sync with server state
  void syncFromServer(CosmeticState remote) {
    state = state.mergeWithServer(remote);
  }

  /// Update catalog (fetch from Firestore)
  void updateCatalog(List<CosmeticItem> items) {
    state = CosmeticState(
      ownedCosmetics: state.ownedCosmetics,
      activeBoardId: state.activeBoardId,
      catalogItems: items,
    );
  }

  /// Reset to initial state
  void reset(CosmeticState initial) {
    state = initial;
  }
}

/// Provider for cosmetic state
final cosmeticProvider = StateNotifierProvider<CosmeticNotifier, CosmeticState>(
  (ref) {
    return CosmeticNotifier(
      CosmeticState.create(),
    );
  },
);

/// Provider for owned cosmetics list (read-only)
final ownedCosmeticsProvider = Provider<List<OwnedCosmetic>>((ref) {
  return ref.watch(cosmeticProvider).ownedCosmetics;
});

/// Provider for active board ID (read-only)
final activeBoardProvider = Provider<String?>((ref) {
  return ref.watch(cosmeticProvider).activeBoardId;
});

/// Provider for available cosmetics for purchase (read-only)
final availableCosmeticsProvider = Provider<List<CosmeticItem>>((ref) {
  return ref.watch(cosmeticProvider).getAvailableForPurchase();
});

/// Provider for owned cosmetics by type (e.g., 'board')
final ownedCosmeticsByTypeProvider = Provider.family<List<CosmeticItem>, String>(
  (ref, type) {
    return ref.watch(cosmeticProvider).getOwnedByType(type);
  },
);
