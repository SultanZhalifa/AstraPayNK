import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final _decimalFormat = NumberFormat.decimalPattern('id_ID');
  static final _dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
  static final _timeFormat = DateFormat('HH:mm', 'id_ID');
  static final _monthShortFormat = DateFormat('MMM', 'id_ID');
  static final _monthYearFormat = DateFormat('MMM yyyy', 'id_ID');
  static final _dayShortFormat = DateFormat('EEE', 'id_ID');

  static String currency(num amount) => _currencyFormat.format(amount);

  /// Compact currency for tight spaces, e.g. Rp1,5 jt / Rp850 rb.
  static String compactCurrency(num amount) {
    final a = amount.abs();
    String body;
    if (a >= 1000000000) {
      body = 'Rp${_trim(a / 1000000000)} M';
    } else if (a >= 1000000) {
      body = 'Rp${_trim(a / 1000000)} jt';
    } else if (a >= 1000) {
      body = 'Rp${_trim(a / 1000)} rb';
    } else {
      body = 'Rp${a.toStringAsFixed(0)}';
    }
    return amount < 0 ? '-$body' : body;
  }

  static String _trim(double v) {
    final s = v.toStringAsFixed(1).replaceAll('.', ',');
    return s.endsWith(',0') ? s.substring(0, s.length - 2) : s;
  }

  static String number(num value) => _decimalFormat.format(value);

  static String date(DateTime date) => _dateFormat.format(date);
  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
  static String time(DateTime date) => _timeFormat.format(date);
  static String monthShort(DateTime date) => _monthShortFormat.format(date);
  static String dayShort(DateTime date) => _dayShortFormat.format(date);
  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  static String percentage(double value, {int digits = 0}) =>
      '${(value * 100).toStringAsFixed(digits)}%';

  static String scoreLevel(int score) {
    if (score < AppConstants.levelBerkembang) return 'Pemula';
    if (score < AppConstants.levelMandiri) return 'Berkembang';
    if (score < AppConstants.levelBintang) return 'Mandiri';
    return 'Bintang';
  }

  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return _dateFormat.format(date);
  }
}
