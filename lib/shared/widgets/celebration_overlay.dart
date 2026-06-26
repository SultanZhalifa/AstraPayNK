import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'svg_icon.dart';

/// Shows a celebratory overlay (confetti + scaled-in badge) for the big
/// emotional moments: leveling up or unlocking Modal Jalan. Dependency-free —
/// just an animated [showGeneralDialog]. Fires a haptic on appear.
Future<void> showCelebration(
  BuildContext context,
  String message, {
  String title = 'Selamat!',
}) {
  HapticFeedback.heavyImpact();
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => _CelebrationDialog(title: title, message: message),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: anim,
      child: child,
    ),
  );
}

class _CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  const _CelebrationDialog({required this.title, required this.message});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with TickerProviderStateMixin {
  late final AnimationController _confetti = AnimationController(
    duration: const Duration(milliseconds: 2200),
    vsync: this,
  )..forward();
  late final AnimationController _pop = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..forward();

  @override
  void dispose() {
    _confetti.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti fills the screen behind the card.
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (_, _) => CustomPaint(
                painter: _ConfettiPainter(_confetti.value),
              ),
            ),
          ),
        ),
        Center(
          child: ScaleTransition(
            scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 36),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.floatShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow:
                          AppColors.softShadow(AppColors.primary, opacity: 0.4),
                    ),
                    child: const Center(
                      child: AppIcon(SvgIcons.star, size: 42, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Lanjutkan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Lightweight falling-confetti painter driven by a 0..1 progress value.
class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  static final _rng = math.Random(42);
  static const _colors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.success,
    AppColors.points,
    AppColors.info,
  ];
  // Pre-seed deterministic particles so they stay stable across repaints.
  static final List<_Particle> _particles = List.generate(
    44,
    (_) => _Particle(
      x: _rng.nextDouble(),
      delay: _rng.nextDouble() * 0.25,
      speed: 0.7 + _rng.nextDouble() * 0.6,
      drift: (_rng.nextDouble() - 0.5) * 0.25,
      size: 5 + _rng.nextDouble() * 6,
      color: _colors[_rng.nextInt(_colors.length)],
      rot: _rng.nextDouble() * math.pi,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final local = ((t - p.delay) * p.speed).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final dx = (p.x + p.drift * local) * size.width;
      final dy = (local * 1.15 - 0.1) * size.height;
      final opacity = (1 - local).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withValues(alpha: opacity);
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(p.rot + local * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          const Radius.circular(1.5),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

class _Particle {
  final double x, delay, speed, drift, size, rot;
  final Color color;
  const _Particle({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.size,
    required this.color,
    required this.rot,
  });
}
