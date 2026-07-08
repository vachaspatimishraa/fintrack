import '../../domain/entities/transaction_entity.dart';

class SplitLine {
  final String categoryId;
  final String category;
  final double amount;

  const SplitLine({
    required this.categoryId,
    required this.category,
    required this.amount,
  });
}

class SplitTransactionService {
  static List<TransactionEntity> split(TransactionEntity parent, List<SplitLine> splits) {
    final totalSplits = splits.fold<double>(0, (p, e) => p + e.amount);
    if ((totalSplits - parent.amount).abs() > 0.01) {
      throw ArgumentError('Splits total must match the parent transaction amount.');
    }

    return splits.map((line) {
      return parent.copyWith(
        uuid: '',
        categoryId: line.categoryId,
        category: line.category,
        amount: line.amount,
        isSynced: false,
      );
    }).toList();
  }
}
