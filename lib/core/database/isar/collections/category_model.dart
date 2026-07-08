import 'package:isar/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  String userId = '';
  String name = '';
  String type = 'expense'; // income, expense, etc.
  String icon = 'category';
  String color = '#9E9E9E'; // HEX string

  bool isDefault = false;
  bool isDeleted = false;
  bool isSynced = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  int syncVersion = 1;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'user_id': userId,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'is_default': isDefault,
      'is_deleted': isDeleted,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'sync_version': syncVersion,
    };
  }

  static CategoryModel fromJson(Map<String, dynamic> json) {
    return CategoryModel()
      ..uuid = json['id'] as String? ?? ''
      ..userId = json['user_id'] as String? ?? ''
      ..name = json['name'] as String? ?? ''
      ..type = json['type'] as String? ?? 'expense'
      ..icon = json['icon'] as String? ?? 'category'
      ..color = json['color'] as String? ?? '#9E9E9E'
      ..isDefault = json['is_default'] as bool? ?? false
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..isSynced = json['is_synced'] as bool? ?? true
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String)
      ..syncVersion = json['sync_version'] as int? ?? 1;
  }
}
