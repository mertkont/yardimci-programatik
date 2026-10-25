import 'package:intl/intl.dart';

/// Formatting helpers. Currency symbol is configurable (default ₺).
class Fmt {
  static String currencySymbol = '₺'; // ₺

  static String money(double v) =>
      '$currencySymbol${_num(v, 2)}';

  static String money4(double v) =>
      '$currencySymbol${_num(v, 4)}';

  static String num0(num v) => _num(v, 0);

  /// Compact number for chart axes: 1.2k, 3.4M, 1.1B.
  static String compact(num v) {
    final a = v.abs();
    if (a >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}B';
    if (a >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (a >= 1e3) return '${(v / 1e3).toStringAsFixed(1)}k';
    return _num(v, v == v.toInt() ? 0 : 1);
  }

  static String pct(double v) => '${_num(v, 2)}%';

  static String mult(double v) => '${_num(v, 2)}x';

  /// Format a [PrimaryMetric]-style value by unit name.
  static String byUnit(String unit, double v) {
    switch (unit) {
      case 'percent':
        return pct(v);
      case 'multiplier':
        return mult(v);
      case 'currency':
      default:
        return money4(v);
    }
  }

  static String _num(num v, int decimals) {
    final f = NumberFormat.decimalPatternDigits(
      locale: 'en',
      decimalDigits: decimals,
    );
    return f.format(v);
  }

  static String date(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  static String dayMonth(DateTime d) => DateFormat('dd MMM').format(d);

  /// "3 days left" style numbers are built in the UI; this is just the date.
  static String shortDate(DateTime d) => DateFormat('dd.MM').format(d);
}
