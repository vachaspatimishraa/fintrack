import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';

class SyncStatusCard extends StatelessWidget {
  final bool isSyncing;
  final DateTime? lastSyncAt;
  final VoidCallback onSyncTap;

  const SyncStatusCard({
    super.key,
    required this.isSyncing,
    this.lastSyncAt,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastSyncStr = lastSyncAt != null 
        ? AppFormatter.formatFriendlyDateTime(lastSyncAt!) 
        : 'Never';

    return Card(
      child: ListTile(
        leading: Icon(
          Icons.cloud_done_outlined,
          color: lastSyncAt != null ? Colors.green : Colors.grey,
        ),
        title: const Text('Synchronization Status'),
        subtitle: Text('Last synced: $lastSyncStr'),
        trailing: isSyncing 
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(
                icon: const Icon(Icons.sync),
                onPressed: onSyncTap,
              ),
      ),
    );
  }
}
