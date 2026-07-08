import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'collections/account_model.dart';
import 'collections/transaction_model.dart';
import 'collections/sync_queue_item.dart';
import 'collections/budget_model.dart';

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
