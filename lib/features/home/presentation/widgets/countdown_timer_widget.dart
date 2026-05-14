import 'dart:async';

import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime? deadline;
  final VoidCallback? onExpired;

  const CountdownTimerWidget({
    super.key,
    required this.deadline,
    this.onExpired,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.inSeconds <= 0) {
      return Chip(
        label: const Text('Expired'),
        backgroundColor: Colors.grey.shade200,
      );
    }
    final red = _remaining.inMinutes < 2;
    return Chip(
      avatar: Icon(
        Icons.timer,
        color: red ? Colors.red : Colors.teal,
        size: 18,
      ),
      label: Text(_format(_remaining)),
      labelStyle: TextStyle(color: red ? Colors.red : Colors.teal),
      backgroundColor: red ? Colors.red.shade50 : Colors.teal.shade50,
    );
  }

  void _tick() {
    final deadline = widget.deadline;
    final next = deadline == null
        ? Duration.zero
        : deadline.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = next.isNegative ? Duration.zero : next);
    if (_remaining == Duration.zero) widget.onExpired?.call();
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
