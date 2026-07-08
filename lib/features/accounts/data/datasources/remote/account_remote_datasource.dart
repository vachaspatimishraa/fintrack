import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRemoteDataSource {
  final SupabaseClient _supabase;

  AccountRemoteDataSource(this._supabase);

  Future<List<Map<String, dynamic>>> fetchAccounts(String userId) async {
    final response = await _supabase
        .from('accounts')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertAccount(Map<String, dynamic> jsonPayload) async {
    await _supabase.from('accounts').upsert(jsonPayload);
  }

  Future<void> deleteAccount(String uuid) async {
    await _supabase.from('accounts').delete().eq('id', uuid);
  }
}
