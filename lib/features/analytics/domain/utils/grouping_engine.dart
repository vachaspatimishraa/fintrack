import 'package:intl/intl.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/custom_report_data.dart';

class GroupingEngine {
  const GroupingEngine._();

  static List<CustomReportGroup> group({
    required List<TransactionEntity> transactions,
    required String groupBy,
  }) {
    if (transactions.isEmpty) return const [];

    final groupsMap = <String, List<TransactionEntity>>{};

    for (final tx in transactions) {
      String key = 'Other';

      switch (groupBy.toLowerCase()) {
        case 'day':
          key = DateFormat('yyyy-MM-dd').format(tx.date);
          break;
        case 'week':
          final w = ((tx.date.day - 1) / 7).floor() + 1;
          key = 'Week $w, ${DateFormat('MMM yyyy').format(tx.date)}';
          break;
        case 'month':
          key = DateFormat('MMMM yyyy').format(tx.date);
          break;
        case 'quarter':
          final quarter = ((tx.date.month - 1) / 3).floor() + 1;
          key = 'Q$quarter ${tx.date.year}';
          break;
        case 'year':
          key = '${tx.date.year}';
          break;
        case 'category':
          key = tx.category.isNotEmpty ? tx.category : 'Uncategorized';
          break;
        case 'account':
          key = tx.accountId.isNotEmpty ? tx.accountId : 'Default Wallet';
          break;
        default:
          key = tx.category.isNotEmpty ? tx.category : 'Others';
          break;
      }

      groupsMap.putIfAbsent(key, () => []).add(tx);
    }

    final result = groupsMap.entries.map((entry) {
      double income = 0;
      double expense = 0;

      for (final tx in entry.value) {
        if (tx.type == 'income') {
          income += tx.amount;
        } else if (tx.type == 'expense') {
          expense += tx.amount;
        }
      }

      return CustomReportGroup(
        name: entry.key,
        income: income,
        expense: expense,
        savings: income - expense,
        transactionCount: entry.value.length,
      );
    }).toList();

    // Sort groups chronologically or by amount depending on nature
    if (['day', 'week', 'month', 'quarter', 'year'].contains(groupBy.toLowerCase())) {
      result.sort((a, b) => a.name.compareTo(b.name));
    } else {
      result.sort((a, b) => b.expense.compareTo(a.expense)); // By default sort categories by expense desc
    }

    return result;
  }
}
