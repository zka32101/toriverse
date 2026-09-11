import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';

/// Results screen: displays match results, streak updates, and reverse-turn replay
class ResultsScreen extends ConsumerStatefulWidget {
  final String matchId;

  const ResultsScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _showingReplay = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final streak = ref.watch(streakProvider);

    if (gameState == null || !gameState.isGameOver) {
      return Scaffold(
        appBar: AppBar(title: const Text('リザルト')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stoneCounts = gameState.stoneCounts;
    final playerIds = gameState.playerIds;

    // Calculate ranking
    final ranking = List.generate(3, (i) => i)
        .toList()
      ..sort((a, b) =>
          stoneCounts[playerIds[b]]!.compareTo(stoneCounts[playerIds[a]]!));

    // Check if there was a reverse (player in 2nd place beats player in 1st)
    final hasReversal = ranking[0] != 0; // Not player_0 in first place
    final reversalPlayerIndex = ranking[0];

    return Scaffold(
      appBar: AppBar(
        title: const Text('リザルト'),
        elevation: 0,
        backgroundColor: hasReversal
            ? Colors.red.shade400 // Highlight reversals in red
            : Colors.blue.shade400,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Reversal highlight
              if (hasReversal)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ReverseHighlight(
                    winner: playerIds[reversalPlayerIndex],
                    stoneCount: stoneCounts[playerIds[reversalPlayerIndex]] ?? 0,
                  ),
                ),

              // Streak display with animation
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        '連続完走',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: streak),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Text(
                            '$value',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Rankings
              const Text(
                '順位',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (index) {
                final playerIndex = ranking[index];
                final playerId = playerIds[playerIndex];
                final stoneCount = stoneCounts[playerId] ?? 0;
                final medal = index == 0
                    ? '🥇'
                    : index == 1
                        ? '🥈'
                        : '🥉';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _RankingCard(
                    medal: medal,
                    rank: index + 1,
                    playerId: playerId,
                    stoneCount: stoneCount,
                    isHighlight: hasReversal && index == 0,
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Reverse-turn replay section
              Text(
                'ゲーム検証',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _ReverseReplayButton(
                isShowing: _showingReplay,
                onPressed: () {
                  setState(() => _showingReplay = !_showingReplay);
                },
              ),
              const SizedBox(height: 12),

              if (_showingReplay)
                _ReverseReplayWidget(
                  board: gameState.board,
                  playerIds: playerIds,
                ),

              const SizedBox(height: 24),

              // Clip sharing section
              Text(
                'シェア',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showShareOptions(context);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('この対局をシェア'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Home button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).resetGame();
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'ホームに戻る',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'この対局をシェア',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _ShareOptionTile(
              icon: Icons.movie,
              title: 'クリップを生成して共有',
              subtitle: 'ハイライトシーンを動画クリップで',
              onTap: () {
                Navigator.pop(context);
                _generateAndShareClip();
              },
            ),
            const SizedBox(height: 8),
            _ShareOptionTile(
              icon: Icons.link,
              title: 'リプレイリンクをコピー',
              subtitle: 'この対局の再生リンクをコピー',
              onTap: () {
                Navigator.pop(context);
                _copyReplayLink();
              },
            ),
            const SizedBox(height: 8),
            _ShareOptionTile(
              icon: Icons.person_add,
              title: 'フレンドに招待',
              subtitle: 'この相手と再戦する',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('フレンド招待機能は準備中です')),
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
          ],
        ),
      ),
    );
  }

  void _generateAndShareClip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('クリップ生成中...')),
    );
    // TODO: Integrate with clipping service
  }

  void _copyReplayLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('リンクをコピーしました')),
    );
    // TODO: Copy link to clipboard
  }
}

/// Highlight for reverse wins
class _ReverseHighlight extends StatelessWidget {
  final String winner;
  final int stoneCount;

  const _ReverseHighlight({
    required this.winner,
    required this.stoneCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade300, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade600, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '🔥 逆転勝利！',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$winner が $stoneCount 石で優勝',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ranking card with styling
class _RankingCard extends StatelessWidget {
  final String medal;
  final int rank;
  final String playerId;
  final int stoneCount;
  final bool isHighlight;

  const _RankingCard({
    required this.medal,
    required this.rank,
    required this.playerId,
    required this.stoneCount,
    required this.isHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isHighlight ? 8 : 2,
      color: isHighlight ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  medal,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$rank位',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isHighlight ? Colors.red : Colors.black,
                      ),
                    ),
                    Text(
                      playerId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '$stoneCount 石',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reverse replay button
class _ReverseReplayButton extends StatelessWidget {
  final bool isShowing;
  final VoidCallback onPressed;

  const _ReverseReplayButton({
    required this.isShowing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(isShowing ? Icons.expand_less : Icons.expand_more),
        label: Text(isShowing ? '非表示' : 'リプレイを見る'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.grey.shade600,
        ),
      ),
    );
  }
}

/// Reverse replay visualization (board state)
class _ReverseReplayWidget extends StatelessWidget {
  final Board board;
  final List<String> playerIds;

  const _ReverseReplayWidget({
    required this.board,
    required this.playerIds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            '最終盤面',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final stone = board.getStone(row, col);

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black26,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: _buildStone(stone),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStone(int stone) {
    switch (stone) {
      case Board.black:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            shape: BoxShape.circle,
          ),
        );
      case Board.white:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 0.5),
          ),
        );
      case Board.red:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            shape: BoxShape.circle,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Share option tile
class _ShareOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ShareOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade400),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
