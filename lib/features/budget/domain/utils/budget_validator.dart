import '../entities/budget_entity.dart';

class BudgetValidator {
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? validateAmount(double? value) {
    if (value == null || value <= 0) {
      return 'Amount must be greater than 0';
    }
    return null;
  }

  static String? validateDateRange(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }

  static String? validateDescription(String? value) {
    if (value != null && value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    return null;
  }

  static bool isValid(BudgetEntity budget) {
    return validateTitle(budget.title) == null &&
        validateAmount(budget.amount) == null &&
        validateDateRange(budget.startDate, budget.endDate) == null &&
        validateDescription(budget.description) == null;
  }
}
