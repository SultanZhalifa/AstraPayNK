import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Primary call-to-action button with a press-scale micro-interaction and a
/// brand gradient + soft glow. Light-theme tuned.
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color glowColor;
  final double? width;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.glowColor = AppColors.primary,
    this.width,
    this.height = 54,
    this.borderRadius = 16,
    this.isLoading = false,
    this.enabled = true,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 130),
    vsync: this,
    lowerBound: 0.0,
    upperBound: 0.04,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _interactive =>
      widget.enabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _interactive ? (_) => _controller.forward() : null,
      onTapUp: _interactive
          ? (_) {
              _controller.reverse();
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: 1 - _controller.value,
          child: child,
        ),
        child: Opacity(
          opacity: _interactive ? 1 : 0.5,
          child: Container(
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.gradient ?? AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _interactive
                  ? AppColors.softShadow(widget.glowColor, opacity: 0.32)
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 9),
                        ],
                        Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
