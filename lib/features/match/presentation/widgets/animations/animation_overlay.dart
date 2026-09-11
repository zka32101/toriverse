import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../config/theme.dart';
import '../../application/providers/animation_orchestrator_provider.dart';
import 'animations_barrel.dart';

/// Animation Overlay Widget
///
/// Full-screen overlay for displaying queued animations sequentially.
/// Watches the AnimationOrchestratorNotifier and renders the current animation
/// (if any) as a full-screen Material overlay.
///
/// Animations displayed:
/// - Weak Bonus (弱者ボーナス)
/// - Rescue Card (救済カード)
/// - Collision Resolution (同マス被り)
/// - Lottery (くじ引き) - secondary display if needed
/// - Flip animations (反転)
///
/// Widget lifecycle:
/// 1. AnimationOrchestratorNotifier.queueAnimations() adds QueuedAnimation entries
/// 2. _processQueue() starts next animation, updates currentAnimation
/// 3. AnimationOverlay watches and renders the current animation
/// 4. onAnimationComplete callback triggers next animation in queue
/// 5. Repeat until queue empty
class AnimationOverlay extends ConsumerWidget {
  final String matchId;
  final List<String> playerNames;
  final List<int> playerIndices;

  const AnimationOverlay({
    required this.matchId,
    required this.playerNames,
    required this.playerIndices,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the animation orchestrator state
    final orchestratorState =
        ref.watch(animationOrchestratorProvider(matchId));

    // Only render if there's a current animation
    if (orchestratorState.currentAnimation == null) {
      return const SizedBox.shrink();
    }

    final animation = orchestratorState.currentAnimation!;

    return Material(
      color: Colors.black87,
      child: Center(
        child: SingleChildScrollView(
          child: _buildAnimationWidget(
            animation: animation,
            onComplete: () {
              // Trigger next animation in queue
              // The orchestrator will automatically process the next one
              // This callback is called when the animation widget completes
              animation.onComplete?.call();
            },
          ),
        ),
      ),
    );
  }

  /// Build the appropriate animation widget based on event type
  Widget _buildAnimationWidget({
    required QueuedAnimation animation,
    required VoidCallback onComplete,
  }) {
    switch (animation.type) {
      case AnimationEventType.weakBonus:
        return WeakBonusAnimationWidget(
          playerName: animation.data['playerName'] ?? '',
          playerIndex: animation.data['playerIndex'] ?? 0,
          displayDuration:
              Duration(milliseconds: animation.durationMs),
          onAnimationComplete: onComplete,
        );

      case AnimationEventType.rescueCard:
        return RescueCardAnimationWidget(
          playerName: animation.data['playerName'] ?? '',
          playerIndex: animation.data['playerIndex'] ?? 0,
          reason: animation.data['reason'] ?? 'consecutive_attacks',
          displayDuration:
              Duration(milliseconds: animation.durationMs),
          onAnimationComplete: onComplete,
        );

      case AnimationEventType.collision:
        return CollisionResolutionAnimationWidget(
          conflictingPlayerNames:
              List<String>.from(animation.data['conflictingPlayerNames'] ?? []),
          playerIndices:
              List<int>.from(animation.data['playerIndices'] ?? []),
          winnerName: animation.data['winnerName'] ?? '',
          winnerIndex: animation.data['winnerIndex'] ?? 0,
          boardRow: animation.data['boardRow'] ?? 0,
          boardCol: animation.data['boardCol'] ?? 0,
          displayDuration:
              Duration(milliseconds: animation.durationMs),
          onAnimationComplete: onComplete,
        );

      case AnimationEventType.lottery:
        return LotteryAnimationWidget(
          playerNames:
              List<String>.from(animation.data['playerNames'] ?? playerNames),
          playerIndices:
              List<int>.from(animation.data['playerIndices'] ?? playerIndices),
          processOrder:
              List<String>.from(animation.data['processOrder'] ?? []),
          displayDuration:
              Duration(milliseconds: animation.durationMs),
          onAnimationComplete: onComplete,
        );

      case AnimationEventType.flip:
        // Flip animation is typically handled by SimultaneousRevealWidget
        // But if queued separately, display a placeholder
        return SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.flip, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              Text(
                '${animation.data['playerName']} の手を反映中...',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
