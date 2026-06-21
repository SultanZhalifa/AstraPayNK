import 'package:flutter/widgets.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'AstraPay Naik Kelas';
  static const String appShortName = 'Naik Kelas';
  static const String appTagline = 'Modal yang tumbuh bareng usahamu';

  // ===== AstraScore range (selaras proposal: 300–850) =====
  static const int scoreMin = 300;
  static const int scoreMax = 850;

  // Level thresholds (lower bound inclusive)
  static const int levelBerkembang = 500;
  static const int levelMandiri = 650;
  static const int levelBintang = 750;
  // Minimum score eligible for Modal Jalan
  static const int eligibleScore = 500;

  // ===== Modal Jalan limits (proposal: Rp500rb–Rp3jt) =====
  static const double modalMin = 500000;
  static const double modalMax = 3000000;
  static const double modalStep = 100000;

  // Tenor options (days) — short tenor "bayar sambil jualan"
  static const List<int> tenorOptions = [14, 30, 60];

  // Service fee (illustrative)
  static const double serviceFeeRate = 0.025; // 2.5%

  // Split repayment percentage applied to each incoming QRIS
  static const double defaultSplitPercentage = 0.15; // 15%
  static const List<double> splitOptions = [0.10, 0.15, 0.20];

  // QRIS MDR (Merchant Discount Rate) untuk usaha mikro (UMI), selaras
  // docs.astrapay.com: 0% untuk transaksi ≤ Rp500rb, 0,3% di atasnya.
  static const double qrisMdrThreshold = 500000;
  static const double qrisMdrRateMicro = 0.0;
  static const double qrisMdrRateStandard = 0.003;

  /// MDR (Rupiah) yang dipotong dari satu pembayaran QRIS masuk.
  static double qrisMdr(double amount) => amount <= qrisMdrThreshold
      ? amount * qrisMdrRateMicro
      : amount * qrisMdrRateStandard;

  // AstraScore signal weights (proposal §6.2)
  static const Map<String, double> scoreWeights = {
    'Ketepatan Bayar Angsuran FIF': 0.35,
    'Volume & Konsistensi QRIS': 0.30,
    'Keteraturan Top-up': 0.15,
    'Tenure & Kelengkapan Akun': 0.10,
    'Tren Pertumbuhan': 0.10,
  };

  // Points economy
  static const int pointsPerOnTimeRepayment = 100;
  static const int pointsPerQrisSplit = 8;

  // Animation durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 800);

  // Common radii
  static const double radius = 18;
  static const Radius radiusCircular = Radius.circular(18);
}
