import 'package:flutter/material.dart';
import '../../../../core/utils/translations.dart';

class DeleteTransactionDialog extends StatelessWidget {
  const DeleteTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('delete_transaction')),
      content: Text(
        context.translate('delete_transaction_desc'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.translate('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.translate('delete')),
        ),
      ],
    );
  }
}
