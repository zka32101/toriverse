import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';

/// Animation event types
enum AnimationEventType {
  weakBonus,
  rescueCard,
  collision,
  lottery,
  flip,
}

/// Animation state for orchestrating sequences
class AnimationOrchestratorState {
  final List<QueuedAnimation> queue;
  final QueuedAnimation? currentAnimation;
  final bool isPlaying;

  AnimationOrchestratorState({
    required this.queue,
    this.currentAnimation,
    this.isPlaying = false,
  });

  AnimationOrchestratorState copyWith({
    List<QueuedAnimation>? queue,
    QueuedAnimation? currentAnimation,
    bool? isPlaying,
  }) {
    return AnimationOrchestratorState(
      queue: queue ?? this.queue,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }
}

/// Queued animation entry
class QueuedAnimation {
  final String id; // Unique identifier
  final AnimationEventType type;
  final Map<String, dynamic> data;
  final int durationMs;
  final VoidCallback? onComplete;

  QueuedAnimation({
    required this.id,
    required this.type,
    required this.data,
    required this.durationMs,
    this.onComplete,
  });
}

/// Notifier for animation orchestration
class AnimationOrchestratorNotifier
    extends StateNotifier<AnimationOrchestratorState> {
  AnimationOrchestratorNotifier()
      : super(
          AnimationOrchestratorState(
            queue: [],
            currentAnimation: null,
            isPlaying: false,
          ),
        );

  /// Queue an animation for playback
  void queueAnimation(QueuedAnimation animation) {
    state = state.copyWith(
      queue: [...state.queue, animation],
    );
    _processQueue();
  }

  /// Queue multiple animations in sequence
  void queueAnimations(List<QueuedAnimation> animations) {
    state = state.copyWith(
      queue: [...state.queue, ...animations],
    );
    _processQueue();
  }

  /// Clear all queued animations
  void clearQueue() {
    state = state.copyWith(
      queue: [],
      currentAnimation: null,
      isPlaying: false,
    );
  }

  /// Process the animation queue
  Future<void> _processQueue() async {
    if (state.isPlaying || state.queue.isEmpty) {
      return;
    }

    // Get the first animation in queue
    final animation = state.queue.first;
    final remainingQueue = state.queue.skip(1).toList();

    // Update state to show current animation
    state = state.copyWith(
      currentAnimation: animation,
      queue: remainingQueue,
      isPlaying: true,
    );

    // Wait for animation duration
    await Future.delayed(Duration(milliseconds: animation.durationMs));

    // Call completion callback if provided
    animation.onComplete?.call();

    // Update state and continue with next animation
    state = state.copyWith(
      currentAnimation: null,
      isPlaying: false,
    );

    // Process next animation if available
    if (state.queue.isNotEmpty) {
      _processQueue();
    }
  }
}

/// Provider for animation orchestrator (per-match)
final animationOrchestratorProvider =
    StateNotifierProvider.family<AnimationOrchestratorNotifier,
        AnimationOrchestratorState, String>((ref, matchId) {
  return AnimationOrchestratorNotifier();
});
