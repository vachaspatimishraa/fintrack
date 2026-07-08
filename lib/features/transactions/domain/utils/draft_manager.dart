import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DraftManager {
  static Future<String> _getDraftPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/transaction_draft.json';
  }

  static Future<void> saveDraft(Map<String, dynamic> draftJson) async {
    try {
      final file = File(await _getDraftPath());
      await file.writeAsString(jsonEncode(draftJson));
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadDraft() async {
    try {
      final file = File(await _getDraftPath());
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> clearDraft() async {
    try {
      final file = File(await _getDraftPath());
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
