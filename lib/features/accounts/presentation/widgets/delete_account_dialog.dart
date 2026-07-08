import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../controllers/account_controller.dart';

class DeleteAccountDialog extends ConsumerWidget {
  final AccountModel account;

  const DeleteAccountDialog({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(context.translate('delete_account_title'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
      content: Text(
        context.translate('delete_account_desc').replaceFirst('{name}', account.name),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref.read(accountControllerProvider).deleteAccount(account.uuid);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${account.name} ${context.translate('deleted_success')}')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${context.translate('error')}: $e'), backgroundColor: Colors.red),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(context.translate('delete')),
        ),
      ],
    );
  }
}
