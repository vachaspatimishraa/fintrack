import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/goals/domain/repositories/goals_api_contracts.dart';

class MockGoalsRepository implements GoalsRepository {
  final List<GoalModel> _list = [];

  @override
  Future<void> createGoal(GoalModel goal) async {
    _list.add(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    _list.removeWhere((g) => g.id == goalId);
  }

  @override
  Future<GoalModel> getGoal(String goalId) async {
    return _list.firstWhere((g) => g.id == goalId);
  }

  @override
  Future<List<GoalModel>> loadGoals() async => _list;

  @override
  Stream<List<GoalModel>> watchGoals() => Stream.value(_list);

  @override
  Future<void> updateGoal(GoalModel goal) async {}
}

class MockGoalEngine implements GoalEngine {
  @override
  Future<GoalProgressModel> calculateProgress(String goalId) async {
    return const GoalProgressModel(completionPercentage: 80.0, savingsRate: 500.0);
  }

  @override
  Future<GoalForecastModel> forecast(String goalId) async {
    return GoalForecastModel(projectedCompletionDate: DateTime.now(), confidenceScore: 0.9);
  }
}

void main() {
  group('Goals Contracts Compliance Tests', () {
    test('satisfies abstract signatures for GoalsRepository and GoalEngine', () async {
      final repo = MockGoalsRepository();
      final engine = MockGoalEngine();

      final goal = GoalModel(
        id: '1',
        name: 'New Car',
        targetAmount: 20000.0,
        currentAmount: 5000.0,
        deadline: DateTime.now(),
        status: 'Active',
        updatedAt: DateTime.now(),
      );

      await repo.createGoal(goal);
      final list = await repo.loadGoals();

      expect(list.length, 1);
      expect(list.first.name, 'New Car');

      final progress = await engine.calculateProgress('1');
      expect(progress.completionPercentage, 80.0);
    });
  });
}
