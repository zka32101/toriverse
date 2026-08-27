import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../match/presentation/widgets/board_widget.dart';
import '../../../match/application/providers/match_providers.dart';
import '../../application/providers/spectator_providers.dart';
import '../widgets/spectator_info_card.dart';
import '../widgets/spectator_list_widget.dart';

/// Screen for spectating an active match in real-time
///
/// Displays:
/// - Read-only board state (auto-updating)
/// - Player information (names, scores, status)
/// - Real-time spectator count
/// - Optional: Spectator list
/// - Share/chat buttons (Phase 2b+)
class SpectatorViewScreen extends ConsumerWidget {
  final String matchId;

  const SpectatorViewScreen({
    Key? key,
    required this.matchId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch match state
    final matchAsync = ref.watch(firebaseMatchStreamProvider(matchId));

    // Watch spectators for this match
    final spectatorsAsync = ref.watch(matchSpectatorsProvider(matchId));

    // Watch spectator count
    final countAsync = ref.watch(matchSpectatorCountProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spectating'),
        elevation: 0,
        actions: [
          // Spectator count badge
          countAsync.when(
            data: (count) => Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Chip(
                  label: Text(
                    '👁️ $count watching',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: matchAsync.when(
        data: (match) => SingleChildScrollView(
          child: Column(
            children: [
              // Read-only board display
              Padding(
                padding: const EdgeInsets.all(16),
                child: BoardWidget(
                  boardState: match.boardState,
                  onStonePressed: null, // Null = read-only (spectator mode)
                ),
              ),

              // Player info row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 3; i++)
                      SpectatorInfoCard(
                        playerIndex: i,
                        match: match,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Game progress section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🎮 Round ${match.roundIndex + 1}/10',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (match.status == MatchStatus.playing)
                              Text(
                                '⏱️ Move submitted',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.green,
                                    ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _shareMatch(context, matchId),
                        icon: const Icon(Icons.share),
                        label: const Text('Share Match'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Chat button (Phase 2b+)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showChatComingSoon(context),
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('Chat'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Spectator list (expandable)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpansionTile(
                  title: const Text('Spectators'),
                  children: [
                    spectatorsAsync.when(
                      data: (spectators) => SpectatorListWidget(
                        spectators: spectators,
                      ),
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Error: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 16),
                Text('Error loading match: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareMatch(BuildContext context, String matchId) {
    // TODO: Implement share functionality
    // Use Share plugin to share match URL
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _showChatComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Coming Soon'),
        content: const Text(
          'Live spectator chat will be available in Phase 2b.\n\n'
          'For now, enjoy watching the match!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// TODO: Import Match model when available
// For now, using placeholder status
enum MatchStatus {
  waiting,
  playing,
  finished,
}
