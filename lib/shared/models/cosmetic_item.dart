import 'package:cloud_firestore/cloud_firestore.dart';

/// Cosmetic item rarity levels
enum CosmeticRarity {
  common,
  rare,
  limited,
}

/// Cosmetic type (board or stone design)
enum CosmeticType {
  board,
  stoneBlack,
  stoneWhite,
  stoneRed,
}

/// Represents a cosmetic item (board design or stone design)
class CosmeticItem {
  final String id;
  final CosmeticType type;
  final String name;
  final String description;
  final int price; // JPY
  final CosmeticRarity rarity;
  final String colorScheme;
  final String previewImageUrl;
  final DateTime releaseDate;
  final DateTime? limitedEditionEndDate;
  final String requiresMinVersion;
  final String revenuekatProductId;

  const CosmeticItem({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.price,
    required this.rarity,
    required this.colorScheme,
    required this.previewImageUrl,
    required this.releaseDate,
    this.limitedEditionEndDate,
    required this.requiresMinVersion,
    required this.revenuekatProductId,
  });

  /// Convert CosmeticType enum to string
  String get typeString {
    switch (type) {
      case CosmeticType.board:
        return 'board';
      case CosmeticType.stoneBlack:
        return 'stone_black';
      case CosmeticType.stoneWhite:
        return 'stone_white';
      case CosmeticType.stoneRed:
        return 'stone_red';
    }
  }

  /// Check if this cosmetic is currently available (limited edition)
  bool get isCurrentlyAvailable {
    final now = DateTime.now();
    if (releaseDate.isAfter(now)) return false;
    if (limitedEditionEndDate != null && limitedEditionEndDate!.isBefore(now)) {
      return false;
    }
    return true;
  }

  /// Check if this is a limited edition item
  bool get isLimitedEdition => limitedEditionEndDate != null;

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': typeString,
      'name': name,
      'description': description,
      'price': price,
      'rarity': rarity.name,
      'color_scheme': colorScheme,
      'preview_image_url': previewImageUrl,
      'release_date': Timestamp.fromDate(releaseDate),
      'limited_edition_end_date': limitedEditionEndDate != null
          ? Timestamp.fromDate(limitedEditionEndDate!)
          : null,
      'requires_min_version': requiresMinVersion,
      'revenueket_product_id': revenuekatProductId,
    };
  }

  /// Create from Firestore map
  factory CosmeticItem.fromMap(Map<String, dynamic> map) {
    return CosmeticItem(
      id: map['id'] as String,
      type: _parseType(map['type'] as String),
      name: map['name'] as String,
      description: map['description'] as String,
      price: map['price'] as int,
      rarity: CosmeticRarity.values.byName(map['rarity'] as String),
      colorScheme: map['color_scheme'] as String,
      previewImageUrl: map['preview_image_url'] as String,
      releaseDate:
          (map['release_date'] as Timestamp).toDate(),
      limitedEditionEndDate: map['limited_edition_end_date'] != null
          ? (map['limited_edition_end_date'] as Timestamp).toDate()
          : null,
      requiresMinVersion: map['requires_min_version'] as String? ?? '0.1.0',
      revenuekatProductId: map['revenueket_product_id'] as String,
    );
  }

  static CosmeticType _parseType(String typeStr) {
    switch (typeStr) {
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

  /// Copy with modifications
  CosmeticItem copyWith({
    String? id,
    CosmeticType? type,
    String? name,
    String? description,
    int? price,
    CosmeticRarity? rarity,
    String? colorScheme,
    String? previewImageUrl,
    DateTime? releaseDate,
    DateTime? limitedEditionEndDate,
    String? requiresMinVersion,
    String? revenuekatProductId,
  }) {
    return CosmeticItem(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      rarity: rarity ?? this.rarity,
      colorScheme: colorScheme ?? this.colorScheme,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      releaseDate: releaseDate ?? this.releaseDate,
      limitedEditionEndDate: limitedEditionEndDate ?? this.limitedEditionEndDate,
      requiresMinVersion: requiresMinVersion ?? this.requiresMinVersion,
      revenuekatProductId: revenuekatProductId ?? this.revenuekatProductId,
    );
  }

  @override
  String toString() =>
      'CosmeticItem(id: $id, type: $type, name: $name, price: ¥$price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CosmeticItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// User's owned cosmetic
class UserCosmetic {
  final String cosmeticId;
  final DateTime purchasedAt;
  final String purchaseSource; // 'shop', 'seasonal_reward', 'event_gift'
  final String revenuekatProductId;

  const UserCosmetic({
    required this.cosmeticId,
    required this.purchasedAt,
    required this.purchaseSource,
    required this.revenuekatProductId,
  });

  Map<String, dynamic> toMap() {
    return {
      'cosmetic_id': cosmeticId,
      'purchased_at': Timestamp.fromDate(purchasedAt),
      'purchase_source': purchaseSource,
      'revenueket_product_id': revenuekatProductId,
    };
  }

  factory UserCosmetic.fromMap(Map<String, dynamic> map) {
    return UserCosmetic(
      cosmeticId: map['cosmetic_id'] as String,
      purchasedAt: (map['purchased_at'] as Timestamp).toDate(),
      purchaseSource: map['purchase_source'] as String? ?? 'shop',
      revenuekatProductId: map['revenueket_product_id'] as String,
    );
  }
}

/// User's cosmetics preferences (which cosmetics are active)
class UserCosmeticsPreference {
  final String activeBoard; // cosmeticId or 'default'
  final String activeStoneBlack; // cosmeticId or 'default'
  final String activeStoneWhite;
  final String activeStoneRed;

  const UserCosmeticsPreference({
    this.activeBoard = 'default',
    this.activeStoneBlack = 'default',
    this.activeStoneWhite = 'default',
    this.activeStoneRed = 'default',
  });

  Map<String, dynamic> toMap() {
    return {
      'active_board': activeBoard,
      'active_stone_black': activeStoneBlack,
      'active_stone_white': activeStoneWhite,
      'active_stone_red': activeStoneRed,
    };
  }

  factory UserCosmeticsPreference.fromMap(Map<String, dynamic> map) {
    return UserCosmeticsPreference(
      activeBoard: map['active_board'] as String? ?? 'default',
      activeStoneBlack: map['active_stone_black'] as String? ?? 'default',
      activeStoneWhite: map['active_stone_white'] as String? ?? 'default',
      activeStoneRed: map['active_stone_red'] as String? ?? 'default',
    );
  }

  UserCosmeticsPreference copyWith({
    String? activeBoard,
    String? activeStoneBlack,
    String? activeStoneWhite,
    String? activeStoneRed,
  }) {
    return UserCosmeticsPreference(
      activeBoard: activeBoard ?? this.activeBoard,
      activeStoneBlack: activeStoneBlack ?? this.activeStoneBlack,
      activeStoneWhite: activeStoneWhite ?? this.activeStoneWhite,
      activeStoneRed: activeStoneRed ?? this.activeStoneRed,
    );
  }
}
