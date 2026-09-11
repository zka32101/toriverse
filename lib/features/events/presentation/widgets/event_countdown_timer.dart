import 'package:flutter/material.dart';
import 'dart:async';

/// Event countdown timer widget
class EventCountdownTimer extends StatefulWidget {
  final DateTime endDate;
  final TextStyle? textStyle;
  final void Function()? onExpired;

  const EventCountdownTimer({
    Key? key,
    required this.endDate,
    this.textStyle,
    this.onExpired,
  }) : super(key: key);

  @override
  State<EventCountdownTimer> createState() => _EventCountdownTimerState();
}

class _EventCountdownTimerState extends State<EventCountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final now = DateTime.now();
    final remaining = widget.endDate.difference(now);

    if (remaining.isNegative) {
      _timer.cancel();
      widget.onExpired?.call();
      setState(() {
        _remaining = Duration.zero;
      });
    } else {
      setState(() {
        _remaining = remaining;
      });
    }
  }

  String _formatDuration() {
    if (_remaining.isNegative || _remaining == Duration.zero) {
      return 'Expired';
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    if (days > 0) {
      return '$days d ${hours} h';
    } else if (hours > 0) {
      return '${hours} h ${minutes} m';
    } else if (minutes > 0) {
      return '${minutes} m ${seconds} s';
    } else {
      return '${seconds} s';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(),
      style: widget.textStyle ??
          Theme.of(context).textTheme.bodyMedium,
    );
  }
}
