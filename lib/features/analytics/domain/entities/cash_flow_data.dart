class CashFlowPoint {
  final DateTime date;
  final double income;
  final double expense;
  final double netFlow;
  final double runningBalance;

  const CashFlowPoint({
    required this.date,
    required this.income,
    required this.expense,
    required this.netFlow,
    required this.runningBalance,
  });
}

class CashFlowReport {
  final List<CashFlowPoint> points;
  final double netCashFlow;
  final double averageDailyFlow;
  final double highestIncome;
  final double highestExpense;

  const CashFlowReport({
    required this.points,
    required this.netCashFlow,
    required this.averageDailyFlow,
    required this.highestIncome,
    required this.highestExpense,
  });

  factory CashFlowReport.empty() {
    return const CashFlowReport(
      points: [],
      netCashFlow: 0.0,
      averageDailyFlow: 0.0,
      highestIncome: 0.0,
      highestExpense: 0.0,
    );
  }
}
