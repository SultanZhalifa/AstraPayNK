import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/personas.dart';
import '../../shared/widgets/svg_icon.dart';

Future<void> showPersonaSwitcher(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _PersonaSheet(),
  );
}

class _PersonaSheet extends StatelessWidget {
  const _PersonaSheet();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ganti Profil Demo',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Setiap persona punya jejak transaksi & AstraScore berbeda.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...Personas.all.values.map((p) => _PersonaItem(
                  seed: p,
                  active: p.persona == app.persona,
                  onTap: () {
                    context.read<AppState>().switchPersona(p.persona);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _PersonaItem extends StatelessWidget {
  final PersonaSeed seed;
  final bool active;
  final VoidCallback onTap;

  const _PersonaItem({
    required this.seed,
    required this.active,
    required this.onTap,
  });

  Color get _levelColor {
    switch (Formatters.scoreLevel(seed.history.last.score)) {
      case 'Bintang':
        return AppColors.scoreBintang;
      case 'Mandiri':
        return AppColors.scoreMandiri;
      case 'Berkembang':
        return AppColors.scoreBerkembang;
      default:
        return AppColors.scorePemula;
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = Formatters.scoreLevel(seed.history.last.score);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? AppColors.primary : AppColors.border,
          width: active ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      seed.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seed.name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        seed.businessCategory,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${seed.history.last.score}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _levelColor,
                      ),
                    ),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _levelColor,
                      ),
                    ),
                  ],
                ),
                if (active)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: AppIcon(SvgIcons.checkCircle,
                        size: 20, color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
