import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/presentation/widgets/board_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/move_submission_panel.dart';

/// Match/Board screen: displays the 3-color Othello board and handles moves
class MatchScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  @override
  void initState() {
    super.initState();
    // Start AI moves if applicable
    _checkForAIMove();
  }

  void _checkForAIMove() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(gameStateProvider.notifier).executeAIMove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final isGameOver = ref.watch(isGameOverProvider);
    final currentPlayer = ref.watch(currentPlayerProvider);
    final roundIndex = ref.watch(roundIndexProvider);
    final validMoves = ref.watch(validMovesProvider);

    if (gameState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('マッチ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/results/${widget.matchId}');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('トリバース対局'),
        leading: BackButton(
          onPressed: () => _confirmQuit(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Round counter and player info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ラウンド: $roundIndex',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text('現在: $currentPlayer'),
                    backgroundColor: _getPlayerColor(gameState.currentPlayerIndex),
                  ),
                ],
              ),
            ),

            // Board
            Expanded(
              child: Center(
                child: BoardWidget(
                  board: gameState.board,
                  validMoves: validMoves,
                  onMoveTapped: (row, col) {
                    ref.read(gameStateProvider.notifier).placeStone(row, col);
                    _checkForAIMove();
                  },
                ),
              ),
            ),

            // Move submission panel
            MoveSubmissionPanel(
              currentPlayer: currentPlayer ?? '',
              validMoveCount: validMoves.length,
              onSubmit: () {
                // Auto-submit when all players are ready
                // This is handled by the server in async mode
              },
            ),

            // Pause button
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(gameStateProvider.notifier).pauseGame();
                },
                icon: const Icon(Icons.pause),
                label: const Text('一時停止'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('マッチを終了しますか？'),
        content: const Text(
          'マッチを終了すると、AIが自動的に引き継ぎます。'
          'あなたにペナルティはありません。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).resetGame();
              Navigator.pop(context);
              context.go('/home');
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  Color _getPlayerColor(int playerIndex) {
    switch (playerIndex) {
      case 0:
        return Colors.grey.shade900; // black
      case 1:
        return Colors.white; // white
      case 2:
        return Colors.red.shade600; // red
      default:
        return Colors.grey;
    }
  }
}
