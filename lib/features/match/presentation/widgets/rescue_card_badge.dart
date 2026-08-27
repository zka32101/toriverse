import 'package:flutter/material.dart';
import '../../../../config/theme.dart';

/// Rescue card badge - shows availability of rescue card for a player
class RescueCardBadge extends StatelessWidget {
  final bool isAvailable;
  final String playerName;
  final bool isCurrentPlayer;

  const RescueCardBadge({
    required this.isAvailable,
    required this.playerName,
    this.isCurrentPlayer = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isAvailable) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: ToriverseTheme.accentRed.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ToriverseTheme.accentRed,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: ToriverseTheme.accentRed.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: ToriverseTheme.spacing12,
        vertical: ToriverseTheme.spacing8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.card_giftcard,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: ToriverseTheme.spacing8),
          Text(
            '救済カード',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Player stat card showing stones and rescue card status
class PlayerStatCard extends StatelessWidget {
  final String playerName;
  final int stoneCount;
  final bool hasRescueCard;
  final bool isCurrentPlayer;
  final int playerIndex;

  const PlayerStatCard({
    required this.playerName,
    required this.stoneCount,
    this.hasRescueCard = false,
    this.isCurrentPlayer = false,
    required this.playerIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stoneColor = ToriverseTheme.getStoneColor(playerIndex);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentPlayer ? ToriverseTheme.accentRed : Colors.grey,
          width: isCurrentPlayer ? 3 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isCurrentPlayer
            ? ToriverseTheme.accentRed.withOpacity(0.05)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.all(ToriverseTheme.spacing12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stoneColor,
                  border: stoneColor == ToriverseTheme.stoneWhite
                      ? Border.all(color: Colors.grey.shade400, width: 1)
                      : null,
                ),
              ),
              const SizedBox(width: ToriverseTheme.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stoneCount}個',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasRescueCard)
                Tooltip(
                  message: '2手連続実行権あり',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ToriverseTheme.accentRed.withOpacity(0.2),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: ToriverseTheme.accentRed,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          if (isCurrentPlayer)
            Padding(
              padding: const EdgeInsets.only(
                top: ToriverseTheme.spacing8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: ToriverseTheme.accentRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: ToriverseTheme.spacing8,
                  vertical: 2,
                ),
                child: const Text(
                  'あなたのターン',
                  style: TextStyle(
                    fontSize: 11,
                    color: ToriverseTheme.accentRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
