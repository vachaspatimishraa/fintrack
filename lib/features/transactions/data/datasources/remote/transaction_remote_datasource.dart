import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../mappers/transaction_mapper.dart';

class TransactionRemoteDataSource {
  final SupabaseClient _supabase;

  TransactionRemoteDataSource(this._supabase);

  Future<void> upsertTransaction(TransactionEntity transaction) async {
    try {
      final payload = TransactionMapper.toJson(transaction);
      await _supabase.from('transactions').upsert(payload);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  Future<void> deleteTransaction(String uuid) async {
    try {
      await _supabase.from('transactions').delete().eq('id', uuid);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  Future<List<TransactionEntity>> fetchTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);
      
      return (response as List? ?? [])
          .map((json) {
            try {
              return TransactionMapper.fromJson(json as Map<String, dynamic>);
            } catch (e, stack) {
              debugPrint("========== MAPPING ERROR ==========");
              debugPrint(e.toString());
              debugPrintStack(stackTrace: stack);
              debugPrint("===================================");
              rethrow;
            }
          })
          .whereType<TransactionEntity>()
          .toList();
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }
}
