import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/svg_icon.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _animating = false; // guards against a doubled tap skipping a page

  Future<void> _next() async {
    if (_animating) return;
    _animating = true;
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOut,
    );
    _animating = false;
  }

  static const _pages = [
    _Ob(
      icon: SvgIcons.sparkles,
      color: AppColors.primary,
      title: 'Jejak transaksimu\npunya nilai',
      desc:
          'Setiap QRIS masuk, angsuran FIF, dan top-up membangun AstraScore — skor kredit alternatif yang membuka akses modal untukmu.',
    ),
    _Ob(
      icon: SvgIcons.handCoins,
      color: AppColors.accent,
      title: 'Modal Jalan,\nmodal yang tumbuh',
      desc:
          'Cairkan modal kerja Rp500rb–Rp3jt sesuai AstraScore-mu. Tanpa slip gaji, tanpa agunan — cukup jejak transaksi digitalmu.',
    ),
    _Ob(
      icon: SvgIcons.split,
      color: AppColors.success,
      title: 'Bayar sambil\njualan',
      desc:
          'Cicilan otomatis dipotong sebagian kecil dari tiap QRIS yang masuk. Tanpa jatuh tempo mencekik — bayar seiring usahamu berjalan.',
    ),
  ];

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _goLogin,
                  child: const Text('Lewati'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _ObPage(data: _pages[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 22),
                child: Column(
                  children: [
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _pages.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.borderStrong,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 3.2,
                        spacing: 6,
                      ),
                    ),
                    const SizedBox(height: 26),
                    GradientButton(
                      text: isLast ? 'Mulai Sekarang' : 'Lanjutkan',
                      icon: AppIcon(
                        isLast ? SvgIcons.lightning : SvgIcons.arrowRight,
                        size: 19,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isLast) {
                          _goLogin();
                        } else {
                          _next();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ob {
  final String icon;
  final Color color;
  final String title;
  final String desc;
  const _Ob({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}

class _ObPage extends StatelessWidget {
  final _Ob data;
  const _ObPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final iconSize = (Responsive.height(context) * 0.15).clamp(96.0, 150.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(iconSize * 0.30),
              border: Border.all(color: data.color.withValues(alpha: 0.18)),
            ),
            child: Center(
              child: AppIcon(data.icon, size: iconSize * 0.42, color: data.color),
            ),
          ),
          SizedBox(height: Responsive.height(context) * 0.05),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
