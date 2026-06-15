/// A live Modal Jalan loan. [amountPaid] grows as QRIS split-repayments arrive,
/// so this is intentionally mutable and shared through AppState.
class ActiveModal {
  final String id;
  final String referenceNo;
  final String partner; // licensed financing rail
  final double amount;
  final int tenorDays;
  final double serviceFee;
  double splitRate; // fraction of each QRIS siphoned to repayment
  final DateTime disbursedAt;
  final DateTime dueDate;
  double amountPaid;

  ActiveModal({
    required this.id,
    required this.referenceNo,
    required this.partner,
    required this.amount,
    required this.tenorDays,
    required this.serviceFee,
    required this.splitRate,
    required this.disbursedAt,
    required this.dueDate,
    this.amountPaid = 0,
  });

  double get totalRepayment => amount + serviceFee;
  double get remaining =>
      (totalRepayment - amountPaid).clamp(0, totalRepayment).toDouble();
  double get progress =>
      totalRepayment == 0 ? 0 : (amountPaid / totalRepayment).clamp(0.0, 1.0);
  bool get isPaidOff => amountPaid >= totalRepayment - 0.5;
  int get daysRemaining {
    final d = dueDate.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }
}
