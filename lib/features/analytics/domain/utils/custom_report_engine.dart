import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/custom_report_data.dart';
import 'filter_engine.dart';
import 'grouping_engine.dart';
import 'statistics_engine.dart';

class CustomReportEngine {
  const CustomReportEngine._();

  static CustomReportDataset generate({
    required List<TransactionEntity> transactions,
    required CustomReportFilter filter,
    required String groupBy,
    required String sortBy,
  }) {
    // 1. Filter data
    final filtered = FilterEngine.filter(
      transactions: transactions,
      filter: filter,
    );

    if (filtered.isEmpty) {
      return CustomReportDataset(
        filter: filter,
        stats: CustomReportStats.zero(),
        transactions: const [],
        groups: const [],
        isEmpty: true,
      );
    }

    // 2. Sort data
    final sorted = List<TransactionEntity>.from(filtered);
    switch (sortBy.toLowerCase()) {
      case 'oldest':
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'highestamount':
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'lowestamount':
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'category':
        sorted.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'account':
        sorted.sort((a, b) => a.accountId.compareTo(b.accountId));
        break;
      case 'newest':
      default:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
    }

    // 3. Group data
    final groups = GroupingEngine.group(
      transactions: sorted,
      groupBy: groupBy,
    );

    // 4. Calculate statistics
    final stats = StatisticsEngine.calculate(sorted);

    return CustomReportDataset(
      filter: filter,
      stats: stats,
      transactions: sorted,
      groups: groups,
      isEmpty: false,
    );
  }
}
