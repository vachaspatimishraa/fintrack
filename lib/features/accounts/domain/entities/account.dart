class Account {
  final String uuid;
  final String name;
  final String type;
  final double balance;
  final String icon;
  final int colorValue;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userId;

  const Account({
    required this.uuid,
    required this.name,
    required this.type,
    required this.balance,
    required this.icon,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
  });
}
