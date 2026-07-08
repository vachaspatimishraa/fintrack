import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../../core/constants/app_categories.dart';
import '../controllers/transaction_list_controller.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String? _type;
  late List<String> _categories;
  late String? _accountId;
  late String? _paymentMethod;
  late DateTimeRange? _dateRange;
  late double? _minAmount;
  late double? _maxAmount;
  late String? _amountComparison;
  late bool? _hasReceipt;
  late String? _syncStatus;

  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  static const List<String> _paymentMethods = [
    'Cash',
    'UPI',
    'Debit Card',
    'Credit Card',
    'Wallet',
    'Bank Transfer',
    'Cheque',
  ];

  @override
  void initState() {
    super.initState();
    final current = ref.read(transactionListProvider).filter;
    _type = current.type;
    _categories = List<String>.from(current.categories);
    _accountId = current.accountId;
    _paymentMethod = current.paymentMethod;
    _dateRange = current.dateRange;
    _minAmount = current.minAmount;
    _maxAmount = current.maxAmount;
    _amountComparison = current.amountComparison ?? 'between';
    _hasReceipt = current.hasReceipt;
    _syncStatus = current.syncStatus;

    if (_minAmount != null) _minAmountController.text = _minAmount!.toString();
    if (_maxAmount != null) _maxAmountController.text = _maxAmount!.toString();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final min = double.tryParse(_minAmountController.text);
    final max = double.tryParse(_maxAmountController.text);

    final current = ref.read(transactionListProvider).filter;
    final updated = current.copyWith(
      type: _type,
      categories: _categories,
      accountId: _accountId,
      paymentMethod: _paymentMethod,
      dateRange: _dateRange,
      minAmount: min,
      maxAmount: max,
      amountComparison: _amountComparison,
      hasReceipt: _hasReceipt,
      syncStatus: _syncStatus,
    );

    ref.read(transactionListProvider.notifier).updateFilter(updated);
    Navigator.pop(context);
  }

  void _resetFilters() {
    ref.read(transactionListProvider.notifier).resetFilters();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final allCategories = <dynamic>{...AppCategories.income, ...AppCategories.expense}.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Advanced Filters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset All'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Type filter
                    const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('All')),
                        ButtonSegment(value: 'income', label: Text('Income')),
                        ButtonSegment(value: 'expense', label: Text('Expense')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (val) {
                        setState(() {
                          _type = val.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Date range picker
                    const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _dateRange == null
                            ? 'Any Date'
                            : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: _dateRange != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _dateRange = null),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDateRange: _dateRange,
                        );
                        if (picked != null) {
                          setState(() => _dateRange = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Accounts selection
                    const Text('Account / Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    accountsAsync.when(
                      data: (accounts) {
                        return DropdownButtonFormField<String?>(
                          initialValue: _accountId,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Accounts')),
                            ...accounts.map(
                              (acc) => DropdownMenuItem(value: acc.uuid, child: Text(acc.name)),
                            ),
                          ],
                          onChanged: (val) => setState(() => _accountId = val),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (err, _) => Text('Error: $err'),
                    ),
                    const SizedBox(height: 20),

                    // Amount ranges
                    const Text('Amount Range', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _amountComparison,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      items: const [
                        DropdownMenuItem(value: 'greater', child: Text('Greater Than')),
                        DropdownMenuItem(value: 'less', child: Text('Less Than')),
                        DropdownMenuItem(value: 'between', child: Text('Between')),
                      ],
                      onChanged: (val) => setState(() => _amountComparison = val),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min Amount',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        if (_amountComparison == 'between') ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _maxAmountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Amount',
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Methods
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Methods')),
                        ..._paymentMethods.map(
                          (m) => DropdownMenuItem(value: m, child: Text(m)),
                        ),
                      ],
                      onChanged: (val) => setState(() => _paymentMethod = val),
                    ),
                    const SizedBox(height: 20),

                    // Receipts Attachment filter
                    const Text('Receipt Attachment', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<bool?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('All')),
                        ButtonSegment(value: true, label: Text('With Receipt')),
                        ButtonSegment(value: false, label: Text('No Receipt')),
                      ],
                      selected: {_hasReceipt},
                      onSelectionChanged: (val) {
                        setState(() {
                          _hasReceipt = val.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sync Status
                    const Text('Sync Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SegmentedButton<String?>(
                      segments: const [
                        ButtonSegment(value: null, label: Text('All')),
                        ButtonSegment(value: 'synced', label: Text('Synced')),
                        ButtonSegment(value: 'pending', label: Text('Pending')),
                      ],
                      selected: {_syncStatus},
                      onSelectionChanged: (val) {
                        setState(() {
                          _syncStatus = val.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // Categories Multiselect Checkboxes
                    const Text('Select Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allCategories.length,
                        itemBuilder: (context, index) {
                          final cat = allCategories[index];
                          final isChecked = _categories.contains(cat);
                          return CheckboxListTile(
                            title: Text(cat),
                            value: isChecked,
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _categories.add(cat);
                                } else {
                                  _categories.remove(cat);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
