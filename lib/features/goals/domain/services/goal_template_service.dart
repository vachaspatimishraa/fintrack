import 'package:fintrack/features/goals/domain/repositories/goal_repository.dart';

class GoalTemplateService {
  final GoalRepository repository;

  GoalTemplateService(this.repository);

  Future<void> apply(String templateId) async {
    // Logic to create a goal from a template
  }
}
