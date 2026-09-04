import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toriverse/features/shop/application/providers/crafting_providers.dart';
import 'package:toriverse/shared/services/analytics_service.dart';

/// Widget showing active crafting progress
class CraftingProgressWidget extends ConsumerStatefulWidget {
  final CraftingProgress progress;

  const CraftingProgressWidget({
    required this.progress,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<CraftingProgressWidget> createState() =>
      _CraftingProgressWidgetState();
}

class _CraftingProgressWidgetState extends ConsumerState<CraftingProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = widget.progress.isReady;
    final progressPercent = widget.progress.progressPercentage;
    final timeRemaining = widget.progress.timeRemaining;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isReady
              ? [Colors.green.shade50, Colors.teal.shade50]
              : [Colors.blue.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? Colors.green.shade300 : Colors.blue.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Icon(
                  isReady ? Icons.check_circle : Icons.hourglass_bottom,
                  size: 32,
                  color: isReady ? Colors.green.shade500 : Colors.blue.shade500,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.progress.cosmeticId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isReady ? '完成！' : 'クラフト中...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isReady
                                ? Colors.green.shade600
                                : Colors.blue.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 12,
              backgroundColor: isReady
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                isReady ? Colors.green.shade400 : Colors.blue.shade400,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '進捗: ${(progressPercent * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (!isReady)
                Text(
                  '残り時間: ${_formatDuration(timeRemaining)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                )
              else
                Text(
                  '完成済み',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Action button
          if (isReady)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: _ClaimButton(
                onPressed: _claimCraft,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    'クラフト完了時に通知でお知らせします',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blue.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _claimCraft() async {
    try {
      final success = await ref
          .read(craftingNotifierProvider.notifier)
          .claimCraft();

      if (!mounted) return;

      if (success) {
        _logCraftClaimed();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('クラフトを受け取りました！'),
            duration: Duration(seconds: 2),
          ),
        );

        // Refresh data
        ref.refresh(userCraftingProgressProvider);
      } else {
        _logCraftClaimFailed('unknown');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('受け取りに失敗しました'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _logCraftClaimFailed(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _logCraftClaimed() {
    final analyticsService = AnalyticsService();
    analyticsService.logEvent(
      name: 'craft_claimed',
      parameters: {
        'cosmetic_id': widget.progress.cosmeticId,
        'claimed_at': DateTime.now().toIso8601String(),
        'time_waited_seconds': DateTime.now()
            .difference(widget.progress.completesAt)
            .inSeconds
            .abs(),
      },
    );
  }

  void _logCraftClaimFailed(String reason) {
    final analyticsService = AnalyticsService();
    analyticsService.logEvent(
      name: 'craft_claim_failed',
      parameters: {
        'cosmetic_id': widget.progress.cosmeticId,
        'reason': reason,
      },
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '準備完了';

    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours 時間 $minutes 分';
    } else if (minutes > 0) {
      return '$minutes 分 $seconds 秒';
    } else {
      return '$seconds 秒';
    }
  }
}

/// Claim button with loading state
class _ClaimButton extends ConsumerStatefulWidget {
  final VoidCallback onPressed;

  const _ClaimButton({
    required this.onPressed,
  });

  @override
  ConsumerState<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends ConsumerState<_ClaimButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green.shade400),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              widget.onPressed().whenComplete(() {
                if (mounted) {
                  setState(() => _isLoading = false);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade400,
            ),
            child: Text(
              'コスメティックを受け取る',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
  }
}
