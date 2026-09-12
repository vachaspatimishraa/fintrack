import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/budget/data/mappers/budget_mapper.dart';
import 'package:fintrack/features/budget/data/datasources/local/budget_local_datasource.dart';

class BudgetPaginationService {
  final BudgetLocalDatasource _localDatasource;

  BudgetPaginationService(this._localDatasource);

  Future<List<BudgetEntity>> fetchPage({
    required String? ownerId,
    required int limit,
    required int offset,
    String? status,
    String? budgetType,
  }) async {
    final models = await _localDatasource.getBudgetsPaginated(
      ownerId: ownerId,
      limit: limit,
      offset: offset,
      status: status,
      budgetType: budgetType,
    );
    return models.map(BudgetMapper.toEntity).toList();
  }
}
