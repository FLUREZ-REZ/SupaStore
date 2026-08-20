import 'package:intl/intl.dart';

class PriceFormatter {
  const PriceFormatter._();

  static final NumberFormat _formatter =
  NumberFormat('#,###', 'fa_IR');

  /// مثال:
  /// 1500000 -> ۱,۵۰۰,۰۰۰ تومان
  static String format(
      int price, {
        String currency = 'تومان',
      }) {
    return '${_formatter.format(price)} $currency';
  }

  /// فقط عدد
  /// 1500000 -> ۱,۵۰۰,۰۰۰
  static String number(int price) {
    return _formatter.format(price);
  }
}