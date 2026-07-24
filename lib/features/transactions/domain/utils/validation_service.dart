class ValidationService {
  static const double maxAmount = 999999999999.99;
  static final RegExp _amountPattern = RegExp(r'^\d+(\.\d{0,2})?$');

  static String? validateTitle(String? value) {
    if (value != null && value.trim().length > 60) {
      return 'enter_title';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty || !_amountPattern.hasMatch(trimmed)) {
      return 'enter_valid_amount_gt_zero';
    }
    final amount = double.tryParse(trimmed);
    if (amount == null || amount <= 0 || amount > maxAmount) {
      return 'enter_valid_amount_gt_zero';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'max_chars_500';
    }
    return null;
  }

  static String? validateCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please_select_category';
    }
    return null;
  }

  static String? validatePaymentMethod(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'please_select_payment_method';
    }
    return null;
  }
}
