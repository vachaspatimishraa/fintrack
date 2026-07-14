import 'package:shared_preferences/shared_preferences.dart';

class SyncPreferences {
  static const String lastSyncKey = 'last_sync_time';

  static Future<void> saveLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      lastSyncKey,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<DateTime?> getLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(lastSyncKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }
}
