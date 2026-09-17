/// Cosmetic Item model for Firestore
/// Maps to 'cosmetics' collection (global catalog)
/// Each user owns cosmetics via reference in UserModel.premiumCosmetics
///
/// Used for seasonal board designs and stone appearance customization
class CosmeticItemModel {
  final String id;
  final String type; // 'board' or 'stone'
  final String name; // display name (e.g., "Cherry Blossom Board")
  final int priceJpy; // price in JPY (120-300)
  final String description;
  final String imageUrl;
  final String category; // 'seasonal', 'premium', 'limited'
  final bool available; // soft delete
  final DateTime createdAt;

  const CosmeticItemModel({
    required this.id,
    this.type = 'board',
    required this.name,
    required this.priceJpy,
    this.description = '',
    this.imageUrl = '',
    this.category = '',
    this.available = true,
    required this.createdAt,
  });

  factory CosmeticItemModel.fromJson(Map<String, dynamic> json) {
    return CosmeticItemModel(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'board',
      name: json['name'] as String,
      priceJpy: json['priceJpy'] as int,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? '',
      available: json['available'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'priceJpy': priceJpy,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'available': available,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
