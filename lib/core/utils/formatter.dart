import 'package:intl/intl.dart';
import '../../features/settings/domain/entities/currency_entity.dart';

class AppFormatter {
  const AppFormatter._();

  static String currentCurrency = 'INR';
  static String currentLanguage = 'en';

  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd(currentLanguage).format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat.jm(currentLanguage).format(date);
  }

  static String formatCurrency(double amount) {
    final currency = CurrencyEntity.supportedCurrencies.firstWhere(
      (c) => c.code == currentCurrency,
      orElse: () => CurrencyEntity.supportedCurrencies.first,
    );
    final format = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );
    return format.format(amount);
  }

  static String formatCurrencyCompact(double amount) {
    final currency = CurrencyEntity.supportedCurrencies.firstWhere(
      (c) => c.code == currentCurrency,
      orElse: () => CurrencyEntity.supportedCurrencies.first,
    );
    final format = NumberFormat.compactCurrency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: 1,
    );
    return format.format(amount);
  }

  static String formatFriendlyDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final compareDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (compareDate == today) {
      return 'Today, $timeStr';
    } else if (compareDate == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return '${DateFormat('dd MMM yyyy').format(dateTime)}, $timeStr';
    }
  }
}
