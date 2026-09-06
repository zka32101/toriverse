import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../models/auth_user_model.dart';

/// Authentication state
class AuthState {
  final User? firebaseUser;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState({
    this.firebaseUser,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? firebaseUser,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Get current user ID
  String? get uid => firebaseUser?.uid;

  /// Get current user email
  String? get email => firebaseUser?.email;

  /// Get current user display name
  String? get displayName => firebaseUser?.displayName;
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState());

  /// Initialize auth state (check if user is already logged in)
  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true);

    final user = _authRepository.currentUser;
    if (user != null) {
      state = AuthState(
        firebaseUser: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } else {
      state = AuthState(isLoading: false);
    }

    // Listen to auth state changes
    _authRepository.authStateChanges().listen((user) {
      state = AuthState(
        firebaseUser: user,
        isAuthenticated: user != null,
        isLoading: false,
      );
    });
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (user != null) {
        state = AuthState(
          firebaseUser: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create account',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (user != null) {
        state = AuthState(
          firebaseUser: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to sign in',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.signInWithGoogle();

      if (user != null) {
        state = AuthState(
          firebaseUser: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to sign in with Google',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepository.signInWithApple();

      if (user != null) {
        state = AuthState(
          firebaseUser: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to sign in with Apple',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepository();
  final notifier = AuthNotifier(authRepository: authRepository);
  notifier.initializeAuth();
  return notifier;
});

/// Computed provider: is user authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Computed provider: current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).uid;
});

/// Computed provider: current user display name
final currentUserDisplayNameProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).displayName;
});

/// Computed provider: is auth loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Computed provider: auth error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
