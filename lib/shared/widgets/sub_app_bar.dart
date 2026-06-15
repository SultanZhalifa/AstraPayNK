import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'svg_icon.dart';

/// Lightweight header for pushed sub-screens: back button + centered title.
class SubAppBar extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBack;

  const SubAppBar({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
      child: Row(
        children: [
          _CircleButton(
            svg: SvgIcons.arrowLeft,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 40, child: Center(child: trailing)),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final String svg;
  final VoidCallback onTap;
  const _CircleButton({required this.svg, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: AppIcon(svg, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
