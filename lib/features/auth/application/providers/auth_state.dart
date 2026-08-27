import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../match/application/providers/user_state.dart';
import 'package:uuid/uuid.dart';

/// Authentication state provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref);
});

/// Is user logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider);
});

/// Auth state notifier
class AuthStateNotifier extends StateNotifier<bool> {
  final StateNotifierProviderRef ref;

  AuthStateNotifier(this.ref) : super(false);

  /// Login as guest user
  Future<void> loginGuest() async {
    try {
      // Generate guest UID
      const uuid = Uuid();
      final guestUid = 'guest_${uuid.v4().split('-').first}';

      // Initialize user state
      ref.read(userStateProvider.notifier).initializeUser(
            guestUid,
            displayName: 'Guest Player',
          );

      state = true;
    } catch (e) {
      print('Guest login error: $e');
      state = false;
    }
  }

  /// Logout
  void logout() {
    ref.read(userStateProvider.notifier).logout();
    state = false;
  }
}
