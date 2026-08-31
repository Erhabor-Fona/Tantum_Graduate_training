import 'package:intl/intl.dart';

/// Contract for turning amounts into display strings.
///
/// DIP: widgets render money through this interface, so a multi-currency
/// formatter can be swapped in without editing a single screen.
abstract interface class MoneyFormatter {
  String format(double amount);
  String formatSigned(double amount, {required bool isCredit});
  String get symbol;
}

/// Nigerian Naira formatting: 165700 -> Naira 165,700.00
class NairaFormatter implements MoneyFormatter {
  NairaFormatter();

  static final NumberFormat _fmt =
      NumberFormat.currency(locale: 'en_NG', symbol: '\u20A6', decimalDigits: 2);

  @override
  String get symbol => '\u20A6';

  @override
  String format(double amount) => _fmt.format(amount);

  @override
  String formatSigned(double amount, {required bool isCredit}) =>
      '${isCredit ? '+' : '-'} ${_fmt.format(amount)}';
}
