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
  String currency = 'INR';
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
      'transaction_date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'transaction_time': "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}",
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'sync_version': syncVersion,
    };
  }

  static TransactionModel fromJson(Map<String, dynamic> json) {
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

    return TransactionModel()
      ..uuid = json['id'] as String? ?? ''
      ..accountId = json['account_id'] as String? ?? ''
      ..type = json['type'] as String? ?? 'expense'
      ..categoryId = json['category_id'] as String? ?? json['category'] as String? ?? ''
      ..category = json['category'] as String? ?? json['category_id'] as String? ?? ''
      ..amount = (json['amount'] as num?)?.toDouble() ?? 0.0
      ..title = json['title'] as String? ?? json['description'] as String? ?? ''
      ..description = json['description'] as String? ?? ''
      ..currency = json['currency'] as String? ?? 'INR'
      ..paymentMethod = json['payment_method'] as String? ?? 'Cash'
      ..receiptUrl = json['receipt_url'] as String?
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..isSynced = json['is_synced'] as bool? ?? true
      ..isRecurring = json['is_recurring'] as bool? ?? false
      ..isSystem = json['is_system'] as bool? ?? false
      ..date = dateVal
      ..createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()
      ..updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now()
      ..userId = json['user_id'] as String?
      ..syncVersion = (json['sync_version'] as num?)?.toInt() ?? 1;
  }
}
