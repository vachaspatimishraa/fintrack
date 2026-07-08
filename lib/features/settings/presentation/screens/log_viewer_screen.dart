import 'package:flutter/material.dart';

class LogViewerScreen extends StatelessWidget {
  const LogViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real implementation, we would fetch logs from a logging service
    final logs = [
      '[INFO] 2026-07-04 14:00:01: Application started.',
      '[DEBUG] 2026-07-04 14:00:05: Isar initialized.',
      '[INFO] 2026-07-04 14:05:12: Budget progress calculated.',
      '[ERROR] 2026-07-04 14:10:45: Sync failed. Retrying...',
      '[DEBUG] 2026-07-04 14:15:00: Cache hit rate: 92%.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        width: double.infinity,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final color = _getLogColor(log);
            return Text(
              log,
              style: TextStyle(
                color: color,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('[ERROR]')) return Colors.redAccent;
    if (log.contains('[WARNING]')) return Colors.orangeAccent;
    if (log.contains('[DEBUG]')) return Colors.blueAccent;
    return Colors.greenAccent;
  }
}
