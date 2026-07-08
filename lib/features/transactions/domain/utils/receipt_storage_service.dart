import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptStorageService {
  final SupabaseClient _supabase;

  ReceiptStorageService(this._supabase);

  Future<String?> uploadReceipt({
    required File file,
    required String userId,
    required String accountId,
    required DateTime date,
    required String transactionUuid,
  }) async {
    try {
      final year = date.year.toString();
      final month = _getMonthName(date.month);
      final isPng = file.path.toLowerCase().endsWith('.png');
      final ext = isPng ? 'png' : 'jpg';
      
      // RLS compliant structured path
      final path = '$userId/$accountId/$year/$month/$transactionUuid.$ext';

      await _supabase.storage.from('receipts').upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      return _supabase.storage.from('receipts').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteReceipt(String cloudUrl) async {
    try {
      final uri = Uri.parse(cloudUrl);
      final segments = uri.pathSegments;
      final receiptsIndex = segments.indexOf('receipts');
      if (receiptsIndex != -1 && receiptsIndex < segments.length - 1) {
        final path = segments.sublist(receiptsIndex + 1).join('/');
        await _supabase.storage.from('receipts').remove([path]);
      }
    } catch (_) {
      // Silent catch
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
