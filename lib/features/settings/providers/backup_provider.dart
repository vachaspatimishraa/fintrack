import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../splash/providers/initialization_provider.dart';
import '../data/repositories/backup_repository_impl.dart';
import '../domain/entities/backup_history_entity.dart';
import '../domain/repositories/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return BackupRepositoryImpl(isarService.isar, ref);
});

final backupHistoryProvider = StreamProvider<List<BackupHistoryEntity>>((ref) {
  final repository = ref.watch(backupRepositoryProvider);
  return repository.watchBackupHistory();
});
