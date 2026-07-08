class TransactionDto {
  final String uuid;
  final String accountId;
  final String type;
  final String categoryId;
  final String category;
  final double amount;
  final String title;
  final String currency;
  final String paymentMethod;
  final DateTime date;

  const TransactionDto({
    required this.uuid,
    required this.accountId,
    required this.type,
    required this.categoryId,
    required this.category,
    required this.amount,
    required this.title,
    required this.currency,
    required this.paymentMethod,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'accountId': accountId,
      'type': type,
      'categoryId': categoryId,
      'category': category,
      'amount': amount,
      'title': title,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
    };
  }
}
