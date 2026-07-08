import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/cash_flow_data.dart';

class CashFlowAggregators {
  static CashFlowReport aggregate({
    required List<TransactionEntity> transactions,
    required String timeFilter,
  }) {
    if (transactions.isEmpty) {
      return CashFlowReport.empty();
    }

    final sorted = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    final Map<String, _DayBucket> buckets = {};
    double runningBal = 0.0;

    for (final tx in sorted) {
      if (tx.isDeleted) continue;
      final dateKey = '${tx.date.year}-${tx.date.month}-${tx.date.day}';
      final bucket = buckets.putIfAbsent(
        dateKey,
        () => _DayBucket(date: DateTime(tx.date.year, tx.date.month, tx.date.day)),
      );

      if (tx.type == 'income') {
        bucket.income += tx.amount;
        runningBal += tx.amount;
      } else if (tx.type == 'expense') {
        bucket.expense += tx.amount;
        runningBal -= tx.amount;
      }
      bucket.runningBalance = runningBal;
    }

    final points = buckets.values.map((b) {
      return CashFlowPoint(
        date: b.date,
        income: b.income,
        expense: b.expense,
        netFlow: b.income - b.expense,
        runningBalance: b.runningBalance,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    double netCash = 0.0;
    double highestInc = 0.0;
    double highestExp = 0.0;

    for (final pt in points) {
      netCash += pt.netFlow;
      if (pt.income > highestInc) highestInc = pt.income;
      if (pt.expense > highestExp) highestExp = pt.expense;
    }

    final avgDaily = points.isNotEmpty ? netCash / points.length : 0.0;

    return CashFlowReport(
      points: points,
      netCashFlow: netCash,
      averageDailyFlow: avgDaily,
      highestIncome: highestInc,
      highestExpense: highestExp,
    );
  }
}

class _DayBucket {
  final DateTime date;
  double income = 0.0;
  double expense = 0.0;
  double runningBalance = 0.0;

  _DayBucket({required this.date});
}
