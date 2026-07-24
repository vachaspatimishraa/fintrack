import 'package:flutter/material.dart';

class RestoreTransactionDialog extends StatelessWidget {
  const RestoreTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Restore Transaction?'),
      content: const Text(
        'This transaction will be added back to your wallet balance and transaction history.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Restore'),
        ),
      ],
    );
  }
}
