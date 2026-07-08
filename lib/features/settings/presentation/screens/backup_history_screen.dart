import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/backup_provider.dart';
import '../controllers/backup_controller.dart';

import '../widgets/restore_backup_dialog.dart';

class BackupHistoryScreen extends ConsumerWidget {
  const BackupHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(backupHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup History'),
      ),
      body: historyAsync.when(
        data: (history) {
          if (history.isEmpty) {
            return const Center(child: Text('No backup history found.'));
          }
          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final backup = history[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: backup.status == 'success' ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(
                    backup.status == 'success' ? Icons.check : Icons.error_outline,
                    color: backup.status == 'success' ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(backup.backupName),
                subtitle: Text(
                  '${DateFormat('MMM d, yyyy HH:mm').format(backup.createdAt)} • ${backup.backupType.toUpperCase()}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, backup.uuid),
                ),
                onTap: () => _confirmRestore(context, ref, backup.uuid),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String uuid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(backupControllerProvider).deleteBackup(uuid);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context, WidgetRef ref, String uuid) {
    showDialog(
      context: context,
      builder: (context) => RestoreBackupDialog(
        onConfirm: () {
          ref.read(backupControllerProvider).restoreFromBackup(uuid);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restoration started.')));
        },
      ),
    );
  }
}
