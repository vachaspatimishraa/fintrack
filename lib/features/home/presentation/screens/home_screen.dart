import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../accounts/presentation/screens/account_list_screen.dart';
import '../../../accounts/presentation/screens/create_account_screen.dart';
import '../../../accounts/presentation/widgets/account_picker_bottom_sheet.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../../transactions/presentation/screens/transactions_screen.dart';
import '../../../transactions/presentation/screens/add_edit_transaction_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../domain/models/dashboard_model.dart';
import '../../domain/models/home_state.dart';
import '../../providers/home_provider.dart';
import '../controllers/home_controller.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/presentation/screens/transaction_details_screen.dart';
import '../../../transactions/presentation/widgets/undo_delete_snackbar.dart';
import '../widgets/app_navigation_drawer.dart';
import '../../../../core/utils/translations.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../settings/providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DashboardTab();
  }
}

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final homeController = ref.read(homeControllerProvider);
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      drawer: const AppNavigationDrawer(),
      appBar: accountsAsync.maybeWhen(
        data: (accounts) => accounts.isEmpty
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: HomeAppBar(
                  homeState: homeState,
                  homeController: homeController,
                ),
              ),
        orElse: () => null,
      ),
      body: SafeArea(
        child: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return EmptyAccountView();
            }
            return Column(
              children: [
                // 2. Offline Mode Banner
                if (homeState.dashboard?.syncStatus == HomeSyncStatus.offline)
                  const OfflineBanner(),

                // 3. Main Dashboard content (Scrollable transaction list + Static summary cards)
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => homeController.refreshDashboard(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Date section & Overview statistics
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const DateSection(),
                                const SizedBox(height: 12),
                                if (homeState.isLoading)
                                  const LoadingSkeleton()
                                else if (homeState.error != null)
                                  ErrorStateView(errorMessage: homeState.error!, onRetry: homeController.refreshDashboard)
                                else
                                  const OverviewCards(),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      context.translate('transactions'),
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    if (homeState.selectedTypeFilter != null || homeState.selectedDateRange != null)
                                      TextButton.icon(
                                        onPressed: homeController.clearFilters,
                                        icon: const Icon(Icons.clear, size: 16),
                                        label: Text(context.translate('clear_filters'), style: const TextStyle(fontSize: 12)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),

                        // Transaction List
                        if (!homeState.isLoading && homeState.error == null)
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            sliver: TransactionListSection(
                              transactions: homeState.dashboard?.recentTransactions ?? [],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 4. Fixed Bottom Buttons
                const BottomActionButtons(),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// Custom Premium AppBar
class HomeAppBar extends ConsumerWidget {
  final HomeState homeState;
  final HomeController homeController;

  const HomeAppBar({
    super.key,
    required this.homeState,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        tooltip: context.translate('open_navigation_drawer'),
      ),
      title: Text(
        context.translate('app_title'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        // Add Button
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
            );
          },
          icon: const Icon(Icons.add),
          tooltip: context.translate('add_account'),
        ),
        // Share Button
        IconButton(
          onPressed: () {
            if (homeState.dashboard?.currentAccount == null) return;
            _showShareBottomSheet(context, homeState.dashboard!);
          },
          icon: const Icon(Icons.share_outlined),
          tooltip: context.translate('share_report'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showShareBottomSheet(BuildContext context, DashboardModel dashboard) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.translate('export_account_data'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${context.translate('export_report_for')} ${dashboard.currentAccount?.name}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await homeController.exportPdf(
                        dashboard.recentTransactions,
                        dashboard.currentAccount?.name ?? 'Account',
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(context.translate('pdf')),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      await homeController.exportExcel(dashboard.recentTransactions);
                    },
                    icon: const Icon(Icons.table_view),
                    label: Text(context.translate('excel')),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Sync Indicator Dot
class SyncIndicator extends StatelessWidget {
  final HomeSyncStatus status;

  const SyncIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case HomeSyncStatus.synced:
        color = Colors.green;
        label = context.translate('synced');
        break;
      case HomeSyncStatus.syncing:
        color = Colors.blue;
        label = context.translate('syncing');
        break;
      case HomeSyncStatus.offline:
        color = Colors.orange;
        label = context.translate('offline');
        break;
      case HomeSyncStatus.failed:
        color = Colors.red;
        label = context.translate('sync_failed');
        break;
    }

    return Tooltip(
      message: label,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// Offline Banner
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            context.translate('offline_mode_banner'),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// Date Filter Picker Section
class DateSection extends ConsumerWidget {
  const DateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeController = ref.read(homeControllerProvider);
    final homeState = ref.watch(homeStateProvider);

    // Identify active period label if possible
    final start = homeState.selectedDateRange?.start;
    final end = homeState.selectedDateRange?.end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.translate('overview'),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                Text(
                  start != null && end != null
                      ? '${AppFormatter.formatDate(start)} - ${AppFormatter.formatDate(end)}'
                      : context.translate('current_month'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                final currentRange = homeState.selectedDateRange;
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDateRange: currentRange,
                );
                if (picked != null) {
                  homeController.setCustomDateRange(picked);
                }
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 20),
              tooltip: context.translate('choose_date_range'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['today', 'yesterday', 'week', 'month', 'year'].map((periodKey) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(context.translate(periodKey)),
                  onPressed: () => homeController.setFilterPeriod(periodKey),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  side: BorderSide(color: Colors.grey.shade300),
                  labelStyle: const TextStyle(fontSize: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// Three Overview Cards: Income, Expense, Balance
class OverviewCards extends ConsumerWidget {
  const OverviewCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeStateProvider).dashboard;
    final selectedFilter = ref.watch(homeStateProvider).selectedTypeFilter;
    final controller = ref.read(homeControllerProvider);

    if (dashboard == null) return const SizedBox.shrink();

    return Row(
      children: [
        // Income Card (Green Theme)
        Expanded(
          child: CardWidget(
            title: context.translate('income'),
            amount: dashboard.income,
            count: dashboard.recentTransactions.where((tx) => tx.type == 'income').length,
            color: AppColors.income,
            isActive: selectedFilter == 'income',
            onTap: () {
              controller.setTypeFilter(selectedFilter == 'income' ? null : 'income');
            },
          ),
        ),
        const SizedBox(width: 8),

        // Expense Card (Red Theme)
        Expanded(
          child: CardWidget(
            title: context.translate('expense'),
            amount: dashboard.expense,
            count: dashboard.recentTransactions.where((tx) => tx.type == 'expense').length,
            color: AppColors.expense,
            isActive: selectedFilter == 'expense',
            onTap: () {
              controller.setTypeFilter(selectedFilter == 'expense' ? null : 'expense');
            },
          ),
        ),
        const SizedBox(width: 8),

        // Net Balance Card (Blue/Indigo theme)
        Expanded(
          child: CardWidget(
            title: context.translate('balance'),
            amount: dashboard.balance,
            count: dashboard.transactionCount,
            color: AppColors.primary,
            isActive: false,
            onTap: null, // Static overview card
          ),
        ),
      ],
    );
  }
}

// Helper Card Widget with Animated Counter
class CardWidget extends StatelessWidget {
  final String title;
  final double amount;
  final int count;
  final Color color;
  final bool isActive;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.title,
    required this.amount,
    required this.count,
    required this.color,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade200,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          // Animated Counter using TweenAnimationBuilder
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 250),
            tween: Tween<double>(begin: 0, end: amount),
            builder: (context, val, child) {
              return Text(
                AppFormatter.formatCurrency(val),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '$count ${context.translate('txs')}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

// Transaction List Section (Custom items with transition animations)
class TransactionListSection extends ConsumerWidget {
  final List<TransactionEntity> transactions;

  const TransactionListSection({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: const EmptyTransactionView(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tx = transactions[index];
          return TransactionTile(
            key: ValueKey(tx.uuid),
            transaction: tx,
          );
        },
        childCount: transactions.length,
      ),
    );
  }
}

class TransactionTile extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransactionTile({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isIncome = transaction.type == 'income';
    final repo = ref.read(transactionRepositoryProvider);

    return Dismissible(
      key: ValueKey(transaction.uuid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: AppColors.expense,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        await repo.deleteTransaction(transaction.uuid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            UndoDeleteSnackBar(
              context: context,
              onUndo: () async {
                try {
                  await repo.restoreTransaction(transaction.uuid);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Unable to restore transaction: $e')),
                    );
                  }
                }
              },
            ),
          );
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionDetailsScreen(transactionUuid: transaction.uuid),
                ),
              );
            },
            onLongPress: () => _showDeleteConfirmation(context, ref),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Leading Category Icon
                  CircleAvatar(
                    backgroundColor: isIncome
                        ? AppColors.income.withValues(alpha: 0.1)
                        : AppColors.expense.withValues(alpha: 0.1),
                    child: Icon(
                      AppCategories.getIcon(transaction.category),
                      color: isIncome ? AppColors.income : AppColors.expense,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle Section: Title, Category, Date & Time
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
                        const SizedBox(height: 2),
                        Text(
                          transaction.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
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
                      ],
                    ),
                  ),

                  // Optional Attachment Indicator
                  if (transaction.receiptUrl != null ||
                      transaction.receiptLocalPath != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Tooltip(
                        message: '1 ${context.translate('attachment')}',
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
                        '${isIncome ? '+' : '-'}${AppFormatter.formatCurrency(transaction.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isIncome ? AppColors.income : AppColors.expense,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Sync indicator at the bottom right of the amount
                      Icon(
                        transaction.isSynced ? Icons.cloud_done : Icons.cloud_queue,
                        size: 14,
                        color: transaction.isSynced ? Colors.green : Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(transactionRepositoryProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteTransactionDialog(),
    );

    if (confirm == true) {
      await repo.deleteTransaction(transaction.uuid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          UndoDeleteSnackBar(
            context: context,
            onUndo: () async {
              try {
                await repo.restoreTransaction(transaction.uuid);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Unable to restore transaction: $e')),
                  );
                }
              }
            },
          ),
        );
      }
    }
  }
}

// Empty State View
class EmptyTransactionView extends StatelessWidget {
  const EmptyTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/logo.png',
                height: 80,
                width: 80,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.translate('no_transactions_yet'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.translate('empty_transactions_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(context.translate('add_transaction')),
            ),
          ],
        ),
      ),
    );
  }
}

// Loading Skeleton
class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ],
    );
  }
}

// Error state view
class ErrorStateView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '${context.translate('something_went_wrong')}: $errorMessage',
              style: TextStyle(color: Colors.red.shade900),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onRetry,
                  child: Text(context.translate('retry')),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // Continue Offline by clear state errors
                  },
                  child: Text(context.translate('continue_offline')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Action Buttons (Fixed, Cash In / Cash Out)
class BottomActionButtons extends ConsumerWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAccountUuid = ref.watch(currentAccountProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final currency = settingsAsync.maybeWhen(
      data: (s) => s.currency,
      orElse: () => 'USD',
    );

    return Material(
      elevation: 8,
      color: Theme.of(context).cardColor,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Cash In Button (Income)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.income,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTransactionScreen(
                        transaction: TransactionEntity(
                          uuid: '',
                          accountId: (currentAccountUuid ?? ''),
                          type: 'income',
                          categoryId: AppCategories.income.first,
                          category: AppCategories.income.first,
                          amount: 0.0,
                          title: '',
                          description: '',
                          currency: currency,
                          paymentMethod: 'Cash',
                          isDeleted: false,
                          isSynced: false,
                          isRecurring: false,
                          date: DateTime.now(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          syncVersion: 1,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_upward),
                label: Text(context.translate('cash_in'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),

            // Cash Out Button (Expense)
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expense,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTransactionScreen(
                        transaction: TransactionEntity(
                          uuid: '',
                          accountId: (currentAccountUuid ?? ''),
                          type: 'expense',
                          categoryId: AppCategories.expense.first,
                          category: AppCategories.expense.first,
                          amount: 0.0,
                          title: '',
                          description: '',
                          currency: currency,
                          paymentMethod: 'Cash',
                          isDeleted: false,
                          isSynced: false,
                          isRecurring: false,
                          date: DateTime.now(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                          syncVersion: 1,
                        ),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_downward),
                label: Text(context.translate('cash_out'), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class EmptyAccountView extends StatelessWidget {
  const EmptyAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              context.translate('no_accounts_yet'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              context.translate('create_first_account'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateAccountScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(context.translate('create_account')),
            ),
          ],
        ),
      ),
    );
  }
}
class DeleteTransactionDialog extends StatelessWidget {
  const DeleteTransactionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.translate('delete_transaction')),
      content: Text(
        context.translate('delete_transaction_confirmation'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.translate('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.translate('delete')),
        ),
      ],
    );
  }
}
