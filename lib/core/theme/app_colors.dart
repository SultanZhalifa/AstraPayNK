import 'package:flutter/material.dart';

/// AstraPay Naik Kelas — LIGHT theme palette.
/// Brand-led by AstraPay violet/purple, warm amber accent for "Modal" energy.
/// Light theme only (no dark mode).
class AppColors {
  AppColors._();

  // ===== Primary brand (AstraPay violet) =====
  static const Color primary = Color(0xFF6C2BD9);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF5320A8);
  static const Color primarySoft = Color(0xFFEFE7FB); // tinted surface
  static const Color primarySofter = Color(0xFFF6F1FD);

  // ===== Accent (warm amber/orange — "Modal Jalan") =====
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFD97706);
  static const Color accentSoft = Color(0xFFFEF3DC);

  // ===== Loyalty (AstraPoints) =====
  static const Color points = Color(0xFF9333EA);
  static const Color pointsGold = Color(0xFFF59E0B);

  // ===== Backgrounds & surfaces (light) =====
  static const Color background = Color(0xFFF6F4FB); // app canvas (lavender white)
  static const Color surface = Color(0xFFFFFFFF); // cards
  static const Color surfaceAlt = Color(0xFFF1EEF9); // chips / inactive
  static const Color surfaceMuted = Color(0xFFF8F7FC);

  // ===== Borders & dividers =====
  static const Color border = Color(0xFFEAE5F4);
  static const Color borderStrong = Color(0xFFDCD5EC);

  // ===== Text =====
  static const Color textPrimary = Color(0xFF1B1430); // deep violet-ink
  static const Color textSecondary = Color(0xFF6B6485);
  static const Color textTertiary = Color(0xFF9A93AE);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ===== Semantic =====
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFE3F6E9);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3DC);
  static const Color error = Color(0xFFE11D48);
  static const Color errorSoft = Color(0xFFFCE7EC);
  static const Color info = Color(0xFF2563EB);
  static const Color infoSoft = Color(0xFFE5EDFD);

  // ===== Score level colors =====
  static const Color scorePemula = Color(0xFFE11D48); // red
  static const Color scoreBerkembang = Color(0xFFF59E0B); // amber
  static const Color scoreMandiri = Color(0xFF6C2BD9); // violet
  static const Color scoreBintang = Color(0xFF16A34A); // green

  // ===== Gradients =====
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9), Color(0xFF4C1D95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pointsGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Score arc gradient (low -> high)
  static const List<Color> scoreArcColors = [
    Color(0xFFE11D48),
    Color(0xFFF59E0B),
    Color(0xFF6C2BD9),
    Color(0xFF16A34A),
  ];

  // ===== Soft shadows (light theme) =====
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF6C2BD9).withValues(alpha: 0.06),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF1B1430).withValues(alpha: 0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> floatShadow = [
    BoxShadow(
      color: const Color(0xFF6C2BD9).withValues(alpha: 0.18),
      blurRadius: 22,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> softShadow(Color color, {double opacity = 0.28}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
