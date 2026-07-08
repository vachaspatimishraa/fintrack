import 'package:flutter/material.dart';

class RestoreBackupDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RestoreBackupDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Backup?'),
      content: const Text(
        'Your current local data will be replaced with the data from this backup. This action cannot be reversed.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
