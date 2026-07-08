import '../../domain/entities/transaction_entity.dart';

class ImportService {
  static List<TransactionEntity> parseCsv(String csvContent) {
    final List<TransactionEntity> list = [];
    final lines = csvContent.split('\n');
    if (lines.length <= 1) return list;

    // Skip header line
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = line.split(',');
      if (cols.length >= 5) {
        try {
          final date = DateTime.parse(cols[0].trim());
          final amount = double.parse(cols[1].trim());
          final title = cols[2].trim();
          final category = cols[3].trim();
          final paymentMethod = cols[4].trim();

          list.add(TransactionEntity(
            uuid: '',
            accountId: 'wallet',
            type: amount < 0 ? 'expense' : 'income',
            categoryId: category,
            category: category,
            amount: amount.abs(),
            title: title,
            description: 'Imported transaction',
            currency: 'USD',
            paymentMethod: paymentMethod,
            isDeleted: false,
            isSynced: false,
            isRecurring: false,
            date: date,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncVersion: 1,
          ));
        } catch (_) {}
      }
    }
    return list;
  }
}
