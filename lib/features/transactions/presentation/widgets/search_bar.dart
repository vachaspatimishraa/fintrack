import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_list_controller.dart';

class TransactionSearchBar extends ConsumerStatefulWidget {
  const TransactionSearchBar({super.key});

  @override
  ConsumerState<TransactionSearchBar> createState() => _TransactionSearchBarState();
}

class _TransactionSearchBarState extends ConsumerState<TransactionSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Synchronize initial filter text if any
    final currentQuery = ref.read(transactionListProvider).filter.query;
    _controller.text = currentQuery;
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(transactionListProvider.notifier).updateQuery(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for outer resets to clear the search bar text
    ref.listen<TransactionListState>(transactionListProvider, (prev, next) {
      if (next.filter.query.isEmpty && _controller.text.isNotEmpty) {
        _controller.clear();
      }
    });

    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search title, notes...',
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                onPressed: () {
                  _controller.clear();
                  ref.read(transactionListProvider.notifier).updateQuery('');
                },
              )
            : null,
      ),
    );
  }
}
