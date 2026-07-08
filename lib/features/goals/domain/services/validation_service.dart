import '../entities/goal_entity.dart';

class ValidationService {
  static String? validateGoal(GoalEntity goal) {
    if (goal.title.isEmpty) return 'Goal title is required';
    if (goal.targetAmount <= 0) return 'Target amount must be greater than zero';
    if (goal.deadline.isBefore(goal.startDate)) return 'Deadline must be after start date';
    return null;
  }
}
