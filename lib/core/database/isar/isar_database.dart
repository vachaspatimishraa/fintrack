import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';
import 'package:fintrack/core/database/isar/collections/transaction_model.dart';
import 'package:fintrack/core/database/isar/collections/sync_queue_item.dart';
import 'package:fintrack/core/database/isar/collections/budget_model.dart';

class IsarDatabase {
  static late final Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        AccountModelSchema,
        TransactionModelSchema,
        SyncQueueItemSchema,
        BudgetModelSchema,
      ],
      directory: dir.path,
    );
  }
}
