import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/features/auth/application/providers/auth_provider.dart';
import 'package:toriverse/features/match/application/providers/match_initialization_state.dart';

/// Home screen: main menu with matching, friend match, and shop buttons
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final displayName = ref.watch(currentUserDisplayNameProvider);
    final isMatchmaking = ref.watch(isMatchmakingProvider(currentUserId ?? ''));

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('トリバース')),
        body: const Center(
          child: Text('ログインしてください'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('トリバース'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ?? 'プレイヤー',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'UID: $currentUserId',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '連続完走: 0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Main Action Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isMatchmaking ? null : () => _startMatching(context, ref, currentUserId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    isMatchmaking ? 'マッチング中...' : 'マッチング開始',
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _startFriendMatch(context),
                  child: const Text('フレンド対戦'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.push('/shop'),
                  child: const Text('ショップ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatching(BuildContext context, WidgetRef ref, String userId) async {
    await ref.read(matchInitializationProvider(userId).notifier).startMatchmaking();

    // Watch for match ready
    ref.listen(
      isMatchReadyProvider(userId),
      (previous, next) {
        if (next && context.mounted) {
          final matchId = ref.read(currentMatchIdProvider(userId));
          if (matchId != null) {
            context.push('/match/$matchId');
          }
        }
      },
    );
  }

  void _startFriendMatch(BuildContext context) {
    // TODO: Implement friend match UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('フレンド対戦は準備中です')),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).signOut();
    context.go('/');
  }
}
