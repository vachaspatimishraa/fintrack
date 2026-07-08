class SemanticLabelService {
  static String getBudgetProgressLabel(String title, double progress, double amount) {
    return 'Budget for $title is ${progress.toStringAsFixed(0)} percent used. Total amount is $amount.';
  }

  static String getTransactionLabel(String title, String category, double amount, bool isExpense) {
    final type = isExpense ? 'Expense' : 'Income';
    return '$type transaction: $title in category $category for amount $amount.';
  }

  static String getChartSummaryLabel(String period, double totalIncome, double totalExpense) {
    return 'Financial summary for $period. Total income is $totalIncome. Total expenses are $totalExpense.';
  }
}
