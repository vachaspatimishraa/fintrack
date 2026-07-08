import 'package:isar/isar.dart';
import '../../../../../core/database/isar/collections/settings_model.dart';

/// Datasource for persistent application preferences.
/// 
/// Manages the primary settings model in Isar and provides generic 
/// key-value storage for extensibility.
class SettingsLocalDatasource {
  final Isar _isar;

  SettingsLocalDatasource(this._isar);

  /// Retrieves the centralized settings model.
  /// 
  /// Creates a default record if none exists.
  Future<SettingsModel> getSettings() async {
    final settings = await _isar.settingsModels.where().findFirst();
    if (settings == null) {
      final defaultSettings = SettingsModel();
      await _isar.writeTxn(() => _isar.settingsModels.put(defaultSettings));
      return defaultSettings;
    }
    return settings;
  }

  /// Watches for changes in the settings model.
  Stream<SettingsModel> watchSettings() {
    return _isar.settingsModels.where().watch(fireImmediately: true).map((list) {
      if (list.isEmpty) {
        return SettingsModel();
      }
      return list.first;
    });
  }

  /// Persists a settings model to local storage.
  Future<void> saveSettings(SettingsModel settings) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.settingsModels.where().findFirst();
      if (existing != null) {
        settings.id = existing.id;
      }
      await _isar.settingsModels.put(settings);
    });
  }

  /// Removes all application preferences and resets to defaults.
  Future<void> reset() async {
    await _isar.writeTxn(() async {
      await _isar.settingsModels.where().deleteAll();
      final defaultSettings = SettingsModel();
      await _isar.settingsModels.put(defaultSettings);
    });
  }

  // Generic Key-Value Contract Support (Future implementation)
  Future<void> save(String key, dynamic value) async {}
  Future<dynamic> load(String key) async {}
  Stream<dynamic> watch(String key) async* {}
}
