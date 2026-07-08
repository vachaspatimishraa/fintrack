class TransactionEntity {
  final String uuid;
  final String accountId;
  final String type; // income, expense
  final String categoryId;
  final String category; // preserves backward compatibility
  final double amount;
  final String title;
  final String description;
  final String currency;
  final String paymentMethod;
  final String? receiptUrl;
  final String? receiptLocalPath;
  final bool isDeleted;
  final bool isSynced;
  final bool isRecurring;
  final bool isSystem;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;
  final int syncVersion;
  final List<String> tags;

  TransactionEntity({
    String? uuid,
    String? id,
    String? accountId,
    required this.type,
    String? categoryId,
    required this.category,
    required this.amount,
    String? title,
    String? merchant,
    String? description,
    String? currency,
    String? paymentMethod,
    this.receiptUrl,
    this.receiptLocalPath,
    this.isDeleted = false,
    bool? isSynced,
    bool? isRecurring,
    bool? isSystem,
    required this.date,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.userId,
    int? syncVersion,
    String? categoryColor,
    String? categoryIcon,
    this.tags = const [],
  })  : uuid = uuid ?? id ?? '',
        accountId = accountId ?? '',
        categoryId = categoryId ?? category,
        title = title ?? merchant ?? '',
        description = description ?? '',
        currency = currency ?? 'INR',
        paymentMethod = paymentMethod ?? 'cash',
        isSynced = isSynced ?? false,
        isRecurring = isRecurring ?? false,
        isSystem = isSystem ?? false,
        createdAt = createdAt ?? date,
        updatedAt = updatedAt ?? date,
        syncVersion = syncVersion ?? 1;

  String get merchant => title;

  String get categoryColor {
    const palette = [
      '#6750A4',
      '#006A6A',
      '#B3261E',
      '#386A20',
      '#7D5260',
      '#625B71',
      '#005DB7',
      '#8C5000',
      '#006D3B',
      '#7F4E1D',
    ];
    final seed = category.isEmpty ? categoryId : category;
    final index = seed.codeUnits.fold<int>(0, (sum, code) => sum + code) %
        palette.length;
    return palette[index];
  }

  String get categoryIcon => categoryId.isNotEmpty ? categoryId : category;

  TransactionEntity copyWith({
    String? uuid,
    String? accountId,
    String? type,
    String? categoryId,
    String? category,
    double? amount,
    String? title,
    String? description,
    String? currency,
    String? paymentMethod,
    String? receiptUrl,
    String? receiptLocalPath,
    bool? isDeleted,
    bool? isSynced,
    bool? isRecurring,
    bool? isSystem,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    int? syncVersion,
    List<String>? tags,
  }) {
    return TransactionEntity(
      uuid: uuid ?? this.uuid,
      accountId: accountId ?? this.accountId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      description: description ?? this.description,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptLocalPath: receiptLocalPath ?? this.receiptLocalPath,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      isRecurring: isRecurring ?? this.isRecurring,
      isSystem: isSystem ?? this.isSystem,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      syncVersion: syncVersion ?? this.syncVersion,
      tags: tags ?? this.tags,
    );
  }

  TransactionEntity clearReceipt() {
    return TransactionEntity(
      uuid: uuid,
      accountId: accountId,
      type: type,
      categoryId: categoryId,
      category: category,
      amount: amount,
      title: title,
      description: description,
      currency: currency,
      paymentMethod: paymentMethod,
      receiptUrl: null,
      receiptLocalPath: null,
      isDeleted: isDeleted,
      isSynced: isSynced,
      isRecurring: isRecurring,
      isSystem: isSystem,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      syncVersion: syncVersion,
    );
  }
}
