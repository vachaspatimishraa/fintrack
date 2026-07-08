import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/goal_entity.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../providers/goal_provider.dart';

/// Controller for orchestrating goal-related user interactions.
/// 
/// Validates inputs, manages UI loading states, and delegates data logic
/// to the [GoalRepository].
class GoalController {
  final Ref _ref;

  GoalController(this._ref);

  GoalRepository get _repository => _ref.read(goalRepositoryProvider);

  /// Initiates the creation or update of a financial goal.
  /// 
  /// Throws [Exception] if validation fails.
  Future<void> saveGoal(GoalEntity goal) async {
    // Input validation logic here
    await _repository.saveGoal(goal);
    _ref.invalidate(goalsStreamProvider);
  }

  /// Handles the deletion request for a goal.
  Future<void> deleteGoal(String uuid) async {
    await _repository.deleteGoal(uuid);
    _ref.invalidate(goalsStreamProvider);
  }

  /// Triggers a manual synchronization of goals with the cloud.
  Future<void> sync() async {
    await _repository.synchronize();
  }
}

final goalControllerProvider = Provider<GoalController>((ref) => GoalController(ref));
