import 'package:intl/intl.dart';
import '../../features/settings/domain/entities/currency_entity.dart';

class AppFormatter {
  const AppFormatter._();

  static String currentCurrency = 'USD';
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
}
