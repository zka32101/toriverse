import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/config/theme.dart';
import 'package:toriverse/features/auth/application/providers/auth_provider.dart';
import 'package:toriverse/features/match/application/providers/ai_difficulty_provider.dart';
import 'package:toriverse/features/match/application/providers/ai_takeover_state.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';
import 'package:toriverse/features/match/application/providers/inactivity_provider.dart';
import 'package:toriverse/features/match/application/providers/remote_config_provider.dart';
import 'package:toriverse/features/match/application/providers/rescue_card_state.dart';
import 'package:toriverse/features/match/application/providers/rivalry_state.dart';
import 'package:toriverse/features/match/application/providers/round_resolution_provider.dart';
import 'package:toriverse/features/match/application/providers/round_submission_provider.dart';
import 'package:toriverse/features/match/application/services/move_applicator.dart';
import 'package:toriverse/features/match/application/services/firestore_round_result_service.dart';
import 'package:toriverse/features/match/data/models/round_result_model.dart';
import 'package:toriverse/features/match/domain/entities/board.dart';
import 'package:toriverse/features/match/domain/services/ai_player.dart';
import 'package:toriverse/features/match/domain/services/bonus_calculator.dart';
import 'package:toriverse/features/match/domain/services/rivalry_tracker.dart';
import 'package:toriverse/features/match/presentation/widgets/ai_takeover_indicator_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/animations/animations_barrel.dart';
import 'package:toriverse/features/match/presentation/widgets/animations/animation_overlay.dart';
import 'package:toriverse/features/match/presentation/widgets/board_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/move_submission_panel.dart';
import 'package:toriverse/features/match/presentation/widgets/rivalry_indicator_widget.dart';
import 'package:toriverse/features/match/presentation/widgets/simultaneous_reveal_widget.dart';
import 'package:toriverse/features/match/application/providers/animation_orchestrator_provider.dart';
import 'package:toriverse/features/match/application/services/animation_sequence_builder.dart';

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
  late String _currentPlayerId; // Human player ID
  RoundResolution? _currentResolution; // Store current round resolution

  @override
  void initState() {
    super.initState();

    // Initialize current player ID - will be updated in build
    _currentPlayerId = '';

    // Start first round and schedule AI moves sequentially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize bonus tracking for this match
      ref.read(bonusActivationProvider(widget.matchId));

      _startNewRoundAndSchedule();
    });
  }

  Future<void> _startNewRoundAndSchedule() async {
    await _startNewRound();

    // Only schedule AI moves after round is fully initialized
    if (mounted) {
      _scheduleAIMoves();
    }
  }

  Future<void> _startNewRound() async {
    final gameState = ref.read(gameStateProvider);
    if (gameState != null) {
      // Initialize rescue card tracking for first round only
      if (gameState.roundIndex == 0) {
        ref
            .read(rescueCardStateProvider(widget.matchId).notifier)
            .initializeMatch(
              widget.matchId,
              gameState.playerIds,
            );
      }

      // Fetch submission timeout from Remote Config
      try {
        final configResult = await ref.read(submissionTimeoutProvider.future);
        final timeoutMs = configResult;
        final timeout = Duration(milliseconds: timeoutMs);

        ref
            .read(roundSubmissionProvider.notifier)
            .startRound(
              roundIndex: gameState.roundIndex,
              playerIds: gameState.playerIds,
              timeout: timeout,
            );

        // Initialize round submission monitoring for AI takeover detection
        ref.read(roundSubmissionMonitorProvider.notifier).startMonitoring(
              playerIds: gameState.playerIds,
              submissionTimeoutMs: timeoutMs,
            );

        ref.read(roundPhaseProvider.notifier).setSelection();
        _clearSelection();
      } catch (e) {
        // Fallback to default timeout if Remote Config fetch fails
        const defaultTimeoutMs = 30000;
        ref
            .read(roundSubmissionProvider.notifier)
            .startRound(
              roundIndex: gameState.roundIndex,
              playerIds: gameState.playerIds,
              timeout: const Duration(milliseconds: defaultTimeoutMs),
            );

        ref.read(roundSubmissionMonitorProvider.notifier).startMonitoring(
              playerIds: gameState.playerIds,
              submissionTimeoutMs: defaultTimeoutMs,
            );

        ref.read(roundPhaseProvider.notifier).setSelection();
        _clearSelection();
      }
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

          // Skip if already submitted
          if (roundSubmission.submittedPositions[playerId] != null) {
            continue;
          }

          // Auto-submit AI player moves
          if (playerId == 'AI' || playerId.startsWith('AI_')) {
            final difficulty = ref.read(aiDifficultyProvider);
            final move = getAIMove(gameState.board, i, difficulty);

            if (move != null) {
              final position = move[0] * 8 + move[1];
              ref
                  .read(roundSubmissionProvider.notifier)
                  .submitMove(playerId, position);

              // Record submission for AI takeover timeout monitoring
              ref
                  .read(roundSubmissionMonitorProvider.notifier)
                  .recordSubmission(playerId);
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

    // Submit for current human player
    final position = _selectedRow! * 8 + _selectedCol!;
    ref.read(roundSubmissionProvider.notifier).submitMove(_currentPlayerId, position);

    // Record submission for timeout monitoring
    ref
        .read(roundSubmissionMonitorProvider.notifier)
        .recordSubmission(_currentPlayerId);

    ref.read(roundPhaseProvider.notifier).setWaiting();
    _clearSelection();

    // Check if round is complete
    _checkRoundCompletion();
  }

  void _checkRoundCompletion() {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);

    if (gameState == null || roundSubmission == null) return;

    // Check for submission timeouts and activate AI takeover if needed
    final monitor = ref.read(roundSubmissionMonitorProvider);
    if (monitor != null) {
      final timedOutPlayers = monitor.getTimedOutPlayers(gameState.playerIds);
      for (final playerId in timedOutPlayers) {
        ref.read(aiTakeoverProvider.notifier).activateTakeover(
          playerId: playerId,
          reason: 'timeout',
        );
      }
    }

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
    await _generateRoundResult();

    // The SimultaneousRevealWidget will now be displayed
  }

  Future<void> _generateRoundResult() async {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);
    final bonusState = ref.read(bonusActivationProvider(widget.matchId));

    if (gameState == null || roundSubmission == null || bonusState == null) {
      return;
    }

    try {
      // Get resolution service
      final resolutionService = ref.read(roundResolutionServiceProvider);

      // Convert bonus state to list format
      final bonusActivations = [
        bonusState.getActivationCount(gameState.playerIds[0]),
        bonusState.getActivationCount(gameState.playerIds[1]),
        bonusState.getActivationCount(gameState.playerIds[2]),
      ];

      // Filter submitted positions
      final validPositions = <String, int>{};
      for (final (playerId, pos)
          in roundSubmission.submittedPositions.entries) {
        if (pos != null) {
          validPositions[playerId] = pos;
        }
      }

      // Resolve the round using RoundResolutionService
      final resolution = await resolutionService.resolveRound(
        matchId: widget.matchId,
        roundIndex: roundSubmission.roundIndex,
        boardBefore: gameState.board,
        playerIds: gameState.playerIds,
        submittedPositions: validPositions,
        bonusActivationCounts: bonusActivations,
      );

      // Store result for animation
      ref.read(roundResultProvider.notifier).setResult(resolution.result);

      // Update bonus tracking if bonus was triggered
      if (resolution.result.bonusTriggered.isNotEmpty) {
        ref
            .read(bonusActivationProvider(widget.matchId).notifier)
            .recordActivation(
              resolution.result.bonusTriggered,
              roundSubmission.roundIndex,
            );
      }

      // Track rescue cards granted
      for (final playerId in resolution.result.rescueCardsGranted) {
        ref
            .read(rescueCardStateProvider(widget.matchId).notifier)
            .recordAttack(widget.matchId, playerId);
      }

      // Store resolution for next phase
      _currentResolution = resolution;
    } catch (e) {
      debugPrint('Error resolving round: $e');
      _handleGameError(e);
    }
  }

  void _applyRoundMoves() {
    // Launch async work without awaiting to maintain VoidCallback signature
    unawaited(_applyRoundMovesAsync());
  }

  Future<void> _applyRoundMovesAsync() async {
    final gameState = ref.read(gameStateProvider);
    final roundSubmission = ref.read(roundSubmissionProvider);
    final currentResolution = _currentResolution;

    if (gameState == null || roundSubmission == null || currentResolution == null) {
      return;
    }

    try {
      // Build and queue post-game animations (weak bonus, rescue card, collision)
      final animationSequence =
          AnimationSequenceBuilder.buildRoundSequence(
        result: currentResolution.result,
        playerNames: gameState.playerIds
            .map((id) => id == 'AI' || id.startsWith('AI_')
                ? 'AI'
                : id)
            .toList(),
        playerIndices: [0, 1, 2], // Standard 3-player indices
      );

      // Queue animations if any exist
      if (animationSequence.isNotEmpty) {
        ref
            .read(animationOrchestratorProvider(widget.matchId).notifier)
            .queueAnimations(animationSequence);

        // Wait for animations to complete
        await _waitForAnimationsComplete();
      }

      // Get the resolved board state
      final newBoard = currentResolution.boardAfter;

      // Update game state with new board
      final newCounts = newBoard.countStones();
      final newStoneCounts = {
        gameState.playerIds[0]: newCounts[Board.black] ?? 0,
        gameState.playerIds[1]: newCounts[Board.white] ?? 0,
        gameState.playerIds[2]: newCounts[Board.red] ?? 0,
      };

      // Save round result to Firestore
      final firestoreService =
          ref.read(firestoreRoundResultServiceProvider);
      final roundSaved = await firestoreService
          .saveRoundResultWithRetry(currentResolution.result);

      if (!roundSaved) {
        debugPrint(
          'Warning: Failed to save round result to Firestore '
          '(match: ${widget.matchId}, round: ${roundSubmission.roundIndex})',
        );
        // Continue anyway - game state is updated locally
      }

      // Update match state in Firestore
      await firestoreService.updateMatchStateAfterRound(
        matchId: widget.matchId,
        roundIndex: gameState.roundIndex + 1,
        status: currentResolution.isGameOver ? 'finished' : 'playing',
        stoneCounts: newStoneCounts,
        isGameOver: currentResolution.isGameOver,
      );

      // Clean up and prepare for next round
      ref.read(roundResultProvider.notifier).clear();

      if (currentResolution.isGameOver) {
        // Update game state to finished
        ref.read(gameStateProvider.notifier).updateGameState(
          board: newBoard,
          roundIndex: gameState.roundIndex + 1,
          status: GameStatus.finished,
          stoneCounts: newStoneCounts,
        );

        // Navigate to results screen
        if (mounted) {
          context.push('/results/${widget.matchId}');
        }
      } else {
        // Update game state to continue
        ref.read(gameStateProvider.notifier).updateGameState(
          board: newBoard,
          roundIndex: gameState.roundIndex + 1,
          status: GameStatus.playing,
          stoneCounts: newStoneCounts,
        );

        // Start next round
        ref.read(roundPhaseProvider.notifier).setFinished();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _startNewRound();
            _scheduleAIMoves();
          }
        });
      }
    } catch (e) {
      debugPrint('Error applying round moves: $e');
      _handleGameError(e);
    }
  }

  /// Wait for animation orchestrator to complete all queued animations
  ///
  /// Polls the orchestrator state until isPlaying becomes false.
  /// Returns immediately if no animations are queued.
  Future<void> _waitForAnimationsComplete() async {
    const maxWaitMs = 30000; // 30 second timeout
    const pollIntervalMs = 100; // Check every 100ms
    int elapsedMs = 0;

    while (elapsedMs < maxWaitMs) {
      final orchestratorState =
          ref.read(animationOrchestratorProvider(widget.matchId));

      // Done when not playing and queue is empty
      if (!orchestratorState.isPlaying &&
          orchestratorState.queue.isEmpty &&
          orchestratorState.currentAnimation == null) {
        return;
      }

      // Poll again after interval
      await Future.delayed(const Duration(milliseconds: pollIntervalMs));
      elapsedMs += pollIntervalMs;
    }

    // Timeout - log warning and continue
    debugPrint('Animation orchestrator timeout after ${maxWaitMs}ms');
  }

  void _handleGameError(Object error) {
    // Show error dialog to user
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラーが発生しました'),
          content: Text('ゲーム処理中にエラーが発生しました: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/home');
              },
              child: const Text('ホームに戻る'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final gameState = ref.watch(gameStateProvider);
    final roundPhase = ref.watch(roundPhaseProvider);
    final roundSubmission = ref.watch(roundSubmissionProvider);
    final roundResult = ref.watch(roundResultProvider);
    final timeRemaining = ref.watch(timeRemainingProvider);
    final rivalryState = ref.watch(rivalryProvider);
    final aiTakeoverState = ref.watch(aiTakeoverProvider);

    // Update current player ID from auth
    if (currentUserId != null && _currentPlayerId.isEmpty) {
      _currentPlayerId = currentUserId;
    }

    if (gameState == null || currentUserId == null) {
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
            // Main game board (hidden during reveal)
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

                  // Rivalry indicator (shows alliance/2v1 dynamics)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: RivalryIndicatorWidget(
                      rivalryScores: rivalryState.getAggregatedScores(),
                      playerIds: gameState.playerIds,
                      currentPlayerIndex: 0, // Human player (player 0)
                      showCounts: false,
                    ),
                  ),

                  // AI Takeover indicator (shows which players are AI-controlled)
                  if (aiTakeoverState.activeTakeovers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: AITakeoverIndicatorWidget(
                        aiControlledPlayers: aiTakeoverState.activeTakeovers
                            .map((playerId, info) =>
                                MapEntry(playerId, info['reason'] as String))
                            .cast<String, String>(),
                        playerIds: gameState.playerIds,
                      ),
                    ),

                  // Board
                  Expanded(
                    child: Center(
                      child: BoardWidget(
                        board: gameState.board,
                        validMoves: roundPhase == RoundPhase.selection
                            ? gameState.board.getValidMoves(0) // Show moves for player 0
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
                  if (roundPhase == RoundPhase.selection &&
                      roundSubmission != null)
                    timeRemaining.when(
                      data: (ms) => MoveSubmissionPanel(
                        currentPlayer: _currentPlayerId,
                        validMoveCount: gameState.board.getValidMoves(0).length,
                        onSubmit: _selectedRow != null && _selectedCol != null
                            ? _submitSelectedMove
                            : null,
                        timeRemaining: ms,
                        onTimeout: _checkRoundCompletion,
                      ),
                      loading: () => MoveSubmissionPanel(
                        currentPlayer: _currentPlayerId,
                        validMoveCount: 0,
                      ),
                      error: (_, __) => MoveSubmissionPanel(
                        currentPlayer: _currentPlayerId,
                        validMoveCount: 0,
                      ),
                    )
                  else if (roundPhase == RoundPhase.waiting &&
                      roundSubmission != null)
                    _WaitingPanel(
                      submittedCount: roundSubmission.submittedPositions.values
                          .where((v) => v != null)
                          .length,
                      totalPlayers: gameState.playerIds.length,
                    ),
                ],
              ),

            // Reveal animation overlay
            if (roundPhase == RoundPhase.revealing && roundResult != null)
              SimultaneousRevealWidget(
                events: roundResult.replayEvents,
                onComplete: _applyRoundMoves,
              ),

            // Post-game animation overlay (weak bonus, rescue card, collision, etc.)
            AnimationOverlay(
              matchId: widget.matchId,
              playerNames: gameState.playerIds
                  .map((id) => id == 'AI' || id.startsWith('AI_') ? 'AI' : id)
                  .toList(),
              playerIndices: [0, 1, 2],
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
  final int submittedCount;
  final int totalPlayers;

  const _WaitingPanel({
    required this.submittedCount,
    required this.totalPlayers,
  });

  @override
  Widget build(BuildContext context) {
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
            value: submittedCount / totalPlayers,
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Text(
            '$submittedCount / $totalPlayers',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
