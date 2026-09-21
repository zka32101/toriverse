
/// Limited edition cosmetic stored in cosmetics/limited/{eventId}
class LimitedCosmetic {
  final String id;
  final String eventId;
  final String name;
  final String type; // stone, board, theme
  final String? description;
  final String? imageUrl;
  final List<String> colors;
  final String rarity; // common, uncommon, rare, legendary
  final String? requiresChallenge;
  final int basePrice;
  final bool eventExclusive;
  final DateTime createdAt;

  const LimitedCosmetic({
    required this.id,
    required this.eventId,
    required this.name,
    this.type = 'stone',
    this.description,
    this.imageUrl,
    this.colors = const [],
    this.rarity = 'common',
    this.requiresChallenge,
    this.basePrice = 0,
    this.eventExclusive = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'name': name,
        'type': type,
        'description': description,
        'imageUrl': imageUrl,
        'colors': colors,
        'rarity': rarity,
        'requiresChallenge': requiresChallenge,
        'basePrice': basePrice,
        'eventExclusive': eventExclusive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LimitedCosmetic.fromJson(Map<String, dynamic> json) {
    return LimitedCosmetic(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'stone',
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      colors: json['colors'] != null ? List<String>.from(json['colors'] as List) : const [],
      rarity: json['rarity'] as String? ?? 'common',
      requiresChallenge: json['requiresChallenge'] as String?,
      basePrice: json['basePrice'] as int? ?? 0,
      eventExclusive: json['eventExclusive'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// User's event cosmetic stored in users/{uid}/eventCosmetics/{cosmeticId}
class UserEventCosmetic {
  final String cosmeticId;
  final String eventId;
  final DateTime unlockedAt;
  final String method; // challenge, purchase, gift
  final bool equipped;

  const UserEventCosmetic({
    required this.cosmeticId,
    required this.eventId,
    required this.unlockedAt,
    this.method = 'challenge',
    this.equipped = false,
  });

  Map<String, dynamic> toJson() => {
        'cosmeticId': cosmeticId,
        'eventId': eventId,
        'unlockedAt': unlockedAt.toIso8601String(),
        'method': method,
        'equipped': equipped,
      };

  factory UserEventCosmetic.fromJson(Map<String, dynamic> json) {
    return UserEventCosmetic(
      cosmeticId: json['cosmeticId'] as String,
      eventId: json['eventId'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
      method: json['method'] as String? ?? 'challenge',
      equipped: json['equipped'] as bool? ?? false,
    );
  }
}
