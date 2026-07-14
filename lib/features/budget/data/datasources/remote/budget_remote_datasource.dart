import 'package:flutter/foundation.dart';
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
    try {
       final payload = BudgetMapper.toJson(budget);
       await _supabase.from(BudgetApiContract.tableBudgets).upsert(payload);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  /// Downloads all budgets for a user from Supabase.
  Future<List<BudgetEntity>> download(String userId) async {
    try {
      final response = await _supabase
          .from(BudgetApiContract.tableBudgets)
          .select()
          .eq(BudgetApiContract.fOwnerId, userId);
      
      return (response as List? ?? [])
          .map((json) {
            try {
              return BudgetMapper.fromJson(json as Map<String, dynamic>);
            } catch (e, stack) {
              debugPrint("========== MAPPING ERROR ==========");
              debugPrint(e.toString());
              debugPrintStack(stackTrace: stack);
              debugPrint("===================================");
              rethrow;
            }
          })
          .whereType<BudgetEntity>()
          .toList();
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  /// Marks a budget as deleted on the remote server.
  Future<void> softDelete(String uuid) async {
    try {
      await _supabase.from(BudgetApiContract.tableBudgets).update({
        'is_deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq(BudgetApiContract.fId, uuid);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  /// Restores a deleted budget on the remote server.
  Future<void> restore(String uuid) async {
    try {
      await _supabase.from(BudgetApiContract.tableBudgets).update({
        'is_deleted': false,
        'deleted_at': null,
      }).eq(BudgetApiContract.fId, uuid);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }
}
