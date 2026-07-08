import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String accountId = '';

  String type = 'expense'; // income, expense
  
  @Index()
  String categoryId = '';
  
  String category = ''; // keeps compatibility with existing pages
  
  double amount = 0.0;
  String title = '';
  String description = '';
  String currency = 'USD';
  String paymentMethod = 'Cash';
  
  String? receiptUrl;
  String? receiptLocalPath;
  
  bool isDeleted = false;
  bool isSynced = false;
  bool isRecurring = false;
  bool isSystem = false;
  List<String> tags = [];
  
  DateTime date = DateTime.now(); // transaction date
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String? userId;
  int syncVersion = 1;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'account_id': accountId,
      'type': type,
      'category_id': categoryId,
      'category': category,
      'amount': amount,
      'title': title,
      'description': description,
      'currency': currency,
      'payment_method': paymentMethod,
      'receipt_url': receiptUrl,
      'is_deleted': isDeleted,
      'is_synced': isSynced,
      'is_recurring': isRecurring,
      'is_system': isSystem,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'sync_version': syncVersion,
    };
  }

  static TransactionModel fromJson(Map<String, dynamic> json) {
    return TransactionModel()
      ..uuid = json['id'] as String
      ..accountId = json['account_id'] as String
      ..type = json['type'] as String
      ..categoryId = json['category_id'] as String? ?? json['category'] as String? ?? ''
      ..category = json['category'] as String? ?? json['category_id'] as String? ?? ''
      ..amount = (json['amount'] as num?)?.toDouble() ?? 0.0
      ..title = json['title'] as String? ?? json['description'] as String? ?? ''
      ..description = json['description'] as String? ?? ''
      ..currency = json['currency'] as String? ?? 'USD'
      ..paymentMethod = json['payment_method'] as String? ?? 'Cash'
      ..receiptUrl = json['receipt_url'] as String?
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..isSynced = json['is_synced'] as bool? ?? true
      ..isRecurring = json['is_recurring'] as bool? ?? false
      ..isSystem = json['is_system'] as bool? ?? false
      ..date = DateTime.parse(json['date'] as String)
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String)
      ..userId = json['user_id'] as String?
      ..syncVersion = json['sync_version'] as int? ?? 1;
  }
}
