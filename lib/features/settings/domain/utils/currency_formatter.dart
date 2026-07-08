import 'package:intl/intl.dart';
import '../entities/currency_entity.dart';
import '../entities/settings_entity.dart';

class CurrencyFormatter {
  static String format(double amount, SettingsEntity settings) {
    final currency = CurrencyEntity.supportedCurrencies.firstWhere(
      (c) => c.code == settings.currency,
      orElse: () => CurrencyEntity.supportedCurrencies.first,
    );

    final format = NumberFormat.currency(
      locale: currency.locale,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );

    return format.format(amount);
  }

  static String formatCompact(double amount, SettingsEntity settings) {
    final currency = CurrencyEntity.supportedCurrencies.firstWhere(
      (c) => c.code == settings.currency,
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
