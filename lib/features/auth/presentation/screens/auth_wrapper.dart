import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/auth_provider.dart';

/// Authentication wrapper - routes to login or home based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isLoading = ref.watch(isAuthLoadingProvider);
    final error = ref.watch(authErrorProvider);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isAuthenticated) {
      // Redirect to home after build
      Future.microtask(() => context.go('/home'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                  const SizedBox(height: 16),
                  const Text(
                    '3色オセロで遊ぶ',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 48),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        error,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _handleGoogleSignIn(ref, context),
                    icon: const Icon(Icons.account_circle),
                    label: const Text('Googleでログイン'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _handleAppleSignIn(ref, context),
                    icon: const Icon(Icons.apple),
                    label: const Text('Appleでログイン'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(WidgetRef ref, BuildContext context) async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (context.mounted) {
      context.go('/home');
    }
  }

  Future<void> _handleAppleSignIn(WidgetRef ref, BuildContext context) async {
    await ref.read(authProvider.notifier).signInWithApple();
    if (context.mounted) {
      context.go('/home');
    }
  }
}
