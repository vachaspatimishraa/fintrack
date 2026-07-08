import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'isar/collections/account_model.dart';
import 'isar/collections/transaction_model.dart';
import 'isar/collections/sync_queue_item.dart';
import 'isar/collections/category_model.dart';
import 'isar/collections/receipt_model.dart';
import 'isar/collections/budget_model.dart';
import 'isar/collections/budget_recommendation_model.dart';
import 'isar/collections/settings_model.dart';
import 'isar/collections/backup_history_model.dart';
import 'isar/collections/goal_model.dart';

import 'package:flutter/foundation.dart';

class IsarInitializationService {
  Isar? _isar;

  Isar get isar {
    if (_isar == null) {
      throw StateError('Isar database has not been initialized yet.');
    }
    return _isar!;
  }

  Future<void> initialize() async {
    if (_isar != null) return;
    
    String? path;
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      path = dir.path;
    }
    _isar = await Isar.open(
      [
        AccountModelSchema,
        TransactionModelSchema,
        SyncQueueItemSchema,
        CategoryModelSchema,
        ReceiptModelSchema,
        BudgetModelSchema,
        BudgetCategoryModelSchema,
        BudgetHistoryModelSchema,
        BudgetAlertModelSchema,
        BudgetRecommendationModelSchema,
        SettingsModelSchema,
        BackupHistoryModelSchema,
        GoalModelSchema,
        MilestoneModelSchema,
        ContributionModelSchema,
        GoalHistoryModelSchema,
      ],
      directory: path ?? "",
    );
  }
}
