import 'package:isar/isar.dart';

part 'goal_model.g.dart';

@collection
class GoalModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index(composite: [CompositeIndex('status'), CompositeIndex('deadline')])
  String ownerId = '';

  String title = '';
  String? description;
  
  double targetAmount = 0.0;
  double currentAmount = 0.0;
  String currency = 'INR';
  
  @Index()
  DateTime startDate = DateTime.now();
  
  @Index()
  DateTime deadline = DateTime.now();
  
  @Index()
  String status = 'active'; // active, completed, archived, abandoned
  
  @Index(composite: [CompositeIndex('ownerId')])
  int priority = 3; // 1-5
  
  String category = '';
  String? color;
  String? icon;

  DateTime createdAt = DateTime.now();
  
  @Index()
  DateTime updatedAt = DateTime.now();
  
  bool isDeleted = false;
  String syncStatus = 'pending';
  int version = 1;

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'user_id': ownerId,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'currency': currency,
      'start_date': startDate.toIso8601String(),
      'deadline': deadline.toIso8601String(),
      'status': status,
      'priority': priority,
      'category': category,
      'color': color,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
      'sync_status': syncStatus,
      'version': version,
    };
  }

  static GoalModel fromJson(Map<String, dynamic> json) {
    return GoalModel()
      ..uuid = json['id'] as String? ?? ''
      ..ownerId = (json['user_id'] ?? json['owner_id']) as String? ?? ''
      ..title = json['title'] as String? ?? ''
      ..description = json['description'] as String?
      ..targetAmount = (json['target_amount'] as num?)?.toDouble() ?? 0.0
      ..currentAmount = (json['current_amount'] as num?)?.toDouble() ?? 0.0
      ..currency = json['currency'] as String? ?? 'INR'
      ..startDate = json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : DateTime.now()
      ..deadline = json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : DateTime.now()
      ..status = json['status'] as String? ?? 'active'
      ..priority = (json['priority'] as num?)?.toInt() ?? 3
      ..category = json['category'] as String? ?? ''
      ..color = json['color'] as String?
      ..icon = json['icon'] as String?
      ..createdAt = json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now()
      ..updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now()
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..syncStatus = json['sync_status'] as String? ?? 'synced'
      ..version = (json['version'] as num?)?.toInt() ?? 1;
  }
}

@collection
class MilestoneModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index(composite: [CompositeIndex('updatedAt')])
  String goalId = '';

  String title = '';
  double targetAmount = 0.0;
  bool isCompleted = false;
  DateTime? completedAt;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@collection
class ContributionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index(composite: [CompositeIndex('createdAt')])
  String goalId = '';

  double amount = 0.0;
  String? note;
  String? transactionId;
  
  @Index()
  DateTime createdAt = DateTime.now();
}

@collection
class GoalHistoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String goalId = '';

  String action = ''; // created, contribution, milestone_reached, status_changed
  String? oldValue;
  String? newValue;
  
  @Index()
  DateTime timestamp = DateTime.now();
}
