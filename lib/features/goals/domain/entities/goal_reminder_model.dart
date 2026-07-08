class GoalReminderModel {
  final String uuid;
  final String goalId;
  final String title;
  final String message;
  final DateTime scheduledDate;
  final String repeatInterval; // Daily, Weekly, Monthly, None
  final bool isEnabled;

  const GoalReminderModel({
    required this.uuid,
    required this.goalId,
    required this.title,
    required this.message,
    required this.scheduledDate,
    required this.repeatInterval,
    this.isEnabled = true,
  });

  GoalReminderModel copyWith({
    String? uuid,
    String? goalId,
    String? title,
    String? message,
    DateTime? scheduledDate,
    String? repeatInterval,
    bool? isEnabled,
  }) {
    return GoalReminderModel(
      uuid: uuid ?? this.uuid,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      message: message ?? this.message,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      repeatInterval: repeatInterval ?? this.repeatInterval,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
