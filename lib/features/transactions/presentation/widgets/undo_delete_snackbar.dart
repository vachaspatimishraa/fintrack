import 'package:flutter/material.dart';
import '../../../../core/utils/translations.dart';

class UndoDeleteSnackBar extends SnackBar {
  UndoDeleteSnackBar({
    super.key,
    required BuildContext context,
    required VoidCallback onUndo,
  }) : super(
          content: Text(context.translate('deleted_success')),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: context.translate('restore').toUpperCase(),
            onPressed: onUndo,
          ),
        );
}
