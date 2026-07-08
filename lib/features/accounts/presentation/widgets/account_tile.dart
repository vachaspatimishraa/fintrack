import 'package:flutter/material.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/utils/formatter.dart';
import 'current_account_badge.dart';

class AccountTile extends StatelessWidget {
  final AccountModel account;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AccountTile({
    super.key,
    required this.account,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(account.colorValue);

    return Card(
      elevation: isSelected ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.indigo.shade400 : Colors.grey.shade200,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(_getIconData(account.icon), color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                account.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const CurrentAccountBadge(),
            ],
          ],
        ),
        subtitle: Text(account.type),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppFormatter.formatCurrency(account.balance),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!account.isSynced)
                  const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.sync, size: 12, color: Colors.orange),
                  ),
                Text(
                  account.isSynced ? 'Synced' : 'Pending',
                  style: TextStyle(
                    fontSize: 9,
                    color: account.isSynced ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'credit_card':
        return Icons.credit_card_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'savings':
        return Icons.savings_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
