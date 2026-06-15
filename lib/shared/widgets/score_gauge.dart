import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Speedometer-style gauge for the AstraScore (300–850).
/// Animates to [score] and renders [center] in the middle.
class ScoreGauge extends StatelessWidget {
  final int score;
  final int min;
  final int max;
  final double size;
  final double stroke;
  final Widget center;
  final Color? trackColor;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.center,
    this.min = 300,
    this.max = 850,
    this.size = 200,
    this.stroke = 14,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = ((score - min) / (max - min)).clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size * 0.78,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return CustomPaint(
            painter: _GaugePainter(
              fraction: value,
              stroke: stroke,
              trackColor: trackColor ?? AppColors.surfaceAlt,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: size * 0.12),
              child: Center(child: center),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final double stroke;
  final Color trackColor;

  static const double _startAngle = math.pi * 0.75; // 135°
  static const double _sweep = math.pi * 1.5; // 270°

  _GaugePainter({
    required this.fraction,
    required this.stroke,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.width / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _startAngle, _sweep, false, track);

    if (fraction > 0) {
      final progress = Paint()
        ..shader = const SweepGradient(
          startAngle: _startAngle,
          endAngle: _startAngle + _sweep,
          colors: AppColors.scoreArcColors,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, _startAngle, _sweep * fraction, false, progress);

      // Tip dot, coloured to match the score position.
      final tipAngle = _startAngle + _sweep * fraction;
      final tip = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );
      canvas.drawCircle(tip, stroke / 2 + 3, Paint()..color = Colors.white);
      canvas.drawCircle(tip, stroke / 2, Paint()..color = _sample(fraction));
    }
  }

  Color _sample(double f) {
    const colors = AppColors.scoreArcColors;
    if (f <= 0) return colors.first;
    if (f >= 1) return colors.last;
    final scaled = f * (colors.length - 1);
    final i = scaled.floor();
    return Color.lerp(colors[i], colors[i + 1], scaled - i)!;
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.stroke != stroke;
}
