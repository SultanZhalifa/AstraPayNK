/// Abstraction over the AstraPay ecosystem APIs used by Naik Kelas.
///
/// Naik Kelas is a thin intelligence layer on top of products AstraPay already
/// ships (proposal §4): QRIS (cash-flow signal + split-repayment rail),
/// Disbursement (Modal Jalan payout via a licensed financing partner), and
/// AstraPoints (loyalty). This interface mirrors those endpoints so the demo's
/// mock can be swapped for the real AstraPay Sandbox without touching the UI.
abstract class AstraPayService {
  /// Human-readable backend this instance talks to (shown in the UI).
  String get environment;

  /// True once a real Sandbox base URL + credentials are configured.
  bool get isLiveSandbox;

  /// Simulate / receive an incoming QRIS payment for the merchant.
  /// In production this is driven by AstraPay's QRIS settlement webhook.
  Future<QrisPaymentResult> receiveQrisPayment({
    required double amount,
    required String payerName,
    required double splitRate,
  });

  /// Disburse Modal Jalan to the merchant's AstraPay balance via the licensed
  /// financing rail (FINATRA / partner). Maps to AstraPay Disbursement.
  Future<DisbursementResult> disburseModal({
    required double amount,
    required int tenorDays,
    required double serviceFee,
  });

  /// Award AstraPoints for a loyalty event (on-time repayment, level-up, …).
  Future<int> awardPoints({required int points, required String reason});
}

/// Result of an incoming QRIS payment, including the auto-split breakdown.
class QrisPaymentResult {
  final String referenceNo;
  final double grossAmount;
  final double mdrFee; // MDR dipotong (usaha mikro: 0% untuk ≤Rp500rb)
  final double splitToRepayment; // siphoned to Modal Jalan
  final double netToBalance; // lands in merchant balance
  final DateTime settledAt;

  const QrisPaymentResult({
    required this.referenceNo,
    required this.grossAmount,
    required this.mdrFee,
    required this.splitToRepayment,
    required this.netToBalance,
    required this.settledAt,
  });
}

class DisbursementResult {
  final String referenceNo;
  final String partner; // licensed lender (e.g. FINATRA)
  final double amount;
  final int tenorDays;
  final double serviceFee;
  final DateTime disbursedAt;
  final DateTime dueDate;

  const DisbursementResult({
    required this.referenceNo,
    required this.partner,
    required this.amount,
    required this.tenorDays,
    required this.serviceFee,
    required this.disbursedAt,
    required this.dueDate,
  });
}
