import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toriverse/features/match/application/providers/matching_state.dart';
import 'package:toriverse/features/match/application/providers/user_state.dart';

/// Home screen: main menu with matching, friend match, and shop buttons
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final userUid = ref.watch(userUidProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final rankPoints = ref.watch(rankPointsProvider);
    final streak = ref.watch(streakProvider);
    final hasFreeMatch = ref.watch(hasFreeMatchProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    if (!isLoggedIn) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UID: $userUid'),
                              const SizedBox(height: 4),
                              Text('ランクポイント: $rankPoints'),
                              const SizedBox(height: 4),
                              Text('連続完走: $streak'),
                            ],
                          ),
                          if (isSubscribed)
                            Chip(label: const Text('購読中'))
                          else
                            Chip(label: const Text('トライアル')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Free Match Status
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        hasFreeMatch ? Icons.check_circle : Icons.block,
                        color: hasFreeMatch ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'マッチング無料枠',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasFreeMatch
                                  ? '本日の無料マッチ: 利用可'
                                  : '本日の無料マッチ: 利用済み',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
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
                  onPressed: () => _startMatching(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'マッチング開始',
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
              const SizedBox(height: 24),

              // Settings & Logout
              Center(
                child: TextButton.icon(
                  onPressed: () => _logout(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('ログアウト'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatching(BuildContext context, WidgetRef ref) {
    final userUid = ref.read(userUidProvider);
    if (userUid != null) {
      ref.read(matchingStateProvider.notifier).startMatching(userUid);
      context.push('/matching');
    }
  }

  void _startFriendMatch(BuildContext context) {
    // TODO: Implement friend match UI
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('フレンド対戦は準備中です')),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(userStateProvider.notifier).logout();
    context.go('/login');
  }
}
