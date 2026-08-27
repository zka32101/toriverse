import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/features/match/application/providers/matching_state.dart';
import 'package:toriverse/features/match/application/providers/game_state.dart';

/// Matching screen: waiting for 3 players or AI completion
class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  @override
  Widget build(BuildContext context) {
    final matchingState = ref.watch(matchingStateProvider);
    final isMatched = ref.watch(isMatchedProvider);
    final isSearching = ref.watch(isSearchingProvider);
    final matchedPlayers = ref.watch(matchedPlayersProvider);

    // Navigate to match when matched
    if (isMatched && matchingState.matchId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Initialize game with matched players
        ref
            .read(gameStateProvider.notifier)
            .startGame(playerIds: matchedPlayers);
        context.push('/match/${matchingState.matchId}');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('マッチング中'),
        leading: BackButton(
          onPressed: () {
            ref.read(matchingStateProvider.notifier).cancelMatching();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated searching indicator
              if (isSearching)
                Column(
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(strokeWidth: 4),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'プレイヤーを探索中...',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),

              // Player count display
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '${matchingState.playersWaiting}人/3人',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'プレイヤーが集まるのを待機中...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Player list
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'マッチ参加予定プレイヤー',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ...matchedPlayers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final playerId = entry.value;
                      final isAI = playerId.startsWith('AI');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              isAI ? Icons.android : Icons.person,
                              color: isAI ? Colors.blue : Colors.green,
                            ),
                            const SizedBox(width: 12),
                            Text(playerId),
                            if (isAI)
                              Chip(
                                label: const Text('AI'),
                                visualDensity: VisualDensity.compact,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Cancel button
              const SizedBox(height: 32),
              if (matchingState.status.name == 'timeout')
                Column(
                  children: [
                    Text(
                      'マッチング超時間 (30秒)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                )
              else if (matchingState.status.name == 'error')
                Column(
                  children: [
                    Text(
                      'エラー: ${matchingState.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text('ホームに戻る'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
