import 'package:flutter/material.dart';
import '../../domain/entities/transaction_entity.dart';
import 'sticky_date_header.dart';
import 'transaction_tile.dart';

class TransactionTimeline extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const TransactionTimeline({super.key, required this.transactions});

  Map<String, List<TransactionEntity>> _groupTransactions(List<TransactionEntity> list) {
    final Map<String, List<TransactionEntity>> grouped = {};
    for (final tx in list) {
      final key = _getDateGroupKey(tx.date);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(tx);
    }
    return grouped;
  }

  String _getDateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) {
      return 'Today';
    } else if (txDate == yesterday) {
      return 'Yesterday';
    } else {
      // Return month name and year (e.g. July 2026)
      return _formatMonthYear(date);
    }
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupTransactions(transactions);

    return SliverMainAxisGroup(
      slivers: grouped.entries.expand((entry) {
        return [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyDateHeaderDelegate(title: entry.key),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final tx = entry.value[index];
                  return TransactionTile(
                    key: ValueKey(tx.uuid),
                    transaction: tx,
                  );
                },
                childCount: entry.value.length,
              ),
            ),
          ),
        ];
      }).toList(),
    );
  }
}
