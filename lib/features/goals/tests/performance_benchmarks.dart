import 'package:flutter_test/flutter_test.dart';
import '../domain/utils/goal_optimization_engine.dart';
import '../domain/entities/goal_entity.dart';

void main() {
  group('Goals Module Performance Benchmarks', () {
    test('Goal filtering and sorting should be under 40ms for 1000 goals', () async {
      final goals = List.generate(1000, (i) => GoalEntity(
        uuid: 'uuid-$i',
        ownerId: 'user-1',
        title: 'Goal $i',
        targetAmount: 1000,
        currentAmount: 100,
        currency: 'USD',
        startDate: DateTime.now(),
        deadline: DateTime.now().add(const Duration(days: 30)),
        status: i % 2 == 0 ? 'active' : 'completed',
        priority: (i % 5) + 1,
        category: 'Savings',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final stopwatch = Stopwatch()..start();
      
      await GoalOptimizationEngine.processGoals(
        goals,
        query: 'Goal 1',
        sortBy: 'priority',
        filterStatus: 'active',
      );
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(40));
    });
  });
}
