import '../repositories/goal_repository.dart';

class GoalTemplateService {
  final GoalRepository _repository;

  GoalTemplateService(this._repository);

  Future<void> apply(String templateId) async {
    // Logic to create a goal from a template
  }
}
