import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../core/utils/translations.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../providers/transaction_provider.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/delete_transaction_dialog.dart';
import '../widgets/undo_delete_snackbar.dart';
import 'add_edit_transaction_screen.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final String transactionUuid;

  const TransactionDetailsScreen({super.key, required this.transactionUuid});

  void _handleDelete(BuildContext context, WidgetRef ref, TransactionEntity transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteTransactionDialog(),
    );

    if (confirm == true) {
      final controller = ref.read(transactionControllerProvider);
      
      try {
        await controller.deleteTransaction(transaction.uuid);
        if (!context.mounted) return;

        // Pop back to transactions list if this route is still active
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          Navigator.pop(context);
        }

        // Show Undo SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          UndoDeleteSnackBar(
            context: context,
            onUndo: () async {
              try {
                await controller.restoreTransaction(transaction.uuid);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${context.translate('error_restore')}: $e')),
                  );
                }
              }
            },
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${context.translate('error_delete')}: $e')),
          );
        }
      }
    }
  }

  void _handleDuplicate(BuildContext context, WidgetRef ref, TransactionEntity transaction) {
    final controller = ref.read(transactionControllerProvider);
    final duplicated = controller.duplicateTransaction(transaction);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTransactionScreen(transaction: duplicated),
      ),
    );
  }

  void _handleReceiptReplace(BuildContext context, WidgetRef ref, TransactionEntity transaction) async {
    final picker = ImagePicker();
    final image = await showModalBottomSheet<XFile?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.translate('camera')),
                onTap: () async {
                  final file = await picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 70);
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(context.translate('gallery')),
                onTap: () async {
                  final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 70);
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      final controller = ref.read(transactionControllerProvider);
      try {
        await controller.replaceReceipt(transaction, File(image.path));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate('receipt_replaced'))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${context.translate('error_receipt_update')}: $e')),
          );
        }
      }
    }
  }

  void _handleReceiptRemove(BuildContext context, WidgetRef ref, TransactionEntity transaction) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('remove_receipt_title')),
        content: Text(context.translate('remove_receipt_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.translate('remove')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final controller = ref.read(transactionControllerProvider);
      try {
        await controller.removeReceipt(transaction);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.translate('receipt_removed'))),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${context.translate('error_receipt_remove')}: $e')),
          );
        }
      }
    }
  }

  void _handleShare(BuildContext context, TransactionEntity transaction) {
    final text = '${context.translate('app_title')} ${context.translate('transaction_details')}:\n'
        '${context.translate('title')}: ${transaction.title}\n'
        '${context.translate('amount')}: ${AppFormatter.formatCurrency(transaction.amount)} (${transaction.type.toUpperCase()})\n'
        '${context.translate('category')}: ${transaction.category}\n'
        '${context.translate('payment_method')}: ${transaction.paymentMethod}\n'
        '${context.translate('date')}: ${AppFormatter.formatDate(transaction.date)}\n'
        '${context.translate('notes')}: ${transaction.description}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(context.translate('transaction_details')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: context.translate('share'),
            onPressed: transactionsAsync.maybeWhen(
              data: (list) {
                final tx = list.firstWhere((t) => t.uuid == transactionUuid, orElse: () => widgetPlaceholderTransaction());
                return tx.uuid.isEmpty ? null : () => _handleShare(context, tx);
              },
              orElse: () => null,
            ),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (list) {
          debugPrint('UI rebuilt');
          final tx = list.firstWhere(
            (t) => t.uuid == transactionUuid,
            orElse: () => widgetPlaceholderTransaction(),
          );

          if (tx.uuid.isEmpty) {
            debugPrint('Provider refreshed');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                final route = ModalRoute.of(context);
                if (route != null && route.isCurrent) {
                  Navigator.pop(context);
                }
              }
            });

            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            );
          }

          final isIncome = tx.type == 'income';
          final primaryColor = isIncome ? AppColors.income : AppColors.expense;
          
          final accountName = accountsAsync.maybeWhen(
            data: (accounts) => accounts.firstWhere((a) => a.uuid == tx.accountId, orElse: () => widgetPlaceholderAccount()).name,
            orElse: () => '...',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isIncome
                            ? [AppColors.income.withValues(alpha: 0.05), AppColors.income.withValues(alpha: 0.15)]
                            : [AppColors.expense.withValues(alpha: 0.05), AppColors.expense.withValues(alpha: 0.15)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: primaryColor.withValues(alpha: 0.2),
                          child: Icon(
                            AppCategories.getIcon(tx.category),
                            color: primaryColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          tx.title.isNotEmpty ? tx.title : 'UPI',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${isIncome ? '+' : '-'}${AppFormatter.formatCurrency(tx.amount)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Chip(
                              label: Text(
                                tx.type.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: primaryColor,
                                ),
                              ),
                              backgroundColor: primaryColor.withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                tx.isSynced ? context.translate('synced').toUpperCase() : context.translate('pending_sync').toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: tx.isSynced ? Colors.green : Colors.orange,
                                ),
                              ),
                              backgroundColor: (tx.isSynced ? Colors.green : Colors.orange).withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Details List
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(context, context.translate('category'), tx.category, icon: Icons.category_outlined),
                        const Divider(),
                        _detailRow(context, context.translate('account_wallet'), accountName, icon: Icons.account_balance_wallet_outlined),
                        const Divider(),
                        _detailRow(context, context.translate('payment_method'), tx.paymentMethod, icon: Icons.payment_outlined),
                        const Divider(),
                        _detailRow(context, context.translate('date_time'), '${AppFormatter.formatDate(tx.date)} • ${AppFormatter.formatTime(tx.date)}', icon: Icons.calendar_today_outlined),
                        const Divider(),
                        _detailRow(
                          context,
                          context.translate('created_at'),
                          '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                          icon: Icons.history_toggle_off,
                        ),
                        const Divider(),
                        _detailRow(
                          context,
                          context.translate('updated_at'),
                          '${tx.updatedAt.day}/${tx.updatedAt.month}/${tx.updatedAt.year} ${tx.updatedAt.hour.toString().padLeft(2, '0')}:${tx.updatedAt.minute.toString().padLeft(2, '0')}',
                          icon: Icons.update_outlined,
                        ),
                        if (tx.description.isNotEmpty) ...[
                          const Divider(),
                          _detailRow(context, context.translate('notes'), tx.description, icon: Icons.description_outlined),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Receipt Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.translate('receipt'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                            ),
                            if (tx.receiptLocalPath != null || tx.receiptUrl != null)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: context.translate('remove_receipt'),
                                onPressed: () => _handleReceiptRemove(context, ref, tx),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (tx.receiptLocalPath != null || tx.receiptUrl != null) ...[
                          GestureDetector(
                            onTap: () {
                              final provider = tx.receiptLocalPath != null
                                  ? FileImage(File(tx.receiptLocalPath!))
                                  : NetworkImage(tx.receiptUrl!) as ImageProvider;
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  child: InteractiveViewer(child: Image(image: provider, fit: BoxFit.contain)),
                                ),
                              );
                            },
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: tx.receiptLocalPath != null
                                      ? FileImage(File(tx.receiptLocalPath!))
                                      : NetworkImage(tx.receiptUrl!) as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        OutlinedButton.icon(
                          onPressed: () => _handleReceiptReplace(context, ref, tx),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(tx.receiptLocalPath != null || tx.receiptUrl != null ? context.translate('replace_receipt') : context.translate('attach_receipt')),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions Button Bar
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        onPressed: () => _handleDuplicate(context, ref, tx),
                        icon: const Icon(Icons.copy_outlined),
                        label: Text(context.translate('duplicate')),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => AddEditTransactionScreen(transaction: tx),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(context.translate('edit')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  onPressed: () => _handleDelete(context, ref, tx),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(context.translate('delete_transaction')),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, _) => Center(child: Text('${context.translate('error_loading_details')}: $err')),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String title, String value, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TransactionEntity widgetPlaceholderTransaction() {
    return TransactionEntity(
      uuid: '',
      accountId: '',
      type: '',
      categoryId: '',
      category: '',
      amount: 0.0,
      title: '',
      description: '',
      currency: 'USD',
      paymentMethod: '',
      isDeleted: false,
      isSynced: false,
      isRecurring: false,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncVersion: 1,
    );
  }

  AccountModel widgetPlaceholderAccount() {
    return AccountModel()..name = 'Unknown Wallet';
  }
}
