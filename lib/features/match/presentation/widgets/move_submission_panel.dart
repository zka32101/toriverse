import 'package:flutter/material.dart';

/// Panel showing current player info and submission status
class MoveSubmissionPanel extends StatefulWidget {
  final String currentPlayer;
  final int validMoveCount;
  final VoidCallback onSubmit;

  const MoveSubmissionPanel({
    Key? key,
    required this.currentPlayer,
    required this.validMoveCount,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MoveSubmissionPanel> createState() => _MoveSubmissionPanelState();
}

class _MoveSubmissionPanelState extends State<MoveSubmissionPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;
  int _secondsRemaining = 30;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..forward();

    _timerController.addListener(() {
      setState(() {
        _secondsRemaining = (30 * (1 - _timerController.value)).ceil();
      });
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = _secondsRemaining < 10;

    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'プレイヤー: ${widget.currentPlayer}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '合法手: ${widget.validMoveCount}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Column(
            children: [
              const Text('提出まで', style: TextStyle(fontSize: 12)),
              Text(
                '$_secondsRemaining秒',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isWarning ? Colors.red : Colors.black,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: widget.onSubmit,
            child: const Text('提出'),
          ),
        ],
      ),
    );
  }
}
