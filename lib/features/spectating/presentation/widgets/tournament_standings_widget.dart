import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/tournament_providers.dart';
import 'package:toriverse/features/spectating/domain/models/tournament.dart';

/// Tournament standings and leaderboard widget
///
/// Displays real-time standings with rankings, win rates, and player progress.
class TournamentStandingsWidget extends ConsumerWidget {
  final String tournamentId;

  const TournamentStandingsWidget({
    required this.tournamentId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsAsync = ref.watch(
      standingsStreamProvider(_GetTournamentParams(tournamentId)),
    );

    return standingsAsync.when(
      data: (standings) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStandingsHeader(),
            const SizedBox(height: 16),
            _buildStandingsTable(standings),
          ],
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => Center(
        child: Text('Error: $err'),
      ),
    );
  }

  Widget _buildStandingsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.amber),
          SizedBox(width: 12),
          Text(
            'Tournament Standings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(List<TournamentParticipant> standings) {
    return Column(
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'Rank',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Player',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'W-L',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Rate',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Pts',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
        // Standing rows
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: standings.length,
          itemBuilder: (context, index) {
            final participant = standings[index];
            return _buildStandingRow(participant, index + 1);
          },
        ),
      ],
    );
  }

  Widget _buildStandingRow(
    TournamentParticipant participant,
    int rank,
  ) {
    final winRate = participant.wins + participant.losses == 0
        ? 0.0
        : participant.wins / (participant.wins + participant.losses);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: _buildRankBadge(rank),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (participant.consecutiveWins > 0)
                  Text(
                    '🔥 ${participant.consecutiveWins} streak',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${participant.wins}-${participant.losses}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${(winRate * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: winRate >= 0.5 ? Colors.green[700] : Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              participant.points.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    late Color bgColor;
    late String medal;

    switch (rank) {
      case 1:
        bgColor = Colors.amber[100]!;
        medal = '🥇';
      case 2:
        bgColor = Colors.grey[300]!;
        medal = '🥈';
      case 3:
        bgColor = Colors.orange[100]!;
        medal = '🥉';
      default:
        bgColor = Colors.grey[100]!;
        medal = '#$rank';
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: rank <= 3
          ? Text(
              medal,
              style: const TextStyle(fontSize: 16),
            )
          : Text(
              rank.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
    );
  }
}
