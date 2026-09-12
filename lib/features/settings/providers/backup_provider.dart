import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/splash/providers/initialization_provider.dart';
import 'package:fintrack/features/settings/data/repositories/backup_repository_impl.dart';
import 'package:fintrack/features/settings/domain/entities/backup_history_entity.dart';
import 'package:fintrack/features/settings/domain/repositories/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return BackupRepositoryImpl(isarService.isar, ref);
});

final backupHistoryProvider = StreamProvider<List<BackupHistoryEntity>>((ref) {
  final repository = ref.watch(backupRepositoryProvider);
  return repository.watchBackupHistory();
});
