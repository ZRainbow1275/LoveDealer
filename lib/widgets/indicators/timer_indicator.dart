import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/color_theme.dart';

class TimerIndicator extends StatefulWidget {
  final int durationSeconds;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? child;
  final VoidCallback? onComplete;

  const TimerIndicator({
    Key? key,
    required this.durationSeconds,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.backgroundColor = Colors.grey,
    this.foregroundColor = ColorTheme.primaryColor,
    this.child,
    this.onComplete,
  }) : super(key: key);

  @override
  State<TimerIndicator> createState() => _TimerIndicatorState();
}

class _TimerIndicatorState extends State<TimerIndicator> {
  late Timer _timer;
  late int _remainingSeconds;
  double _progress = 1.0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _progress = _remainingSeconds / widget.durationSeconds;
        } else {
          _timer.cancel();
          if (widget.onComplete != null) {
            widget.onComplete!();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: _progress,
              backgroundColor: widget.backgroundColor.withOpacity(0.3),
              color: widget.foregroundColor,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          widget.child ?? 
          Text(
            '$_remainingSeconds',
            style: TextStyle(
              fontSize: widget.size * 0.3,
              fontWeight: FontWeight.bold,
              color: widget.foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
} 