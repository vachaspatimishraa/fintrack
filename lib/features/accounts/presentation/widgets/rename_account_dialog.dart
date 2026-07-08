import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../controllers/account_controller.dart';

class RenameAccountDialog extends ConsumerStatefulWidget {
  final AccountModel account;

  const RenameAccountDialog({
    super.key,
    required this.account,
  });

  @override
  ConsumerState<RenameAccountDialog> createState() => _RenameAccountDialogState();
}

class _RenameAccountDialogState extends ConsumerState<RenameAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.account.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('edit_rename')),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.translate('account_name'),
            hintText: context.translate('enter_account_name'),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) {
              return context.translate('enter_account_name');
            }
            if (trimmed.length > 40) {
              return context.translate('max_chars_40');
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final newName = _controller.text;
              try {
                await ref.read(accountControllerProvider).renameAccount(widget.account.uuid, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${context.translate('account_updated')}: $newName')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${context.translate('error')}: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }
          },
          child: Text(context.translate('save')),
        ),
      ],
    );
  }
}
