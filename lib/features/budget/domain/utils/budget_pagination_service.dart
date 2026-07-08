import '../../domain/entities/budget_entity.dart';
import '../../data/mappers/budget_mapper.dart';
import '../../data/datasources/local/budget_local_datasource.dart';

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
    return models.map((m) => BudgetMapper.toEntity(m)).toList();
  }
}
