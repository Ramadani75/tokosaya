import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(double amount) {
    return _currencyFormat.format(amount).replaceAll(' ', '');
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)} M';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)} Jt';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)} Rb';
    }
    return format(amount);
  }

  static String formatShortNumber(int number) {
    return NumberFormat.decimalPattern('id_ID').format(number);
  }

  static String getChangeBreakdownHint(double changeAmount) {
    if (changeAmount <= 0) {
      return 'Uang pas, tidak perlu kembalian.';
    }

    int remaining = changeAmount.round();
    final denominations = [100000, 50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100];
    final parts = <String>[];

    for (final denom in denominations) {
      if (remaining >= denom) {
        final count = remaining ~/ denom;
        remaining %= denom;
        final isCoin = denom <= 1000;
        final type = isCoin ? 'koin' : 'lembar';
        parts.add('$count $type ${format(denom.toDouble())}');
      }
    }

    if (parts.isEmpty) return 'Kembalian: ${format(changeAmount)}';
    if (parts.length > 2) {
      return 'Siapkan: ${parts.take(2).join(' + ')} dll.';
    }
    return 'Siapkan: ${parts.join(' + ')}';
  }
}

