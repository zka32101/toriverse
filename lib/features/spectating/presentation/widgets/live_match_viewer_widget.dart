import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/spectating/application/providers/live_match_providers.dart';
import 'package:toriverse/features/spectating/domain/models/live_match.dart';

/// Main widget for watching live matches in real-time
///
/// Displays board, viewers count, current state, and provides
/// access to chat, predictions, and highlights.
class LiveMatchViewerWidget extends ConsumerStatefulWidget {
  final String matchId;
  final String viewerId;
  final String displayName;

  const LiveMatchViewerWidget({
    required this.matchId,
    required this.viewerId,
    required this.displayName,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<LiveMatchViewerWidget> createState() =>
      _LiveMatchViewerWidgetState();
}

class _LiveMatchViewerWidgetState extends ConsumerState<LiveMatchViewerWidget> {
  int commentsPosted = 0;
  int predictionsPlaced = 0;
  int correctPredictions = 0;
  int reactionsGiven = 0;
  bool showChat = false;
  bool showPredictions = false;
  bool showLeaderboard = false;
  bool showHighlights = false;

  @override
  void initState() {
    super.initState();
    _joinMatch();
  }

  void _joinMatch() {
    ref.read(joinLiveMatchProvider((
      widget.matchId,
      widget.viewerId,
      widget.displayName,
    )).future).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined live match')),
        );
      }
    }).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error joining match: $e')),
        );
      }
    });
  }

  @override
  void dispose() {
    _leaveMatch();
    super.dispose();
  }

  void _leaveMatch() {
    ref.read(leaveLiveMatchProvider((
      widget.matchId,
      widget.viewerId,
    )).future);
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(watchLiveMatchSessionProvider(widget.matchId));
    final boardAsync = ref.watch(watchLiveBoardStateProvider(widget.matchId));
    final statsAsync = ref.watch(watchLiveMatchStatsProvider(widget.matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Match'),
        elevation: 0,
        actions: [
          sessionAsync.when(
            data: (session) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '👥 ${session.liveViewerCount} watching',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const Text('—'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Board section
              Padding(
                padding: const EdgeInsets.all(16),
                child: boardAsync.when(
                  data: (board) => _buildBoardSection(board, sessionAsync),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (err, _) => Center(
                    child: Text('Error loading board: $err'),
                  ),
                ),
              ),

              // Live stats section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: statsAsync.when(
                  data: (stats) => _buildStatsSection(stats),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 16),

              // Quick action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildQuickActions(),
              ),

              const SizedBox(height: 24),

              // Content sections (chat, predictions, leaderboard, highlights)
              if (showChat)
                _buildChatSection()
              else if (showPredictions)
                _buildPredictionsSection()
              else if (showLeaderboard)
                _buildLeaderboardSection()
              else if (showHighlights)
                _buildHighlightsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardSection(
    LiveBoardState board,
    AsyncValue<LiveMatchSession> sessionAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Board',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // Simplified board display (3x3 color indicator for demo)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!, width: 2),
          ),
          child: Column(
            children: [
              // Board state visualization
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 1,
                ),
                itemCount: board.boardState.length,
                itemBuilder: (context, index) {
                  final state = board.boardState[index];
                  Color cellColor;
                  switch (state) {
                    case 0: // Empty
                      cellColor = Colors.green[700]!;
                    case 1: // Black
                      cellColor = Colors.black87;
                    case 2: // White
                      cellColor = Colors.white;
                    case 3: // Red
                      cellColor = Colors.red[600]!;
                    default:
                      cellColor = Colors.grey[700]!;
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      border: Border.all(
                        color: index == board.lastMovePosition
                            ? Colors.yellow
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: state > 0
                        ? Center(
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state == 1
                                    ? Colors.black
                                    : state == 2
                                        ? Colors.white
                                        : Colors.red,
                              ),
                              border: Border.all(
                                color: Colors.grey[400]!,
                                width: 0.5,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Scores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildScoreCard('Black', board.blackScore, Colors.black87),
                  _buildScoreCard('White', board.whiteScore, Colors.white),
                  _buildScoreCard('Red', board.redScore, Colors.red[600]!),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Simultaneous reveal indicator
        if (board.isSimultaneousReveal)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[300]!),
            ),
            child: Text(
              '⏱️ Simultaneous reveal in progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.amber[900],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScoreCard(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(LiveMatchStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatChip(
          '💬 ${stats.totalChatMessages}',
          'Messages',
        ),
        _buildStatChip(
          '🎯 ${stats.correctPredictions}/${stats.totalPredictions}',
          'Predictions',
        ),
        _buildStatChip(
          '⭐ ${stats.avgPredictionAccuracy.toStringAsFixed(0)}%',
          'Accuracy',
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildActionButton(
          '💬 Chat',
          showChat,
          () {
            setState(() {
              showChat = !showChat;
              showPredictions = false;
              showLeaderboard = false;
              showHighlights = false;
            });
          },
        ),
        _buildActionButton(
          '🎯 Predict',
          showPredictions,
          () {
            setState(() {
              showPredictions = !showPredictions;
              showChat = false;
              showLeaderboard = false;
              showHighlights = false;
            });
          },
        ),
        _buildActionButton(
          '🏆 Ranking',
          showLeaderboard,
          () {
            setState(() {
              showLeaderboard = !showLeaderboard;
              showChat = false;
              showPredictions = false;
              showHighlights = false;
            });
          },
        ),
        _buildActionButton(
          '✨ Moments',
          showHighlights,
          () {
            setState(() {
              showHighlights = !showHighlights;
              showChat = false;
              showPredictions = false;
              showLeaderboard = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, bool isActive, VoidCallback onTap) {
    return Material(
      color: isActive ? Colors.blue[600] : Colors.grey[800],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Chat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ref.watch(watchLiveChatProvider(widget.matchId)).when(
            data: (messages) => messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No messages yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: messages
                        .take(10)
                        .map((msg) => _buildChatMessage(msg))
                        .toList(),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 12),
          // Message input
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[700]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  maxLines: 1,
                  onSubmitted: (message) {
                    if (message.isNotEmpty) {
                      ref.read(sendChatMessageProvider((
                        widget.matchId,
                        widget.viewerId,
                        widget.displayName,
                        message,
                        false,
                      )).future);
                      setState(() {
                        commentsPosted++;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showChat = false;
                  });
                },
                child: const Text('Close'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(LiveChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: msg.isModerator ? Colors.blue[400] : Colors.grey[300],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  msg.message,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '❤️ ${msg.likes}',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Make a Prediction',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPredictionOption(
            'Winner',
            'Who will win this match?',
            ['Black', 'White', 'Red'],
          ),
          const SizedBox(height: 12),
          _buildPredictionOption(
            'Next Move',
            'Which position next move?',
            ['1-10', '11-20', '21-30', '31-40', '41-50', '51-60', '61-64'],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showPredictions = false;
              });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionOption(String title, String subtitle, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: options
              .map((option) => ActionChip(
                    label: Text(
                      option,
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () {
                      ref.read(placePredictionProvider((
                        widget.matchId,
                        widget.viewerId,
                        title.toLowerCase(),
                        option,
                        75,
                      )).future);
                      setState(() {
                        predictionsPlaced++;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Prediction recorded!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Leaderboard',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ref.watch(watchLiveLeaderboardProvider(widget.matchId)).when(
            data: (entries) => entries.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No entries yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: entries
                        .take(10)
                        .asMap()
                        .entries
                        .map((entry) =>
                            _buildLeaderboardEntry(entry.key + 1, entry.value))
                        .toList(),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showLeaderboard = false;
              });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardEntry(int rank, LiveLeaderboardEntry entry) {
    final badges = ['🥇', '🥈', '🥉'];
    final badge = rank <= 3 ? badges[rank - 1] : '#$rank';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              badge,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '🎯 ${entry.correctPredictions} correct',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.pointsEarned} pts',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Highlight Moments',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ref.watch(watchHighlightsProvider(widget.matchId)).when(
            data: (highlights) => highlights.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No highlights yet',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: highlights
                        .map((h) => _buildHighlightCard(h))
                        .toList(),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showHighlights = false;
              });
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(MatchHighlightMoment highlight) {
    final icons = {
      'upset': '🔄',
      'strategic_move': '♟️',
      'key_turn': '🎯',
      'final_reversal': '💥',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: highlight.isFeatured ? Colors.amber[900] : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: highlight.isFeatured ? Colors.amber[600]! : Colors.grey[700]!,
          ),
        ),
        child: Row(
          children: [
            Text(
              icons[highlight.momentType] ?? '✨',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    highlight.description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${highlight.timestamp ~/ 60}:${(highlight.timestamp % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '❤️ ${highlight.viewerReactions}',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
