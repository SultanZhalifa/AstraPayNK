import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/svg_icon.dart';
import '../modal/modal_screen.dart';
import '../score/score_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../aktivitas/aktivitas_screen.dart';
import '../points/points_screen.dart';
import '../split_demo/split_demo_screen.dart';
import 'dashboard_view.dart';

/// App shell: 4 tabbed destinations + a raised center "Terima QRIS" action
/// that opens the live split-repayment demo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  void _setIndex(int i) => setState(() => _index = i);

  void _openTerimaQris() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TerimaQrisScreen()),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardView(
        onOpenModal: () => _setIndex(1),
        onOpenScore: () => _setIndex(2),
        onTerimaQris: _openTerimaQris,
        onOpenAktivitas: () => _push(const AktivitasScreen()),
        onOpenPoints: () => _push(const PointsScreen()),
      ),
      const ModalScreen(),
      const ScoreDetailScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: _setIndex,
        onCenter: _openTerimaQris,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onCenter;

  const _BottomBar({
    required this.index,
    required this.onTap,
    required this.onCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Row(
            children: [
              _navItem(0, 'Beranda', SvgIcons.home),
              _navItem(1, 'Modal', SvgIcons.wallet),
              _CenterButton(onTap: onCenter),
              _navItem(2, 'Skor', SvgIcons.chart),
              _navItem(3, 'Profil', SvgIcons.user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, String label, String icon) {
    final active = index == i;
    final color = active ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: InkWell(
          onTap: () => onTap(i),
          borderRadius: BorderRadius.circular(14),
          // Fill the cell so the whole area is a comfortable tap target.
          child: SizedBox(
            height: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(icon, size: 23, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised center action with a gentle, looping pulse to draw the eye to the
/// app's hero flow ("Terima QRIS"). The whole nav cell is the tap target.
class _CenterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CenterButton({required this.onTap});

  @override
  State<_CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<_CenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    duration: const Duration(milliseconds: 1600),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: 'Terima QRIS',
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  // Fixed footprint so the expanding halo never grows the
                  // nav row (would overflow its 74px height).
                  width: 50,
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Expanding halo ring — OverflowBox keeps it out of layout.
                      OverflowBox(
                        maxWidth: 86,
                        maxHeight: 86,
                        child: AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, _) {
                            final t = _pulse.value;
                            return Container(
                              width: 50 + 24 * t,
                              height: 50 + 24 * t,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary
                                    .withValues(alpha: 0.22 * (1 - t)),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: AppColors.softShadow(AppColors.primary,
                              opacity: 0.4),
                        ),
                        child: const Center(
                          child: AppIcon(SvgIcons.qris,
                              size: 24, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Terima',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
