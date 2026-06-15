import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/brand.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logo = AnimationController(
    duration: const Duration(milliseconds: 1100),
    vsync: this,
  );
  late final AnimationController _text = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  late final Animation<double> _logoScale = Tween<double>(begin: 0.6, end: 1.0)
      .animate(CurvedAnimation(parent: _logo, curve: Curves.elasticOut));
  late final Animation<double> _logoFade = CurvedAnimation(
      parent: _logo, curve: const Interval(0, 0.5, curve: Curves.easeIn));
  late final Animation<double> _textFade =
      CurvedAnimation(parent: _text, curve: Curves.easeIn);

  @override
  void initState() {
    super.initState();
    _logo.forward();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) _text.forward();
    });
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const OnboardingScreen(),
          transitionsBuilder: (_, a, _, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logo.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // soft brand glow
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.9,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const BrandLogo(size: 92),
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        'AstraPay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 4,
                          color: AppColors.primary.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Naik Kelas',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppConstants.appTagline,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 36,
              child: FadeTransition(
                opacity: _textFade,
                child: Column(
                  children: [
                    const Text(
                      'Powered by',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AstraPay Ecosystem',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
