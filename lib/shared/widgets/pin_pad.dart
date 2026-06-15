import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'svg_icon.dart';

/// Row of PIN indicator dots.
class PinDots extends StatelessWidget {
  final int length;
  final int filled;
  const PinDots({super.key, this.length = 6, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final on = i < filled;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 7),
          width: on ? 15 : 13,
          height: on ? 15 : 13,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: on ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: on ? AppColors.primary : AppColors.borderStrong,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}

/// Numeric keypad with an SVG backspace key (no emoji / Material glyphs).
class PinPad extends StatelessWidget {
  final ValueChanged<String> onKey;
  final VoidCallback onDelete;

  const PinPad({super.key, required this.onKey, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 14,
        childAspectRatio: 1.7,
        children: keys.map((k) {
          if (k.isEmpty) return const SizedBox.shrink();
          final isDel = k == 'del';
          return Material(
            color: isDel ? Colors.transparent : AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDel
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => isDel ? onDelete() : onKey(k),
              child: Center(
                child: isDel
                    ? const AppIcon(SvgIcons.backspace,
                        size: 24, color: AppColors.textSecondary)
                    : Text(
                        k,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
