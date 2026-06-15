import 'dart:math' as math;
import '../constants/app_constants.dart';

/// One scoreable signal pulled from the AstraPay/Astra ecosystem.
/// [value] is normalised 0..1 (how healthy this dimension is).
class ScoreSignal {
  final String key;
  final String label;
  final double weight; // 0..1, sums to 1 across signals
  final double value; // 0..1
  final String description;

  const ScoreSignal({
    required this.key,
    required this.label,
    required this.weight,
    required this.value,
    required this.description,
  });

  /// Contribution to the score above the 300 floor (in points).
  double get points => weight * value * (AppConstants.scoreMax - AppConstants.scoreMin);

  /// How full this factor is, 0..1 (used for the breakdown bars).
  double get fill => value;

  ScoreSignal copyWith({double? value, String? description}) => ScoreSignal(
        key: key,
        label: label,
        weight: weight,
        value: value ?? this.value,
        description: description ?? this.description,
      );
}

/// The explainable output of the AstraScore engine.
class ScoreResult {
  final int score; // 300..850
  final String level; // Pemula / Berkembang / Mandiri / Bintang
  final double rawFraction; // 0..1 weighted health
  final List<ScoreSignal> signals;

  // Modal Jalan eligibility derived from the score + cash flow.
  final bool eligible;
  final double plafon; // approved working-capital limit
  final double serviceFeeRate; // tier pricing, lower for higher tiers

  const ScoreResult({
    required this.score,
    required this.level,
    required this.rawFraction,
    required this.signals,
    required this.eligible,
    required this.plafon,
    required this.serviceFeeRate,
  });
}

/// Alternative credit-scoring engine (proposal §6.1–6.2).
///
/// Turns in-ecosystem behaviour (FIF discipline, QRIS cash flow, top-up
/// regularity, tenure, growth) into a transparent 300–850 score and a
/// cash-flow-sized Modal Jalan plafon. Rule-based & weighted now; the same
/// interface upgrades to a statistical/ML model with real AstraPay data.
class AstraScoreEngine {
  const AstraScoreEngine();

  ScoreResult evaluate({
    required List<ScoreSignal> signals,
    required double monthlyQrisVolume,
  }) {
    final totalWeight =
        signals.fold<double>(0, (sum, s) => sum + s.weight);
    final raw = totalWeight == 0
        ? 0.0
        : signals.fold<double>(0, (sum, s) => sum + s.weight * s.value) /
            totalWeight;
    final fraction = raw.clamp(0.0, 1.0);

    final score = (AppConstants.scoreMin +
            fraction * (AppConstants.scoreMax - AppConstants.scoreMin))
        .round()
        .clamp(AppConstants.scoreMin, AppConstants.scoreMax);

    final level = _level(score);
    final eligible = score >= AppConstants.eligibleScore;

    // Plafon = the SMALLER of a score-band ceiling and a cash-flow ceiling
    // (40% of a typical month's QRIS) — "sizing mengikuti arus kas nyata".
    final scoreCap = _scoreCap(level);
    final cashFlowCap = monthlyQrisVolume * 0.40;
    double plafon = eligible ? math.min(scoreCap, cashFlowCap) : 0;
    // Snap to Rp100rb and clamp to product limits.
    plafon = (plafon / AppConstants.modalStep).floor() * AppConstants.modalStep;
    if (eligible) {
      plafon = plafon.clamp(AppConstants.modalMin, AppConstants.modalMax);
    }

    return ScoreResult(
      score: score,
      level: level,
      rawFraction: fraction,
      signals: signals,
      eligible: eligible,
      plafon: plafon,
      serviceFeeRate: _feeRate(level),
    );
  }

  String _level(int score) {
    if (score < AppConstants.levelBerkembang) return 'Pemula';
    if (score < AppConstants.levelMandiri) return 'Berkembang';
    if (score < AppConstants.levelBintang) return 'Mandiri';
    return 'Bintang';
  }

  double _scoreCap(String level) {
    switch (level) {
      case 'Bintang':
        return 3000000;
      case 'Mandiri':
        return 2500000;
      case 'Berkembang':
        return 1500000;
      default:
        return 500000;
    }
  }

  double _feeRate(String level) {
    switch (level) {
      case 'Bintang':
        return 0.018;
      case 'Mandiri':
        return 0.020;
      case 'Berkembang':
        return 0.025;
      default:
        return 0.030;
    }
  }

  /// Progress (0..1) of [score] toward the next level — for the gauge UI.
  static double progressToNextLevel(int score) {
    final lowers = [
      AppConstants.scoreMin,
      AppConstants.levelBerkembang,
      AppConstants.levelMandiri,
      AppConstants.levelBintang,
      AppConstants.scoreMax,
    ];
    for (var i = 0; i < lowers.length - 1; i++) {
      if (score < lowers[i + 1]) {
        final span = lowers[i + 1] - lowers[i];
        return ((score - lowers[i]) / span).clamp(0.0, 1.0);
      }
    }
    return 1.0;
  }

  /// Lower bound of the next level, or null if already Bintang.
  static int? nextLevelScore(int score) {
    if (score < AppConstants.levelBerkembang) return AppConstants.levelBerkembang;
    if (score < AppConstants.levelMandiri) return AppConstants.levelMandiri;
    if (score < AppConstants.levelBintang) return AppConstants.levelBintang;
    return null;
  }
}
