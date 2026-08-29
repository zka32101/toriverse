import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/round_submission_provider.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/domain/services/ai_player.dart';
import 'package:toriverse/features/match/domain/services/bonus_calculator.dart';
import 'package:toriverse/features/match/presentation/widgets/board_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/move_submission_panel.dart';
import 'package:toriverse/features/match/presentation/widgets/simultaneous_reveal_widget.dart';

/// Match/Board screen: displays the 3-color Othello board and handles simultaneous moves
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
  int? _selectedRow;
  int? _selectedCol;

  @override
  void initState() {
    super.initState();
    // Start first round submission
    _startNewRound();
  }

  void _startNewRound() {
    final gameState = ref.read(gameStateProvider);
    if (gameState != null) {
      ref.read(roundSubmissionProvider.notifier).startRound(
            roundIndex: gameState.roundIndex,
            playerIds: gameState.playerIds,
          );
      ref.read(roundPhaseProvider.notifier).setSelection();
      _clearSelection();

      // Auto-submit AI moves after a short delay
      _scheduleAIMoves();
    }
  }

  void _scheduleAIMoves() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final gameState = ref.read(gameStateProvider);
      final roundSubmission = ref.read(roundSubmissionProvider);

      if (gameState != null && roundSubmission != null) {
        for (int i = 0; i < gameState.playerIds.length; i++) {
          final playerId = gameState.playerIds[i];

          // Auto-submit AI player moves
          if (playerId == 'AI' || playerId.startsWith('AI_')) {
            final validMoves = gameState.board.getValidMoves(i);
            if (validMoves.isNotEmpty) {
              // Use simple greedy move selection for AI
              final move = validMoves.first;
              ref.read(roundSubmissionProvider.notifier)
                  .submitMove(playerId, move[0] * 8 + move[1]);
            }
          }
        }

        // Check if we should auto-advance to next phase
        _checkRoundCompletion();
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedRow = null;
      _selectedCol = null;
    });
  }

  void _selectMove(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _submitSelectedMove() {
    final gameState = ref.read(gameStateProvider);
    if (gameState == null || _selectedRow == null || _selectedCol == null) return;

    final roundSubmission = ref.read(roundSubmissionProvider);
    if (roundSubmission == null) return;

    // Find current player (for non-simultaneous context; in simultaneous mode,
    // submit as current user)
    const playerId = 'player_0'; // TODO: Get from user context
    final position = _selectedRow! * 8 + _selectedCol!;

    ref.read(roundSubmissionProvider.notifier).submitMove(playerId, position);

    ref.read(roundPhaseProvider.notifier).setWaiting();
    _clearSelection();

    // Check if round is complete
    _checkRoundCompletion();
  }

  void _checkRoundCompletion() {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);

    if (gameState == null || roundSubmission == null) return;

    // Check if all players submitted or timeout
    if (roundSubmission.isAllSubmitted(gameState.playerIds) ||
        roundSubmission.isTimedOut()) {
      _proceedToReveal();
    }
  }

  void _proceedToReveal() async {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);

    if (gameState == null || roundSubmission == null) return;

    ref.read(roundPhaseProvider.notifier).setRevealing();

    // Generate round result with animations
    final roundResult = _generateRoundResult(gameState, roundSubmission);
    ref.read(roundResultProvider.notifier).setResult(roundResult);

    // Show reveal animation, then apply moves
    // The SimultaneousRevealWidget will handle the animation display
  }

  RoundResultModel _generateRoundResult(
    GameState gameState,
    RoundSubmissionState roundSubmission,
  ) {
    // Randomize processing order
    final processOrder = ProcessOrderRandomizer.randomizeOrder(gameState.playerIds);

    // Prepare move results for animation sequence
    final moveResults = <String, Map<String, dynamic>>{};
    for (final playerId in gameState.playerIds) {
      final position = roundSubmission.submittedPositions[playerId];
      if (position != null) {
        final row = position ~/ 8;
        final col = position % 8;
        moveResults[playerId] = {
          'position': position,
          'row': row,
          'col': col,
        };
      }
    }

    // Generate animation sequence
    final sequence = ProcessOrderRandomizer.generateAnimationSequence(
      processOrder: processOrder,
      moveResults: moveResults,
    );

    final replayEvents = ProcessOrderRandomizer.toReplayEvents(sequence);

    return RoundResultModel(
      id: '${widget.matchId}_${roundSubmission.roundIndex}',
      matchId: widget.matchId,
      roundIndex: roundSubmission.roundIndex,
      submittedMoves: [
        for (final playerId in gameState.playerIds)
          if (roundSubmission.submittedPositions[playerId] != null)
            SubmittedMove(
              playerId: playerId,
              position: roundSubmission.submittedPositions[playerId]!,
              submittedAt: DateTime.now(),
            ),
      ],
      processOrder: processOrder,
      replayEvents: replayEvents,
      createdAt: DateTime.now(),
    );
  }

  void _applyRoundMoves() async {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);

    if (gameState == null || roundSubmission == null) return;

    // Apply moves to board in process order
    var newBoard = gameState.board.clone();
    final roundResult = ref.read(roundResultProvider);

    if (roundResult != null) {
      for (final playerId in roundResult.processOrder) {
        final move = roundSubmission.submittedPositions[playerId];
        if (move != null) {
          final row = move ~/ 8;
          final col = move % 8;
          final playerIndex = gameState.playerIds.indexOf(playerId);

          // Only apply if move is valid
          if (newBoard.getValidMoves(playerIndex)
              .any((m) => m[0] == row && m[1] == col)) {
            newBoard.placeStone(row, col, playerIndex);
          }
        }
      }
    }

    // Update game state with new board
    final newCounts = newBoard.countStones();
    final newStoneCounts = {
      gameState.playerIds[0]: newCounts[Board.black] ?? 0,
      gameState.playerIds[1]: newCounts[Board.white] ?? 0,
      gameState.playerIds[2]: newCounts[Board.red] ?? 0,
    };

    // Check if game is over
    bool anyHasMove = false;
    for (int i = 0; i < 3; i++) {
      if (newBoard.getValidMoves(i).isNotEmpty) {
        anyHasMove = true;
        break;
      }
    }

    final newStatus =
        anyHasMove ? GameStatus.playing : GameStatus.finished;

    ref.read(gameStateProvider.notifier).updateGameState(
      board: newBoard,
      roundIndex: gameState.roundIndex + 1,
      status: newStatus,
      stoneCounts: newStoneCounts,
    );

    // Clean up and prepare for next round
    ref.read(roundResultProvider.notifier).clear();

    if (newStatus == GameStatus.finished) {
      // Navigate to results screen
      if (mounted) {
        context.push('/results/${widget.matchId}');
      }
    } else {
      // Start next round
      ref.read(roundPhaseProvider.notifier).setFinished();

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _startNewRound();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final roundPhase = ref.watch(roundPhaseProvider);
    final roundSubmission = ref.watch(roundSubmissionProvider);
    final roundResult = ref.watch(roundResultProvider);

    if (gameState == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('マッチ')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('トリバース対局'),
        leading: BackButton(
          onPressed: () => _confirmQuit(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main game board
            if (roundPhase != RoundPhase.revealing)
              Column(
                children: [
                  // Round info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ラウンド: ${gameState.roundIndex}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Chip(
                          label: Text(roundPhase.toString().split('.').last),
                          backgroundColor: _getPhaseColor(roundPhase),
                        ),
                      ],
                    ),
                  ),

                  // Board
                  Expanded(
                    child: Center(
                      child: BoardWidget(
                        board: gameState.board,
                        validMoves: roundPhase == RoundPhase.selection
                            ? gameState.validMoves
                            : [],
                        onMoveTapped: roundPhase == RoundPhase.selection
                            ? (row, col) {
                                _selectMove(row, col);
                              }
                            : null,
                        selectedRow: _selectedRow,
                        selectedCol: _selectedCol,
                      ),
                    ),
                  ),

                  // Submission UI
                  if (roundPhase == RoundPhase.selection && roundSubmission != null)
                    MoveSubmissionPanel(
                      currentPlayer: 'player_0',
                      validMoveCount: gameState.validMoves.length,
                      onSubmit: _selectedRow != null && _selectedCol != null
                          ? _submitSelectedMove
                          : null,
                      timeRemaining: roundSubmission.msRemaining,
                      onTimeout: _checkRoundCompletion,
                    )
                  else if (roundPhase == RoundPhase.waiting)
                    _WaitingPanel(
                      roundSubmission: roundSubmission,
                      playerIds: gameState.playerIds,
                    ),
                ],
              ),

            // Reveal animation overlay
            if (roundPhase == RoundPhase.revealing && roundResult != null)
              SimultaneousRevealWidget(
                events: roundResult.replayEvents,
                onComplete: _applyRoundMoves,
              ),
          ],
        ),
      ),
    );
  }

  Color _getPhaseColor(RoundPhase phase) {
    switch (phase) {
      case RoundPhase.selection:
        return Colors.blue;
      case RoundPhase.waiting:
        return Colors.orange;
      case RoundPhase.revealing:
        return Colors.purple;
      case RoundPhase.finished:
        return Colors.green;
    }
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
}

/// Waiting for other players panel
class _WaitingPanel extends StatelessWidget {
  final RoundSubmissionState? roundSubmission;
  final List<String> playerIds;

  const _WaitingPanel({
    required this.roundSubmission,
    required this.playerIds,
  });

  @override
  Widget build(BuildContext context) {
    final submitted = roundSubmission?.submittedPositions
            .values
            .where((v) => v != null)
            .length ??
        0;

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'すべてのプレイヤーの提出を待機中...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: submitted / playerIds.length,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$submitted / ${playerIds.length}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

extension on GameState {
  /// Get valid moves for the "current" player
  /// In simultaneous mode, this doesn't represent turn order,
  /// just available moves for selection
  List<List<int>> get validMoves {
    // For now, show moves for first human player (player_0)
    return board.getValidMoves(0);
  }
}
