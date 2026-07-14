import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionMapper {
  static TransactionEntity toEntity(TransactionModel model) {
    return TransactionEntity(
      uuid: model.uuid,
      accountId: model.accountId,
      type: model.type,
      categoryId: model.categoryId,
      category: model.category,
      amount: model.amount,
      title: model.title,
      description: model.description,
      currency: model.currency,
      paymentMethod: model.paymentMethod,
      receiptUrl: model.receiptUrl,
      receiptLocalPath: model.receiptLocalPath,
      isDeleted: model.isDeleted,
      isSynced: model.isSynced,
      isRecurring: model.isRecurring,
      isSystem: model.isSystem,
      date: model.date,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      userId: model.userId,
      syncVersion: model.syncVersion,
      tags: model.tags,
    );
  }

  static TransactionModel toModel(TransactionEntity entity) {
    return TransactionModel()
      ..uuid = entity.uuid
      ..accountId = entity.accountId
      ..type = entity.type
      ..categoryId = entity.categoryId
      ..category = entity.category
      ..amount = entity.amount
      ..title = entity.title
      ..description = entity.description
      ..currency = entity.currency
      ..paymentMethod = entity.paymentMethod
      ..receiptUrl = entity.receiptUrl
      ..receiptLocalPath = entity.receiptLocalPath
      ..isDeleted = entity.isDeleted
      ..isSynced = entity.isSynced
      ..isRecurring = entity.isRecurring
      ..isSystem = entity.isSystem
      ..date = entity.date
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..userId = entity.userId
      ..syncVersion = entity.syncVersion
      ..tags = entity.tags;
  }

  static TransactionEntity fromJson(Map<String, dynamic> json) {
    DateTime dateVal = DateTime.now();
    try {
      if (json['transaction_date'] != null) {
        final dateStr = json['transaction_date'] as String;
        final timeStr = (json['transaction_time'] as String?) ?? '00:00:00';
        dateVal = DateTime.parse('${dateStr}T$timeStr');
      } else if (json['date'] != null) {
        dateVal = DateTime.parse(json['date'] as String);
      }
    } catch (_) {}

    return TransactionEntity(
      uuid: json['id'] as String? ?? json['uuid'] as String? ?? '',
      accountId: json['account_id'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      categoryId: json['category_id'] as String? ?? json['category'] as String? ?? '',
      category: json['category'] as String? ?? json['category_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? json['description'] as String? ?? '',
      description: json['description'] as String? ?? '',
      currency: json['currency'] as String? ?? 'INR',
      paymentMethod: json['payment_method'] as String? ?? 'Cash',
      receiptUrl: json['receipt_url'] as String?,
      receiptLocalPath: json['receipt_local_path'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      isSynced: json['is_synced'] as bool? ?? true,
      isRecurring: json['is_recurring'] as bool? ?? false,
      isSystem: json['is_system'] as bool? ?? false,
      date: dateVal,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      userId: json['user_id'] as String?,
      syncVersion: (json['sync_version'] as num?)?.toInt() ?? 1,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  static Map<String, dynamic> toJson(TransactionEntity entity) {
    return {
      'id': entity.uuid,
      'account_id': entity.accountId,
      'type': entity.type,
      'category_id': entity.categoryId,
      'category': entity.category,
      'amount': entity.amount,
      'title': entity.title,
      'description': entity.description,
      'currency': entity.currency,
      'payment_method': entity.paymentMethod,
      'receipt_url': entity.receiptUrl,
      'is_deleted': entity.isDeleted,
      'is_synced': entity.isSynced,
      'is_recurring': entity.isRecurring,
      'is_system': entity.isSystem,
      'transaction_date': "${entity.date.year.toString().padLeft(4, '0')}-${entity.date.month.toString().padLeft(2, '0')}-${entity.date.day.toString().padLeft(2, '0')}",
      'transaction_time': "${entity.date.hour.toString().padLeft(2, '0')}:${entity.date.minute.toString().padLeft(2, '0')}:${entity.date.second.toString().padLeft(2, '0')}",
      'created_at': entity.createdAt.toIso8601String(),
      'updated_at': entity.updatedAt.toIso8601String(),
      'user_id': entity.userId,
      'sync_version': entity.syncVersion,
    };
  }
}
