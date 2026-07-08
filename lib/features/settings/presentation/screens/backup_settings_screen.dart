import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';
import '../controllers/settings_controller.dart';
import '../controllers/backup_controller.dart';
import '../../../sync/providers/sync_provider.dart';
import 'backup_history_screen.dart';

import '../widgets/sync_status_card.dart';

class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final syncState = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Synchronization'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, 'Cloud Synchronization'),
            _buildSyncCard(context, ref, settings, syncState),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Backups'),
            _buildBackupCard(context, ref, settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'History & Restore'),
            _buildHistoryCard(context),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSyncCard(BuildContext context, WidgetRef ref, SettingsEntity settings, dynamic syncState) {
    return Column(
      children: [
        Card(
          child: SwitchListTile(
            title: const Text('Automatic Cloud Sync'),
            subtitle: const Text('Synchronize financial data with Supabase automatically'),
            secondary: const Icon(Icons.sync),
            value: settings.syncEnabled,
            onChanged: (val) => ref.read(settingsControllerProvider).toggleSync(val),
          ),
        ),
        const SizedBox(height: 8),
        SyncStatusCard(
          isSyncing: syncState.isSyncing,
          lastSyncAt: settings.lastSyncAt,
          onSyncTap: () => ref.read(backupControllerProvider).triggerCloudSync(),
        ),
      ],
    );
  }

  Widget _buildBackupCard(BuildContext context, WidgetRef ref, dynamic settings) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Automatic Local Backup'),
            subtitle: const Text('Daily backup to local device storage'),
            secondary: const Icon(Icons.backup_outlined),
            value: settings.backupEnabled,
            onChanged: (val) => ref.read(settingsControllerProvider).toggleBackup(val),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Manual Backup'),
            subtitle: const Text('Create a full backup of all data now'),
            trailing: const Icon(Icons.add_to_photos_outlined),
            onTap: () async {
              await ref.read(backupControllerProvider).createManualBackup();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Manual backup created.')));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('View Backup History'),
        subtitle: const Text('Restore data from previous local backups'),
        leading: const Icon(Icons.history),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BackupHistoryScreen()),
          );
        },
      ),
    );
  }
}
