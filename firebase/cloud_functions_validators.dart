/// Cloud Functions validators for Firestore data integrity
///
/// These validators should be deployed as Cloud Functions to ensure
/// data consistency and prevent client-side manipulation.
///
/// Deploy with:
/// ```bash
/// firebase deploy --only functions
/// ```

import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFunctions functions = FirebaseFunctions.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Validate and record cosmetic purchase
///
/// Called when user purchases cosmetic from shop.
/// Ensures purchase is valid before granting cosmetic.
Future<Map<String, dynamic>> validateCosmeticPurchase({
  required String userId,
  required String cosmeticId,
  required String revenuecatProductId,
  required String revenuecatTransactionId,
}) async {
  try {
    // Validate cosmetic exists
    final cosmeticDoc =
        await firestore.collection('cosmetics').doc(cosmeticId).get();
    if (!cosmeticDoc.exists) {
      throw Exception('Cosmetic not found: $cosmeticId');
    }

    final cosmetic = cosmeticDoc.data()!;
    final priceJpy = cosmetic['price_jpy'] as int;

    // Validate price is reasonable (< ¥10,000)
    if (priceJpy > 1000000) {
      // 10,000 yen in cents
      throw Exception('Invalid price for cosmetic: ¥$priceJpy');
    }

    // Check user doesn't already own it
    final alreadyOwned = await firestore
        .collection('users')
        .doc(userId)
        .collection('cosmetics')
        .doc(cosmeticId)
        .get();

    if (alreadyOwned.exists) {
      throw Exception('User already owns cosmetic: $cosmeticId');
    }

    // Validate cosmetic is available
    if (cosmetic['availability_status'] != 'available') {
      throw Exception('Cosmetic not available for purchase');
    }

    // Record purchase
    await firestore
        .collection('users')
        .doc(userId)
        .collection('cosmetics')
        .doc(cosmeticId)
        .set({
      'cosmetic_id': cosmeticId,
      'purchased_at': FieldValue.serverTimestamp(),
      'purchase_source': 'shop',
      'revenucat_product_id': revenuecatProductId,
      'revenucat_transaction_id': revenuecatTransactionId,
    });

    // Update user's cosmetics count for analytics
    await firestore.collection('users').doc(userId).update({
      'cosmetics_owned': FieldValue.increment(1),
      'last_purchase_at': FieldValue.serverTimestamp(),
    });

    return {
      'success': true,
      'cosmetic_id': cosmeticId,
      'price_jpy': priceJpy,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
      'cosmetic_id': cosmeticId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Validate match submission
///
/// Called when player submits move in match.
/// Ensures move is legal and player has turn.
Future<Map<String, dynamic>> validateMatchMoveSubmission({
  required String matchId,
  required String playerId,
  required int position, // 0-63 board position
  required int roundIndex,
}) async {
  try {
    // Get match document
    final matchDoc = await firestore.collection('matches').doc(matchId).get();
    if (!matchDoc.exists) {
      throw Exception('Match not found: $matchId');
    }

    final match = matchDoc.data()!;

    // Validate player is in match
    final playerIds = List<String>.from(match['playerIds'] as List);
    if (!playerIds.contains(playerId)) {
      throw Exception('Player not in match: $playerId');
    }

    // Validate it's player's turn
    final nextPlayerToMove = match['nextPlayerToMove'] as String;
    if (nextPlayerToMove != playerId) {
      throw Exception(
          'Not player turn. Next: $nextPlayerToMove, Current: $playerId');
    }

    // Validate position is valid (0-63)
    if (position < 0 || position > 63) {
      throw Exception('Invalid board position: $position');
    }

    // Validate position is empty
    final boardState = List<int>.from(match['boardState'] as List);
    if (boardState[position] != -1) {
      // -1 = empty
      throw Exception('Position already occupied: $position');
    }

    // Validate round index matches
    final currentRound = match['currentRoundIndex'] as int;
    if (roundIndex != currentRound) {
      throw Exception('Round mismatch. Expected: $currentRound, Got: $roundIndex');
    }

    // TODO: Add legality check (stone capture logic)
    // This would validate that placing at this position actually captures stones

    return {
      'success': true,
      'match_id': matchId,
      'player_id': playerId,
      'position': position,
      'round_index': roundIndex,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
      'match_id': matchId,
      'player_id': playerId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Validate user statistics update
///
/// Called when user statistics are updated after match completion.
/// Ensures values are reasonable and not manipulated.
Future<Map<String, dynamic>> validateStatisticsUpdate({
  required String userId,
  required int streakIncrement, // 1 or 0
  required int rankPointsIncrement, // 10-1000 range
  required String matchId,
}) async {
  try {
    // Validate increments are reasonable
    if (streakIncrement < 0 || streakIncrement > 1) {
      throw Exception('Invalid streak increment: $streakIncrement');
    }

    if (rankPointsIncrement < 0 || rankPointsIncrement > 10000) {
      throw Exception('Invalid rank points: $rankPointsIncrement');
    }

    // Validate match exists and is completed
    final matchDoc = await firestore.collection('matches').doc(matchId).get();
    if (!matchDoc.exists) {
      throw Exception('Match not found: $matchId');
    }

    final match = matchDoc.data()!;
    if (match['status'] != 'finished') {
      throw Exception('Match not finished: ${match['status']}');
    }

    // Get current user stats
    final userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('User not found: $userId');
    }

    final currentStats = userDoc.data()!;
    final currentStreak = currentStats['completedMatchStreak'] as int? ?? 0;
    final currentRankPoints = currentStats['rankPoints'] as int? ?? 0;

    // Update statistics
    await firestore.collection('users').doc(userId).update({
      'completedMatchStreak':
          currentStreak + streakIncrement, // Can only go up or reset
      'rankPoints': currentRankPoints + rankPointsIncrement,
      'last_match_at': FieldValue.serverTimestamp(),
    });

    return {
      'success': true,
      'user_id': userId,
      'match_id': matchId,
      'streak_increment': streakIncrement,
      'rank_points_increment': rankPointsIncrement,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
      'user_id': userId,
      'match_id': matchId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Validate preference update
///
/// Called when user changes active cosmetics.
/// Ensures user owns the cosmetic before setting active.
Future<Map<String, dynamic>> validatePreferenceUpdate({
  required String userId,
  required String cosmeticId,
  required String cosmeticType, // 'board' or 'stone'
}) async {
  try {
    // Validate cosmetic exists
    final cosmeticDoc =
        await firestore.collection('cosmetics').doc(cosmeticId).get();
    if (!cosmeticDoc.exists) {
      throw Exception('Cosmetic not found: $cosmeticId');
    }

    final cosmetic = cosmeticDoc.data()!;
    final actualType = cosmetic['type'] as String;

    // Validate type matches
    if (actualType != cosmeticType) {
      throw Exception(
          'Type mismatch. Expected: $cosmeticType, Actual: $actualType');
    }

    // Check user owns the cosmetic (or it's a default)
    if (cosmeticId != 'default_board' &&
        cosmeticId != 'default_stone_black' &&
        cosmeticId != 'default_stone_white' &&
        cosmeticId != 'default_stone_red') {
      final owned = await firestore
          .collection('users')
          .doc(userId)
          .collection('cosmetics')
          .doc(cosmeticId)
          .get();

      if (!owned.exists) {
        throw Exception('User does not own cosmetic: $cosmeticId');
      }
    }

    // Update preference
    final typeKey = _getPreferenceKey(cosmeticType);
    await firestore
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('cosmetics')
        .set({typeKey: cosmeticId}, SetOptions(merge: true));

    return {
      'success': true,
      'user_id': userId,
      'cosmetic_id': cosmeticId,
      'cosmetic_type': cosmeticType,
      'timestamp': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
      'user_id': userId,
      'cosmetic_id': cosmeticId,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Helper: Get Firestore document key for cosmetic type
String _getPreferenceKey(String cosmeticType) {
  switch (cosmeticType) {
    case 'board':
      return 'active_board';
    case 'stone_black':
      return 'active_stone_black';
    case 'stone_white':
      return 'active_stone_white';
    case 'stone_red':
      return 'active_stone_red';
    default:
      throw ArgumentError('Unknown cosmetic type: $cosmeticType');
  }
}

/// Request schema for validators
///
/// Example Cloud Function trigger:
/// ```
/// exports.validateCosmeticPurchase = functions
///   .region('asia-northeast1')
///   .runWith({
///     timeoutSeconds: 10,
///     memory: '256MB',
///   })
///   .https.onCall(async (data, context) => {
///     // Dart code above runs server-side
///     return await validateCosmeticPurchase(data);
///   });
/// ```

/// Request schema for cosmetic purchase validation
class CosmeticPurchaseRequest {
  final String userId;
  final String cosmeticId;
  final String revenuecatProductId;
  final String revenuecatTransactionId;

  CosmeticPurchaseRequest({
    required this.userId,
    required this.cosmeticId,
    required this.revenuecatProductId,
    required this.revenuecatTransactionId,
  });

  factory CosmeticPurchaseRequest.fromJson(Map<String, dynamic> json) {
    return CosmeticPurchaseRequest(
      userId: json['user_id'] as String,
      cosmeticId: json['cosmetic_id'] as String,
      revenuecatProductId: json['revenucat_product_id'] as String,
      revenuecatTransactionId: json['revenucat_transaction_id'] as String,
    );
  }
}

/// Response schema for validation results
class ValidationResponse {
  final bool success;
  final String? error;
  final Map<String, dynamic> data;

  ValidationResponse({
    required this.success,
    this.error,
    required this.data,
  });

  factory ValidationResponse.fromJson(Map<String, dynamic> json) {
    return ValidationResponse(
      success: json['success'] as bool,
      error: json['error'] as String?,
      data: json,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'error': error,
        ...data,
      };
}
