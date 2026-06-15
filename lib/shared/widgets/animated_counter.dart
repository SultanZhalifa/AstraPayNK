import 'package:flutter/material.dart';

/// Smoothly tweens a number whenever [value] changes — used for the AstraScore,
/// balance and points so live updates feel responsive.
class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final String prefix;
  final String suffix;
  final Duration duration;
  final int decimalPlaces;
  final bool groupThousands;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 900),
    this.decimalPlaces = 0,
    this.groupThousands = false,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> {
  late double _from = 0;

  @override
  void didUpdateWidget(covariant AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _from = oldWidget.value;
  }

  String _format(double v) {
    var s = v.toStringAsFixed(widget.decimalPlaces);
    if (widget.groupThousands && widget.decimalPlaces == 0) {
      s = s.replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
    }
    return '${widget.prefix}$s${widget.suffix}';
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _from, end: widget.value),
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(_format(v), style: widget.style),
    );
  }
}
