import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/goal_model.dart';
import '../../../domain/repositories/goals_local_datasource.dart';

class GoalsLocalDatasourceImpl implements GoalsLocalDatasource {
  final Isar _isar;

  GoalsLocalDatasourceImpl(this._isar);

  @override
  Future<void> saveGoal(GoalModel goal) async {
    await _isar.writeTxn(() => _isar.goalModels.put(goal));
  }

  @override
  Future<List<GoalModel>> loadGoals(String ownerId) async {
    return _isar.goalModels.filter().ownerIdEqualTo(ownerId).findAll();
  }

  @override
  Stream<List<GoalModel>> watchGoals(String ownerId) {
    return _isar.goalModels.filter().ownerIdEqualTo(ownerId).watch(fireImmediately: true);
  }

  @override
  Future<GoalModel?> findGoalByUuid(String uuid) async {
    return _isar.goalModels.filter().uuidEqualTo(uuid).findFirst();
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    await _isar.writeTxn(() async {
      await _isar.goalModels.filter().uuidEqualTo(goalId).deleteFirst();
    });
  }

  @override
  Future<List<MilestoneModel>> loadMilestones(String goalId) async {
    return _isar.milestoneModels.filter().goalIdEqualTo(goalId).findAll();
  }

  @override
  Future<void> saveMilestone(MilestoneModel milestone) async {
    await _isar.writeTxn(() => _isar.milestoneModels.put(milestone));
  }

  @override
  Future<void> deleteMilestone(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.milestoneModels.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  @override
  Future<List<ContributionModel>> loadContributions(String goalId) async {
    return _isar.contributionModels.filter().goalIdEqualTo(goalId).findAll();
  }

  @override
  Future<void> saveContribution(ContributionModel contribution) async {
    await _isar.writeTxn(() => _isar.contributionModels.put(contribution));
  }

  @override
  Future<void> deleteContribution(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.contributionModels.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }
}
