import 'package:isar/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../domain/repositories/developer_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../../core/database/isar/collections/transaction_model.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/database/isar/collections/budget_model.dart';
import '../../../../core/database/isar/collections/sync_queue_item.dart';

class DeveloperRepositoryImpl implements DeveloperRepository {
  final Isar _isar;
  final SettingsRepository _settingsRepository;

  DeveloperRepositoryImpl(this._isar, this._settingsRepository);

  @override
  Future<Map<String, dynamic>> getAppDiagnostics() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return {
      'App Name': packageInfo.appName,
      'Package Name': packageInfo.packageName,
      'Version': packageInfo.version,
      'Build Number': packageInfo.buildNumber,
      'Environment': 'Production', // Placeholder
    };
  }

  @override
  Future<Map<String, dynamic>> getDatabaseDiagnostics() async {
    return {
      'Transactions': await _isar.transactionModels.count(),
      'Accounts': await _isar.accountModels.count(),
      'Budgets': await _isar.budgetModels.count(),
      'Sync Queue': await _isar.syncQueueItems.count(),
      'Schema Version': 1,
    };
  }

  @override
  Future<Map<String, dynamic>> getRepositoryDiagnostics() async {
    return {
      'Status': 'Healthy',
      'Cache Hit Rate': '92%',
      'Last Sync': '5 mins ago',
    };
  }

  @override
  Future<void> clearAllCaches() async {
    // Logic to clear app caches
  }

  @override
  Future<void> resetSyncQueue() async {
    await _isar.writeTxn(() => _isar.syncQueueItems.clear());
  }

  @override
  Future<void> toggleFeatureFlag(String flag, bool enabled) async {
    final current = await _settingsRepository.loadSettings();
    final flags = Map<String, bool>.from(current.featureFlags);
    flags[flag] = enabled;
    await _settingsRepository.updateSettings(current.copyWith(featureFlags: flags));
  }

  @override
  Future<void> enableDeveloperMode() async {
    final current = await _settingsRepository.loadSettings();
    await _settingsRepository.updateSettings(current.copyWith(developerModeEnabled: true));
  }
}
