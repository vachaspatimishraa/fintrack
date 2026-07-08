import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../controllers/account_controller.dart';

class ArchiveAccountDialog extends ConsumerWidget {
  final AccountModel account;
  final bool shouldArchive;

  const ArchiveAccountDialog({
    super.key,
    required this.account,
    required this.shouldArchive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = shouldArchive ? context.translate('archive_account') : context.translate('restore_account');
    final content = shouldArchive
        ? context.translate('archive_account_desc').replaceFirst('{name}', account.name)
        : context.translate('restore_account_desc').replaceFirst('{name}', account.name);
    final actionText = shouldArchive ? context.translate('archive') : context.translate('restore');

    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref.read(accountControllerProvider).archiveAccount(account.uuid, shouldArchive);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${context.translate('accounts')} ${shouldArchive ? context.translate('archived') : context.translate('restored')} ${context.translate('deleted_success')}')),
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
          child: Text(actionText),
        ),
      ],
    );
  }
}
