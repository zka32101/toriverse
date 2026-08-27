import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home state - for any home-specific state management
final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>(
  (ref) => HomeStateNotifier(),
);

/// Home state model
class HomeState {
  final bool showNotificationPrompt;
  final int dailyLoginStreak;

  HomeState({
    this.showNotificationPrompt = true,
    this.dailyLoginStreak = 0,
  });

  HomeState copyWith({
    bool? showNotificationPrompt,
    int? dailyLoginStreak,
  }) {
    return HomeState(
      showNotificationPrompt: showNotificationPrompt ?? this.showNotificationPrompt,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
    );
  }
}

/// Home state notifier
class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier() : super(HomeState());

  void dismissNotificationPrompt() {
    state = state.copyWith(showNotificationPrompt: false);
  }

  void incrementDailyStreak() {
    state = state.copyWith(dailyLoginStreak: state.dailyLoginStreak + 1);
  }
}
