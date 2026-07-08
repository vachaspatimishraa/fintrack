import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../mappers/transaction_mapper.dart';

class TransactionRemoteDataSource {
  final SupabaseClient _supabase;

  TransactionRemoteDataSource(this._supabase);

  Future<void> upsertTransaction(TransactionEntity transaction) async {
    final payload = TransactionMapper.toJson(transaction);
    await _supabase.from('transactions').upsert(payload);
  }

  Future<void> deleteTransaction(String uuid) async {
    await _supabase.from('transactions').delete().eq('id', uuid);
  }

  Future<List<TransactionEntity>> fetchTransactions(String userId) async {
    final response = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId);
    
    return (response as List)
        .map((json) => TransactionMapper.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
