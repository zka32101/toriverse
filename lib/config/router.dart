import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/screens/auth_wrapper.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/match/presentation/screens/match_screen.dart';
import '../features/results/presentation/screens/results_screen.dart';

/// GoRouter configuration for Toriverse
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/match/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return MatchScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/results/:matchId',
        builder: (context, state) {
          final matchId = state.pathParameters['matchId'] ?? '';
          return ResultsScreen(matchId: matchId);
        },
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('ページが見つかりません'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('ホームに戻る'),
              ),
            ],
          ),
        ),
      );
    },
  );
});
