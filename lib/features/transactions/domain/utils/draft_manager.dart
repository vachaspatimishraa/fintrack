import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DraftManager {
  static Map<String, dynamic>? _memoryDraft;
  static String? _cachedDraftPath;

  static Future<String?> _getDraftPath() async {
    if (_cachedDraftPath != null) return _cachedDraftPath;
    try {
      final dir = await getApplicationDocumentsDirectory().timeout(
        const Duration(milliseconds: 500),
      );
      _cachedDraftPath = '${dir.path}/transaction_draft.json';
      return _cachedDraftPath;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveDraft(Map<String, dynamic> draftJson) async {
    _memoryDraft = draftJson;
    try {
      final path = await _getDraftPath();
      if (path != null) {
        final file = File(path);
        await file.writeAsString(jsonEncode(draftJson));
      }
    } catch (_) {}
  }

  static Future<Map<String, dynamic>?> loadDraft() async {
    try {
      final path = await _getDraftPath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          final content = await file.readAsString();
          return jsonDecode(content) as Map<String, dynamic>;
        }
      }
    } catch (_) {}
    return _memoryDraft;
  }

  static Future<void> clearDraft() async {
    _memoryDraft = null;
    try {
      final path = await _getDraftPath();
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {}
  }
}
