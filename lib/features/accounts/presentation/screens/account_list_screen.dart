import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../providers/account_provider.dart';
import '../../providers/account_search_provider.dart';
import '../../providers/account_sort_provider.dart';
import '../../providers/account_filter_provider.dart';
import '../../providers/account_pagination_provider.dart';
import '../controllers/account_controller.dart';
import '../widgets/empty_account_view.dart';
import '../widgets/account_card.dart';
import '../widgets/rename_account_dialog.dart';
import '../widgets/archive_account_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import 'create_account_screen.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../core/database/isar/collections/account_model.dart';

class AccountListScreen extends ConsumerWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAccounts = ref.watch(filteredAccountsProvider);
    final search = ref.watch(accountSearchProvider);
    final filter = ref.watch(accountFilterProvider);
    final sort = ref.watch(accountSortProvider);
    final pagination = ref.watch(accountPaginationProvider);
    final currentUuid = ref.watch(currentAccountProvider);
    final controller = ref.read(accountControllerProvider);
    final totalBalance = ref.watch(totalBalanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('accounts')),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(accountSearchProvider.notifier).clear();
              ref.read(accountFilterProvider.notifier).setFilterOption(AccountFilterOption.active);
              ref.read(accountSortProvider.notifier).setSortOption(AccountSortOption.alphabetical);
              ref.read(accountPaginationProvider.notifier).reset();
            },
            icon: const Icon(Icons.refresh_outlined),
            tooltip: context.translate('clear_filters'),
          )
        ],
      ),
      body: Column(
        children: [
          // Total Balance Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('balance'),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
                    Text(
                      AppFormatter.formatCurrency(totalBalance),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(context.translate('add_account')),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.translate('search'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => ref.read(accountSearchProvider.notifier).clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (val) => ref.read(accountSearchProvider.notifier).setSearchQuery(val),
            ),
          ),

          // Sorting & Filter Chip Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                // Sort Dropdown
                DropdownButton<AccountSortOption>(
                  value: sort,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.sort, size: 18),
                  items: [
                    DropdownMenuItem(value: AccountSortOption.alphabetical, child: Text(context.translate('alphabetical'))),
                    DropdownMenuItem(value: AccountSortOption.newest, child: Text(context.translate('newest'))),
                    DropdownMenuItem(value: AccountSortOption.oldest, child: Text(context.translate('oldest'))),
                    DropdownMenuItem(value: AccountSortOption.highestBalance, child: Text(context.translate('highest_balance'))),
                    DropdownMenuItem(value: AccountSortOption.lowestBalance, child: Text(context.translate('lowest_balance'))),
                    DropdownMenuItem(value: AccountSortOption.mostRecentlyUsed, child: Text(context.translate('recently_updated'))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(accountSortProvider.notifier).setSortOption(val);
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Filter Chips
                ...AccountFilterOption.values.map((opt) {
                  final label = context.translate(opt.name);
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      selected: filter == opt,
                      label: Text(label, style: const TextStyle(fontSize: 12)),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(accountFilterProvider.notifier).setFilterOption(opt);
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Accounts Grid/List
          Expanded(
            child: filteredAccounts.isEmpty
                ? const EmptyAccountView()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemCount: filteredAccounts.length,
                    itemBuilder: (context, index) {
                      final account = filteredAccounts[index];
                      final isSelected = account.uuid == currentUuid;

                      return AccountCard(
                        account: account,
                        isSelected: isSelected,
                        onTap: () async {
                          if (account.isDeleted) return; // Cant select soft-deleted account
                          await controller.selectAccount(account.uuid);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        onLongPress: () => _showOptionsSheet(context, ref, account),
                      );
                    },
                  ),
          ),

          // Pagination Controls
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: pagination.page > 0
                      ? () => ref.read(accountPaginationProvider.notifier).previousPage()
                      : null,
                  icon: const Icon(Icons.arrow_back_ios, size: 16),
                ),
                Text(
                  '${context.translate('page')} ${pagination.page + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: filteredAccounts.length >= pagination.limit
                      ? () => ref.read(accountPaginationProvider.notifier).nextPage()
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref, AccountModel account) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                account.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (account.isDeleted) ...[
                ListTile(
                  leading: const Icon(Icons.restore_from_trash, color: Colors.green),
                  title: Text(context.translate('restore_account'), style: const TextStyle(color: Colors.green)),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(accountControllerProvider).restoreAccount(account.uuid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${account.name} ${context.translate('restore_account_success')}')),
                      );
                    }
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(context.translate('edit_rename')),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => RenameAccountDialog(account: account),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(account.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                  title: Text(account.isArchived ? context.translate('restore_from_archive') : context.translate('archive_account')),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => ArchiveAccountDialog(account: account, shouldArchive: !account.isArchived),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(context.translate('delete_account'), style: const TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => DeleteAccountDialog(account: account),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
