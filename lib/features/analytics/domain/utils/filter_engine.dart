import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/custom_report_data.dart';

class FilterEngine {
  const FilterEngine._();

  static List<TransactionEntity> filter({
    required List<TransactionEntity> transactions,
    required CustomReportFilter filter,
  }) {
    return transactions.where((tx) {
      if (tx.isDeleted) return false;

      // Date Range Filter
      if (filter.startDate != null && tx.date.isBefore(filter.startDate!)) {
        return false;
      }
      if (filter.endDate != null && tx.date.isAfter(filter.endDate!)) {
        return false;
      }

      // Accounts Filter
      if (filter.selectedAccounts.isNotEmpty && !filter.selectedAccounts.contains(tx.accountId)) {
        return false;
      }

      // Categories Filter
      if (filter.selectedCategories.isNotEmpty && !filter.selectedCategories.contains(tx.category)) {
        return false;
      }

      // Types Filter
      if (filter.selectedTypes.isNotEmpty && !filter.selectedTypes.contains(tx.type)) {
        return false;
      }

      // Amount Filter
      if (filter.minAmount != null && tx.amount < filter.minAmount!) {
        return false;
      }
      if (filter.maxAmount != null && tx.amount > filter.maxAmount!) {
        return false;
      }

      // Search Query Filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchTitle = tx.title.toLowerCase().contains(query);
        final matchDesc = tx.description.toLowerCase().contains(query);
        final matchCat = tx.category.toLowerCase().contains(query);
        if (!matchTitle && !matchDesc && !matchCat) {
          return false;
        }
      }

      // Payment Method Filter
      if (filter.paymentMethod != null && filter.paymentMethod!.isNotEmpty) {
        if (tx.paymentMethod.toLowerCase() != filter.paymentMethod!.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
