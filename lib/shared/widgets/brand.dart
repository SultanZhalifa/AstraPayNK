import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'svg_icon.dart';

/// AstraPay Naik Kelas logo mark (gradient tile) + optional wordmark.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final Color? wordmarkColor;

  const BrandLogo({
    super.key,
    this.size = 56,
    this.showWordmark = false,
    this.wordmarkColor,
  });

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: AppColors.softShadow(AppColors.primary, opacity: 0.35),
      ),
      child: Center(
        child: AppIcon(SvgIcons.logo, size: size * 0.56, color: Colors.white),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.28),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AstraPay',
              style: TextStyle(
                fontSize: size * 0.26,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: (wordmarkColor ?? AppColors.primary),
              ),
            ),
            Text(
              'Naik Kelas',
              style: TextStyle(
                fontSize: size * 0.40,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -0.3,
                color: wordmarkColor ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
