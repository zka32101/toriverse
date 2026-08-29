import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../data/models/round_result_model.dart';

/// 同時公開・くじ引き演出ウィジェット（GAME_DESIGN_UI_REFORM.md §3.3）
///
/// `ProcessOrderRandomizer.generateAnimationSequence` が生成する
/// くじ引き→順番発表→反転再生のシーケンスを、フルスクリーンのオーバーレイ
/// として再生する。「同時公開のドキドキ」を専用のビジュアル言語で
/// 演出する差別化ポイント。
///
/// 各 [ReplayEvent] の `delayMs` を優先し、未指定（0）の場合は
/// イベント種別に応じた [ToriverseTheme] のモーショントークンを
/// デフォルトとして使用する。
class SimultaneousRevealWidget extends StatefulWidget {
  final List<ReplayEvent> events;
  final VoidCallback? onComplete;

  const SimultaneousRevealWidget({
    Key? key,
    required this.events,
    this.onComplete,
  }) : super(key: key);

  @override
  State<SimultaneousRevealWidget> createState() =>
      _SimultaneousRevealWidgetState();
}

class _SimultaneousRevealWidgetState extends State<SimultaneousRevealWidget> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.events.isEmpty) {
      // イベントが無ければ即座に完了扱いにする
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onComplete?.call();
      });
    } else {
      _scheduleNext();
    }
  }

  void _scheduleNext() {
    if (_currentIndex >= widget.events.length) {
      widget.onComplete?.call();
      return;
    }

    final event = widget.events[_currentIndex];
    final duration = event.delayMs > 0
        ? Duration(milliseconds: event.delayMs)
        : _defaultDurationFor(event.type);

    Future.delayed(duration, () {
      if (!mounted) return;
      setState(() => _currentIndex++);
      _scheduleNext();
    });
  }

  Duration _defaultDurationFor(String type) {
    switch (type) {
      case 'lottery':
        return ToriverseTheme.lotteryDuration;
      case 'announce_turn':
        return ToriverseTheme.bonusPulse;
      case 'flip_animation':
      case 'flip':
        return ToriverseTheme.flipStagger;
      default:
        return ToriverseTheme.flipStagger;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty || _currentIndex >= widget.events.length) {
      return const SizedBox.shrink();
    }

    final event = widget.events[_currentIndex];

    return Material(
      color: Colors.black87,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          child: _buildStage(event, key: ValueKey(_currentIndex)),
        ),
      ),
    );
  }

  Widget _buildStage(ReplayEvent event, {Key? key}) {
    switch (event.type) {
      case 'lottery':
        return _LotteryStage(key: key);
      case 'announce_turn':
        return _AnnounceTurnStage(key: key, data: event.data);
      case 'flip_animation':
      case 'flip':
        return _FlipAnnounceStage(key: key, data: event.data);
      default:
        return SizedBox.shrink(key: key);
    }
  }
}

/// くじ引き演出: 処理順抽選中の"開封の快感"を作り込むステージ
class _LotteryStage extends StatelessWidget {
  const _LotteryStage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(strokeWidth: 5, color: Colors.white),
        ),
        const SizedBox(height: ToriverseTheme.spacing24),
        Text(
          'くじ引き中...',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

/// 処理順発表ステージ
class _AnnounceTurnStage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AnnounceTurnStage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final order = data['order'];
    final playerId = data['playerId']?.toString() ?? '';

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$order 番目',
          style: TextStyle(
            fontSize: ToriverseTheme.displayFontSize,
            fontWeight: FontWeight.bold,
            color: ToriverseTheme.neutralColor,
          ),
        ),
        const SizedBox(height: ToriverseTheme.spacing12),
        Text(
          playerId,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ],
    );
  }
}

/// 反転アニメ再生ステージ（結果サマリ表示）
class _FlipAnnounceStage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _FlipAnnounceStage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final playerId = data['playerId']?.toString() ?? '';

    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.flip, color: Colors.white, size: 48),
        const SizedBox(height: ToriverseTheme.spacing12),
        Text(
          '$playerId の手を反映中...',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }
}
