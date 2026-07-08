import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/budget_entity.dart';
import '../../../domain/entities/budget_api_contract.dart';
import '../../mappers/budget_mapper.dart';

/// Contract-compliant remote datasource for Budget synchronization.
class BudgetRemoteDataSource {
  final SupabaseClient _supabase;

  BudgetRemoteDataSource(this._supabase);

  /// Uploads (upserts) a budget to Supabase.
  Future<void> upload(BudgetEntity budget) async {
    final payload = BudgetMapper.toJson(budget);
    await _supabase.from(BudgetApiContract.tableBudgets).upsert(payload);
  }

  /// Downloads all budgets for a user from Supabase.
  Future<List<BudgetEntity>> download(String userId) async {
    final response = await _supabase
        .from(BudgetApiContract.tableBudgets)
        .select()
        .eq(BudgetApiContract.fOwnerId, userId);
    
    return (response as List)
        .map((json) => BudgetMapper.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Marks a budget as deleted on the remote server.
  Future<void> softDelete(String uuid) async {
    await _supabase.from(BudgetApiContract.tableBudgets).update({
      'is_deleted': true,
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq(BudgetApiContract.fId, uuid);
  }

  /// Restores a deleted budget on the remote server.
  Future<void> restore(String uuid) async {
    await _supabase.from(BudgetApiContract.tableBudgets).update({
      'is_deleted': false,
      'deleted_at': null,
    }).eq(BudgetApiContract.fId, uuid);
  }
}
