
class BudgetProgressCalculator {
  static double calculateProgress(double spent, double total) {
    if (total <= 0) return 0.0;
    return (spent / total) * 100;
  }

  static double calculateRemaining(double total, double spent) {
    return total - spent;
  }

  static double calculateDailyLimit(double remaining, DateTime endDate) {
    final now = DateTime.now();
    final remainingDays = endDate.difference(now).inDays;
    if (remainingDays <= 0) return remaining;
    return remaining / remainingDays;
  }
}
