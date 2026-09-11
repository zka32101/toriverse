import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/match_model.dart';
import '../../data/repositories/match_repository.dart';
import 'game_state.dart';

/// Match initialization state
class MatchInitializationState {
  final String? matchId;
  final bool isLoading;
  final String? error;
  final List<String> players; // 3 player IDs (humans or "AI_<id>")

  MatchInitializationState({
    this.matchId,
    this.isLoading = false,
    this.error,
    this.players = const [],
  });

  MatchInitializationState copyWith({
    String? matchId,
    bool? isLoading,
    String? error,
    List<String>? players,
  }) {
    return MatchInitializationState(
      matchId: matchId ?? this.matchId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      players: players ?? this.players,
    );
  }
}

/// Notifier for match initialization
class MatchInitializationNotifier extends StateNotifier<MatchInitializationState> {
  final MatchRepository _matchRepository;
  final String _currentUserId;

  MatchInitializationNotifier({
    required MatchRepository matchRepository,
    required String currentUserId,
  })  : _matchRepository = matchRepository,
        _currentUserId = currentUserId,
        super(MatchInitializationState());

  /// Initialize a new match
  /// If fewer than 2 other human players are available, fills remaining seats with AI
  Future<void> initializeMatch({
    required List<String> humanPlayerIds, // 1-3 player IDs
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Ensure we have exactly 3 players (fill with AI if needed)
      final players = List<String>.from(humanPlayerIds);

      while (players.length < 3) {
        final aiId = 'AI_${const Uuid().v4()}';
        players.add(aiId);
      }

      // Shuffle player order for fairness
      players.shuffle();

      // Initialize 8x8 board with center 4 stones
      final boardState = List.filled(64, -1); // -1 = empty
      boardState[27] = 1; // white at (3,3)
      boardState[28] = 0; // black at (3,4)
      boardState[35] = 0; // black at (4,3)
      boardState[36] = 1; // white at (4,4)

      // Create match document
      final match = MatchModel(
        id: const Uuid().v4(),
        players: players,
        boardState: boardState,
        roundIndex: 0,
        status: 'waiting',
        currentPhase: 'submitPhase',
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final matchId = await _matchRepository.createMatch(match);

      state = state.copyWith(
        matchId: matchId,
        isLoading: false,
        players: players,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Initialize matchmaking (finding opponents)
  /// Returns when 3 players are ready or AI is substituted
  Future<void> startMatchmaking() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // For MVP: immediately start match with current user + AI opponents
      // In Phase 2: this would implement real matchmaking queue
      await initializeMatch(humanPlayerIds: [_currentUserId]);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel matchmaking
  void cancelMatchmaking() {
    state = MatchInitializationState();
  }

  /// Mark match as started (transition to playing)
  Future<void> markMatchStarted(String matchId) async {
    try {
      await _matchRepository.markMatchStarted(matchId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Match initialization provider
final matchInitializationProvider = StateNotifierProvider.family<
    MatchInitializationNotifier,
    MatchInitializationState,
    String>((ref, userId) {
  return MatchInitializationNotifier(
    matchRepository: MatchRepository(),
    currentUserId: userId,
  );
});

/// Computed provider: is match ready to play
final isMatchReadyProvider = Provider.family<bool, String>((ref, userId) {
  final state = ref.watch(matchInitializationProvider(userId));
  return state.matchId != null && !state.isLoading;
});

/// Computed provider: current match ID
final currentMatchIdProvider = Provider.family<String?, String>((ref, userId) {
  return ref.watch(matchInitializationProvider(userId)).matchId;
});

/// Computed provider: is matchmaking in progress
final isMatchmakingProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(matchInitializationProvider(userId)).isLoading;
});
