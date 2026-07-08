import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/utils/currency_formatter.dart';

void main() {
  group('Localization Settings', () {
    test('CurrencyFormatter should format INR correctly', () {
      final settings = SettingsEntity(currency: 'INR');
      final result = CurrencyFormatter.format(12500.50, settings);
      
      // Note: Depending on platform, some characters like non-breaking space might be different.
      // But it should contain ₹ and the number.
      expect(result, contains('₹'));
      expect(result, contains('12,500.50'));
    });

    test('CurrencyFormatter should format USD correctly', () {
      final settings = SettingsEntity(currency: 'USD');
      final result = CurrencyFormatter.format(1250.50, settings);
      
      expect(result, contains(r'$'));
      expect(result, contains('1,250.50'));
    });
  });
}
