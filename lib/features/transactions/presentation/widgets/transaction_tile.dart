import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/transaction_entity.dart';
import '../controllers/selection_controller.dart';
import '../screens/transaction_details_screen.dart';

class TransactionTile extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionState = ref.watch(selectionProvider);
    final selectionNotifier = ref.read(selectionProvider.notifier);

    final isSelected = selectionState.selectedUuids.contains(transaction.uuid);
    final isSelectionMode = selectionState.isSelectionMode;
    final isIncome = transaction.type == 'income';
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = isIncome ? colorScheme.primary : colorScheme.error;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: isSelected ? 4 : 1,
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            selectionNotifier.toggleSelection(transaction.uuid);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionDetailsScreen(transactionUuid: transaction.uuid),
              ),
            );
          }
        },
        onLongPress: () {
          if (!isSelectionMode) {
            selectionNotifier.enterSelectionMode(transaction.uuid);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              isSelectionMode
                  ? Checkbox(
                      value: isSelected,
                      onChanged: (val) {
                        selectionNotifier.toggleSelection(transaction.uuid);
                      },
                    )
                  : CircleAvatar(
                      backgroundColor: primaryColor.withValues(alpha: 0.1),
                      child: Icon(
                        AppCategories.getIcon(transaction.category),
                        color: primaryColor,
                      ),
                    ),
              const SizedBox(width: 12),

              // Middle Section: Title, Date & Time, Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.title.isNotEmpty
                          ? transaction.title
                          : (transaction.description.isNotEmpty
                              ? transaction.description
                              : 'UPI'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppFormatter.formatDate(transaction.date)} • ${AppFormatter.formatTime(transaction.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.category} • ${transaction.paymentMethod}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Optional Attachment Indicator
              if (transaction.receiptLocalPath != null ||
                  transaction.receiptUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Tooltip(
                    message: '1 Attachment',
                    child: Icon(
                      Icons.attach_file,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

              // Amount Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isIncome ? "+" : "-"}${AppFormatter.formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SyncIndicator(isSynced: transaction.isSynced),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptIndicator extends StatelessWidget {
  const ReceiptIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Receipt Attached',
      child: Icon(Icons.attach_file, size: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class SyncIndicator extends StatelessWidget {
  final bool isSynced;

  const SyncIndicator({super.key, required this.isSynced});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: isSynced ? 'Synced to Cloud' : 'Pending Sync',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isSynced ? Colors.green : colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
