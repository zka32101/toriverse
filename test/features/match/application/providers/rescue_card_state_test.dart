import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toriverse/features/match/application/providers/rescue_card_state.dart';
import 'package:toriverse/features/match/application/services/remote_config_service.dart';

void main() {
  group('RescueCardNotifier', () {
    late RescueCardNotifier notifier;
    const matchId = 'test-match-1';
    const playerIds = ['player1', 'player2', 'player3'];

    setUp(() {
      notifier = RescueCardNotifier(configService: RemoteConfigService());
    });

    group('Initialization', () {
      test('initializeMatch creates rescue cards for all players', () {
        notifier.initializeMatch(matchId, playerIds);

        expect(notifier.state.length, equals(3));
        expect(
          notifier.state.containsKey('${matchId}_player1'),
          isTrue,
        );
        expect(
          notifier.state.containsKey('${matchId}_player2'),
          isTrue,
        );
        expect(
          notifier.state.containsKey('${matchId}_player3'),
          isTrue,
        );
      });

      test('initial cards have zero consecutive attacks', () {
        notifier.initializeMatch(matchId, playerIds);

        for (final playerId in playerIds) {
          final count = notifier.getConsecutiveAttackCount(matchId, playerId);
          expect(count, equals(0));
        }
      });

      test('initial cards are inactive', () {
        notifier.initializeMatch(matchId, playerIds);

        for (final playerId in playerIds) {
          final hasCard = notifier.hasActiveCard(matchId, playerId);
          expect(hasCard, isFalse);
        }
      });
    });

    group('Attack Recording', () {
      setUp(() {
        notifier.initializeMatch(matchId, playerIds);
      });

      test('recordAttack increments consecutive attack count', () {
        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(0),
        );

        notifier.recordAttack(matchId, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(1),
        );
      });

      test('recordAttack returns false before threshold', () {
        final result1 = notifier.recordAttack(matchId, 'player1');
        expect(result1, isFalse);

        final result2 = notifier.recordAttack(matchId, 'player1');
        expect(result2, isTrue); // Should grant on second attack
      });

      test('recordAttack grants rescue card at threshold', () {
        // First attack - no card
        notifier.recordAttack(matchId, 'player1');
        expect(notifier.hasActiveCard(matchId, 'player1'), isFalse);

        // Second attack - card should be granted
        notifier.recordAttack(matchId, 'player1');
        expect(notifier.hasActiveCard(matchId, 'player1'), isTrue);
      });

      test('consecutive attacks count correctly', () {
        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(3),
        );
      });
    });

    group('Consecutive Attacks Reset', () {
      setUp(() {
        notifier.initializeMatch(matchId, playerIds);
      });

      test('resetConsecutiveAttacks clears attack count', () {
        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(2),
        );

        notifier.resetConsecutiveAttacks(matchId, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(0),
        );
      });

      test('resetConsecutiveAttacks does not affect other players', () {
        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player2');
        notifier.recordAttack(matchId, 'player2');

        notifier.resetConsecutiveAttacks(matchId, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player1'),
          equals(0),
        );
        expect(
          notifier.getConsecutiveAttackCount(matchId, 'player2'),
          equals(2),
        );
      });
    });

    group('Card Activation', () {
      setUp(() {
        notifier.initializeMatch(matchId, playerIds);
        // Grant a card
        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player1');
      });

      test('activateCard uses an available card', () {
        expect(notifier.hasActiveCard(matchId, 'player1'), isTrue);

        final activated = notifier.activateCard(matchId, 'player1', 5);
        expect(activated, isTrue);
        expect(notifier.hasActiveCard(matchId, 'player1'), isFalse);
      });

      test('activateCard returns false when no card available', () {
        // Activate the card
        notifier.activateCard(matchId, 'player1', 5);

        // Try to activate again (already used)
        final activated = notifier.activateCard(matchId, 'player1', 6);
        expect(activated, isFalse);
      });

      test('activateCard returns false for player without card', () {
        final activated = notifier.activateCard(matchId, 'player2', 5);
        expect(activated, isFalse);
      });

      test('activateCard records activation round', () {
        notifier.activateCard(matchId, 'player1', 5);

        final card = notifier.getCard(matchId, 'player1');
        expect(card?.cardActivatedRound, equals(5));
      });
    });

    group('Card Query Methods', () {
      setUp(() {
        notifier.initializeMatch(matchId, playerIds);
      });

      test('hasActiveCard returns correct status', () {
        expect(notifier.hasActiveCard(matchId, 'player1'), isFalse);

        notifier.recordAttack(matchId, 'player1');
        notifier.recordAttack(matchId, 'player1');

        expect(notifier.hasActiveCard(matchId, 'player1'), isTrue);
      });

      test('getCard returns null for nonexistent player', () {
        final card = notifier.getCard(matchId, 'nonexistent-player');
        expect(card, isNull);
      });

      test('getCard returns card for existing player', () {
        final card = notifier.getCard(matchId, 'player1');
        expect(card, isNotNull);
        expect(card?.playerId, equals('player1'));
      });
    });

    group('Multiple Matches', () {
      test('separate matches maintain independent state', () {
        const matchId1 = 'match-1';
        const matchId2 = 'match-2';

        notifier.initializeMatch(matchId1, playerIds);
        notifier.initializeMatch(matchId2, playerIds);

        notifier.recordAttack(matchId1, 'player1');
        notifier.recordAttack(matchId1, 'player1');

        notifier.recordAttack(matchId2, 'player1');

        expect(
          notifier.getConsecutiveAttackCount(matchId1, 'player1'),
          equals(2),
        );
        expect(
          notifier.getConsecutiveAttackCount(matchId2, 'player1'),
          equals(1),
        );
      });
    });
  });
}
