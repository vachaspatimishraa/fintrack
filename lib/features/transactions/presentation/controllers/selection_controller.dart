import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../home/providers/home_provider.dart';
import '../../providers/transaction_provider.dart';
import 'transaction_list_controller.dart';

class SelectionState {
  final Set<String> selectedUuids;
  final bool isSelectionMode;

  const SelectionState({
    this.selectedUuids = const {},
    this.isSelectionMode = false,
  });

  SelectionState copyWith({
    Set<String>? selectedUuids,
    bool? isSelectionMode,
  }) {
    return SelectionState(
      selectedUuids: selectedUuids ?? this.selectedUuids,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }
}

class SelectionNotifier extends StateNotifier<SelectionState> {
  final Ref _ref;

  SelectionNotifier(this._ref) : super(const SelectionState());

  void toggleSelection(String uuid) {
    final current = Set<String>.from(state.selectedUuids);
    if (current.contains(uuid)) {
      current.remove(uuid);
    } else {
      current.add(uuid);
    }

    state = state.copyWith(
      selectedUuids: current,
      isSelectionMode: current.isNotEmpty,
    );
  }

  void enterSelectionMode(String initialUuid) {
    state = SelectionState(
      selectedUuids: {initialUuid},
      isSelectionMode: true,
    );
  }

  void clearSelection() {
    state = const SelectionState();
  }

  Future<void> deleteSelected() async {
    if (state.selectedUuids.isEmpty) return;

    final repo = _ref.read(transactionRepositoryProvider);
    final uuidsToDelete = List<String>.from(state.selectedUuids);

    for (final uuid in uuidsToDelete) {
      await repo.deleteTransaction(uuid);
    }

    _ref.invalidate(transactionsStreamProvider);
    _ref.invalidate(homeStateProvider);

    clearSelection();
    // Refresh the paginated transactions list
    _ref.read(transactionListProvider.notifier).loadInitial();
  }

  void shareSelected() {
    if (state.selectedUuids.isEmpty) return;

    final transactions = _ref.read(transactionListProvider).transactions;
    final selectedTxs = transactions.where((tx) => state.selectedUuids.contains(tx.uuid));

    if (selectedTxs.isEmpty) return;

    final buffer = StringBuffer('FinTrack Shared Transactions Export:\n\n');
    for (final tx in selectedTxs) {
      buffer.writeln('- ${tx.title}: \$${tx.amount.toStringAsFixed(2)} (${tx.type.toUpperCase()}) on ${tx.date.day}/${tx.date.month}/${tx.date.year}');
    }

    Share.share(buffer.toString());
    clearSelection();
  }
}

final selectionProvider =
    StateNotifierProvider<SelectionNotifier, SelectionState>((ref) {
  return SelectionNotifier(ref);
});
