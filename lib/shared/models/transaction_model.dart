enum TransactionType {
  qrisIncoming,
  qrisOutgoing,
  angsuranFif,
  topUp,
  splitRepayment,
  modalCair,
  transfer,
  ppob,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final String description;
  final double amount;
  final DateTime date;
  final bool isCredit; // true = money in, false = money out
  final String? splitInfo; // e.g. "15% untuk cicilan Modal Jalan"
  final String status; // success, pending, failed

  const TransactionModel({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.date,
    required this.isCredit,
    this.splitInfo,
    this.status = 'success',
  });

  String get typeLabel {
    switch (type) {
      case TransactionType.qrisIncoming:
        return 'QRIS Masuk';
      case TransactionType.qrisOutgoing:
        return 'QRIS Keluar';
      case TransactionType.angsuranFif:
        return 'Angsuran FIF';
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.splitRepayment:
        return 'Cicilan Modal';
      case TransactionType.modalCair:
        return 'Modal Jalan';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.ppob:
        return 'PPOB';
    }
  }
}
