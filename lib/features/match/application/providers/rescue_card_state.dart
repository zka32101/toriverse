import 'package:riverpod/riverpod.dart';
import '../../data/models/rescue_card_model.dart';
import '../../domain/services/bonus_calculator.dart';
import '../services/remote_config_service.dart';

/// Tracks consecutive attacks and rescue card state per player per match
class RescueCardNotifier extends StateNotifier<Map<String, RescueCardModel>> {
  RescueCardNotifier({
    this.configService,
  }) : super({});

  final RemoteConfigService? configService;

  /// Initialize rescue cards for a match (all players start at 0 attacks)
  void initializeMatch(String matchId, List<String> playerIds) {
    final cards = <String, RescueCardModel>{};
    for (final playerId in playerIds) {
      final id = '${matchId}_$playerId';
      cards[id] = RescueCardModel(
        id: id,
        matchId: matchId,
        playerId: playerId,
        consecutiveAttackedCount: 0,
        cardAvailable: false,
        cardActivatedRound: -1,
        createdAt: DateTime.now(),
      );
    }
    state = cards;
  }

  /// Record an attack on a player from an opponent
  /// Returns whether a rescue card should be granted
  bool recordAttack(String matchId, String targetPlayerId) {
    final cardId = '${matchId}_$targetPlayerId';
    final currentCard = state[cardId];
    if (currentCard == null) return false;

    // Increment consecutive attack count
    final updatedCard = currentCard.copyWith(
      consecutiveAttackedCount: currentCard.consecutiveAttackedCount + 1,
      updatedAt: DateTime.now(),
    );

    // Check if rescue card should be granted
    final shouldGrant = RescueCardCalculator.shouldGrantRescueCard(
      consecutiveAttackCount: updatedCard.consecutiveAttackedCount,
      cardAlreadyActive: currentCard.cardAvailable,
      configService: configService,
    );

    if (shouldGrant) {
      final cardWithGrant = updatedCard.copyWith(
        cardAvailable: true,
      );
      state = {...state, cardId: cardWithGrant};
      return true;
    }

    state = {...state, cardId: updatedCard};
    return false;
  }

  /// Reset consecutive attack count when attacker changes
  void resetConsecutiveAttacks(String matchId, String playerId) {
    final cardId = '${matchId}_$playerId';
    final currentCard = state[cardId];
    if (currentCard == null) return;

    final updatedCard = currentCard.copyWith(
      consecutiveAttackedCount: 0,
      updatedAt: DateTime.now(),
    );

    state = {...state, cardId: updatedCard};
  }

  /// Activate a rescue card (use it in current round)
  bool activateCard(String matchId, String playerId, int currentRound) {
    final cardId = '${matchId}_$playerId';
    final currentCard = state[cardId];
    if (currentCard == null || !currentCard.cardAvailable) return false;

    // Only allow one use per card
    final usedCard = currentCard.copyWith(
      cardAvailable: false,
      cardActivatedRound: currentRound,
      updatedAt: DateTime.now(),
    );

    state = {...state, cardId: usedCard};
    return true;
  }

  /// Check if a player has an active rescue card
  bool hasActiveCard(String matchId, String playerId) {
    final cardId = '${matchId}_$playerId';
    final card = state[cardId];
    return card?.cardAvailable ?? false;
  }

  /// Get consecutive attack count for a player
  int getConsecutiveAttackCount(String matchId, String playerId) {
    final cardId = '${matchId}_$playerId';
    final card = state[cardId];
    return card?.consecutiveAttackedCount ?? 0;
  }

  /// Get rescue card for a player
  RescueCardModel? getCard(String matchId, String playerId) {
    final cardId = '${matchId}_$playerId';
    return state[cardId];
  }
}

/// Riverpod provider for rescue card state
/// Usage: final rescueCardState = ref.watch(rescueCardStateProvider(matchId));
final rescueCardStateProvider = StateNotifierProvider.family<
    RescueCardNotifier,
    Map<String, RescueCardModel>,
    String>((ref, matchId) {
  final configService = RemoteConfigService();
  return RescueCardNotifier(configService: configService);
});
