import 'dart:math';
import 'astrapay_service.dart';

/// In-memory implementation of [AstraPayService] for the prototype / Demo Day.
///
/// It mirrors the real AstraPay Sandbox call shapes (reference numbers,
/// settlement timing, financing partner) so the demo runs fully offline while
/// remaining "Sandbox-ready": swap this for an `HttpAstraPayService` that calls
/// docs.astrapay.com endpoints and the rest of the app is unchanged.
class MockAstraPayService implements AstraPayService {
  final Random _rng = Random();

  @override
  String get environment => 'Sandbox Simulation';

  @override
  bool get isLiveSandbox => false;

  String _ref(String prefix) {
    final n = _rng.nextInt(900000) + 100000;
    final t = DateTime.now().millisecondsSinceEpoch % 100000;
    return '$prefix-$t$n';
  }

  @override
  Future<QrisPaymentResult> receiveQrisPayment({
    required double amount,
    required String payerName,
    required double splitRate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 280));
    final split = (amount * splitRate);
    return QrisPaymentResult(
      referenceNo: _ref('QRIS'),
      grossAmount: amount,
      splitToRepayment: split,
      netToBalance: amount - split,
      settledAt: DateTime.now(),
    );
  }

  @override
  Future<DisbursementResult> disburseModal({
    required double amount,
    required int tenorDays,
    required double serviceFee,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();
    return DisbursementResult(
      referenceNo: _ref('DISB'),
      partner: 'FINATRA',
      amount: amount,
      tenorDays: tenorDays,
      serviceFee: serviceFee,
      disbursedAt: now,
      dueDate: now.add(Duration(days: tenorDays)),
    );
  }

  @override
  Future<int> awardPoints({required int points, required String reason}) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return points;
  }
}
