import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRemoteDataSource {
  final SupabaseClient _supabase;

  AccountRemoteDataSource(this._supabase);

  Future<List<Map<String, dynamic>>> fetchAccounts(String userId) async {
    try {
      final response = await _supabase
          .from('accounts')
          .select()
          .eq('user_id', userId);
      return List<Map<String, dynamic>>.from(response as List? ?? []);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  Future<void> upsertAccount(Map<String, dynamic> jsonPayload) async {
    try {
      await _supabase.from('accounts').upsert(jsonPayload);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }

  Future<void> deleteAccount(String uuid) async {
    try {
      await _supabase.from('accounts').update({
        'is_deleted': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', uuid);
    } catch (e, stack) {
      debugPrint("========== REMOTE DATASOURCE ERROR ==========");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stack);
      debugPrint("=============================================");
      rethrow;
    }
  }
}
