class CurrencyEntity {
  final String code; // ISO code, e.g., USD, INR
  final String name;
  final String symbol;
  final int decimalDigits;
  final String locale; // Reference locale for formatting

  const CurrencyEntity({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalDigits = 2,
    required this.locale,
  });

  static const List<CurrencyEntity> supportedCurrencies = [
    CurrencyEntity(code: 'INR', name: 'Indian Rupee', symbol: '\u20B9', locale: 'en_IN'),
    CurrencyEntity(code: 'USD', name: 'US Dollar', symbol: r'$', locale: 'en_US'),
    CurrencyEntity(code: 'EUR', name: 'Euro', symbol: '\u20AC', locale: 'de_DE'),
    CurrencyEntity(code: 'GBP', name: 'British Pound', symbol: '\u00A3', locale: 'en_GB'),
    CurrencyEntity(code: 'JPY', name: 'Japanese Yen', symbol: '\u00A5', decimalDigits: 0, locale: 'ja_JP'),
    CurrencyEntity(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', locale: 'en_AU'),
    CurrencyEntity(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', locale: 'en_CA'),
    CurrencyEntity(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', locale: 'de_CH'),
    CurrencyEntity(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', locale: 'en_SG'),
    CurrencyEntity(code: 'AED', name: 'UAE Dirham', symbol: '\u062F.\u0625', locale: 'ar_AE'),
  ];
}
