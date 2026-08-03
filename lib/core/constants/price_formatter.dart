import 'package:intl/intl.dart';

class PriceFormatter {
  const PriceFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,###');

  static String format(
      int price, {
        String currency = 'تومان',
      }) {
    return '${_formatter.format(price)} $currency';
  }

  static String number(int price) {
    return _formatter.format(price);
  }
}