class TransactionHistoryModel {
  final String uuid;
  final String transactionUuid;
  final String action; // create, edit, delete, restore, duplicate
  final DateTime timestamp;
  final String? details;

  const TransactionHistoryModel({
    required this.uuid,
    required this.transactionUuid,
    required this.action,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'transaction_uuid': transactionUuid,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
      'details': details,
    };
  }

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      uuid: json['uuid'] as String,
      transactionUuid: json['transaction_uuid'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'] as String?,
    );
  }
}
