import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_state.dart';
import '../../../home/presentation/screens/home_screen.dart';

/// Authentication wrapper - routes to login or home based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (isLoggedIn) {
      // Redirect to home after build
      Future.microtask(() => context.go('/home'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'トリバース',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              '3色オセロで遊ぶ',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => _handleLogin(ref, context),
              icon: const Icon(Icons.account_circle),
              label: const Text('ゲストでログイン'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(WidgetRef ref, BuildContext context) async {
    // Mock login - in production use Firebase Auth
    ref.read(authStateProvider.notifier).loginGuest();
    if (context.mounted) {
      context.go('/home');
    }
  }
}
