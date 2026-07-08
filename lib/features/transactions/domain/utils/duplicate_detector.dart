import '../../domain/entities/transaction_entity.dart';

class DuplicateDetector {
  static bool isPotentialDuplicate({
    required TransactionEntity candidate,
    required List<TransactionEntity> existingList,
  }) {
    for (final tx in existingList) {
      if (tx.uuid == candidate.uuid) continue;

      final isSameAmount = (tx.amount - candidate.amount).abs() < 0.01;
      final isSameTitle = tx.title.trim().toLowerCase() == candidate.title.trim().toLowerCase();
      final isSameCategory = tx.category.trim().toLowerCase() == candidate.category.trim().toLowerCase();
      
      final isSameDay = tx.date.year == candidate.date.year &&
          tx.date.month == candidate.date.month &&
          tx.date.day == candidate.date.day;

      if (isSameAmount && isSameTitle && isSameCategory && isSameDay) {
        return true;
      }
    }
    return false;
  }
}
