import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/validation_service.dart';

void main() {
  group('Transaction UX & Form Validation Tests', () {
    test('validateTitle returns exact spec messages', () {
      expect(ValidationService.validateTitle(''), isNull);
      expect(ValidationService.validateTitle(null), isNull);
      expect(ValidationService.validateTitle('Groceries'), isNull);
    });

    test('validateAmount returns exact spec messages', () {
      expect(ValidationService.validateAmount(''), equals('enter_valid_amount_gt_zero'));
      expect(ValidationService.validateAmount('0'), equals('enter_valid_amount_gt_zero'));
      expect(ValidationService.validateAmount('-10'), equals('enter_valid_amount_gt_zero'));
      expect(ValidationService.validateAmount('12.34'), isNull);
    });

    test('validateCategory returns exact spec messages', () {
      expect(ValidationService.validateCategory(''), equals('please_select_category'));
      expect(ValidationService.validateCategory('Food'), isNull);
    });

    test('validatePaymentMethod returns exact spec messages', () {
      expect(ValidationService.validatePaymentMethod(''), equals('please_select_payment_method'));
      expect(ValidationService.validatePaymentMethod('UPI'), isNull);
    });
  });
}
