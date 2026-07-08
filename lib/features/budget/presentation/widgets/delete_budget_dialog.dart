import 'package:flutter/material.dart';

class DeleteBudgetDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteBudgetDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Budget?'),
      content: const Text(
        'This budget will be archived. Transaction history will remain intact.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
