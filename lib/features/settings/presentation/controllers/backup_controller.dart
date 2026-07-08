import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../providers/backup_provider.dart';

class BackupController {
  final Ref _ref;

  BackupController(this._ref);

  BackupRepository get _repository => _ref.read(backupRepositoryProvider);

  Future<void> createManualBackup() async {
    await _repository.createManualBackup();
  }

  Future<void> restoreFromBackup(String uuid) async {
    await _repository.restoreFromBackup(uuid);
  }

  Future<void> deleteBackup(String uuid) async {
    await _repository.deleteBackup(uuid);
  }

  Future<void> triggerCloudSync() async {
    await _repository.triggerCloudSync();
  }
}

final backupControllerProvider = Provider<BackupController>((ref) => BackupController(ref));
