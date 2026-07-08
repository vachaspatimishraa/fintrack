import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/transaction_list_controller.dart';
import '../controllers/selection_controller.dart';
import 'add_edit_transaction_screen.dart';
import '../widgets/search_bar.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/sort_bottom_sheet.dart';
import '../widgets/transaction_timeline.dart';
import '../widgets/empty_transaction_view.dart';
import '../widgets/loading_skeleton.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionListProvider.notifier).loadMore();
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SortBottomSheet(),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(transactionListProvider);
    final selectionState = ref.watch(selectionProvider);
    final selectionNotifier = ref.read(selectionProvider.notifier);

    final isSelectionMode = selectionState.isSelectionMode;

    return PopScope(
      canPop: !isSelectionMode,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (isSelectionMode) {
          selectionNotifier.clearSelection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: isSelectionMode
              ? Text('${selectionState.selectedUuids.length} ${context.translate('selected')}')
              : Text(context.translate('transactions')),
          actions: isSelectionMode
              ? [
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: context.translate('share_selected'),
                    onPressed: selectionNotifier.shareSelected,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: context.translate('delete_selected'),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(context.translate('delete_selected_title')),
                          content: Text(
                            context.translate('delete_selected_desc').replaceFirst('{count}', selectionState.selectedUuids.length.toString()),
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
                        ),
                      );
                      if (confirm == true) {
                        await selectionNotifier.deleteSelected();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear),
                    tooltip: context.translate('cancel'),
                    onPressed: selectionNotifier.clearSelection,
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.sort),
                    tooltip: context.translate('sort_options'),
                    onPressed: _showSortSheet,
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: context.translate('filter_list'),
                    onPressed: _showFilterSheet,
                  ),
                ],
        ),
        body: Column(
          children: [
            if (!isSelectionMode) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TransactionSearchBar(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: QuickFilterChips(),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: listState.isLoading
                  ? const LoadingSkeleton()
                  : listState.error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${context.translate('error_loading_transactions')}: ${listState.error}', textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => ref.read(transactionListProvider.notifier).loadInitial(),
                                  child: Text(context.translate('retry')),
                                ),
                              ],
                            ),
                          ),
                        )
                      : listState.transactions.isEmpty
                          ? EmptyTransactionView(
                              title: context.translate('no_matching_transactions'),
                              subtitle: context.translate('no_matching_transactions_sub'),
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref.read(transactionListProvider.notifier).refresh(),
                              child: CustomScrollView(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  TransactionTimeline(transactions: listState.transactions),
                                  if (listState.isLoadMore)
                                    const SliverToBoxAdapter(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      ),
                                    ),
                                ],
                              ),
                            ),
            ),
          ],
        ),
        floatingActionButton: isSelectionMode
            ? null
            : FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditTransactionScreen(),
                    ),
                  ).then((_) {
                    ref.read(transactionListProvider.notifier).loadInitial();
                  });
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }
}
