import 'package:isar/isar.dart';

part 'account_model.g.dart';

@collection
class AccountModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  String name = '';
  String type = 'Cash'; // cash, bank, card, savings, etc.
  double balance = 0.0;
  String icon = 'wallet';
  int colorValue = 0xFF3F51B5;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String? userId;
  bool isSynced = false;

  bool isArchived = false;
  bool isDeleted = false;
  String? notes;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'name': name,
      'type': type,
      'balance': balance,
      'icon': icon,
      'color_value': colorValue,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
      'is_archived': isArchived,
      'is_deleted': isDeleted,
      'notes': notes,
    };
  }

  static AccountModel fromJson(Map<String, dynamic> json) {
    return AccountModel()
      ..uuid = json['id'] as String
      ..name = json['name'] as String
      ..type = json['type'] as String
      ..balance = (json['balance'] as num).toDouble()
      ..icon = json['icon'] as String
      ..colorValue = json['color_value'] as int
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String)
      ..userId = json['user_id'] as String?
      ..isArchived = json['is_archived'] as bool? ?? false
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..notes = json['notes'] as String?
      ..isSynced = true;
  }
}
