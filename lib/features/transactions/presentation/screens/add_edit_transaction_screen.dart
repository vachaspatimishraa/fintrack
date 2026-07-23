import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_categories.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/translations.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/utils/validation_service.dart';
import '../../../accounts/providers/account_provider.dart';
import '../controllers/transaction_controller.dart';
import '../../../../core/services/receipt_service.dart';
import '../widgets/category_picker_bottom_sheet.dart';
import '../widgets/receipt_picker_bottom_sheet.dart';
import '../../domain/utils/draft_manager.dart';
import '../../../settings/domain/entities/currency_entity.dart';
import '../../../settings/providers/settings_provider.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transaction;
  final String? initialType;
  final String? initialAccountId;

  const AddEditTransactionScreen({
    super.key,
    this.transaction,
    this.initialType,
    this.initialAccountId,
  });

  @override
  ConsumerState<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState
    extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiptService = ReceiptService();
  final _scrollController = ScrollController();
  final _amountFocusNode = FocusNode();

  late double _amount;
  late String _type;
  late String _category;
  late String _accountId;
  late String _description;
  late String _paymentMethod;
  late DateTime _date;
  String? _receiptUrl;
  String? _receiptLocalPath;
  File? _selectedImageFile;

  bool _isSaving = false;

  // Track field touch/changes for live validation
  String _amountStr = '';
  String _titleStr = '';

  static const String _prefLastPaymentMethodKey = 'last_used_payment_method';
  static const Map<String, String> _paymentMethodsMap = {
    'Cash': 'payment_cash',
    'UPI': 'payment_upi',
    'Debit Card': 'payment_debit_card',
    'Credit Card': 'payment_credit_card',
    'Wallet': 'payment_wallet',
    'Bank Transfer': 'payment_bank_transfer',
    'Cheque': 'payment_cheque',
    'Net Banking': 'payment_net_banking',
  };

  static const List<String> _paymentMethods = [
    'Cash',
    'UPI',
    'Debit Card',
    'Credit Card',
    'Wallet',
    'Bank Transfer',
    'Cheque',
    'Net Banking',
  ];

  late TextEditingController _amountController;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void dispose() {
    if (widget.transaction == null &&
        (_titleController.text.isNotEmpty ||
            _amountController.text.isNotEmpty)) {
      DraftManager.saveDraft({
        'amount': _amountController.text,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _category,
        'paymentMethod': _paymentMethod,
        'type': _type,
        'date': _date.toIso8601String(),
      });
    }
    _amountController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final isEditing = tx != null && tx.uuid.isNotEmpty;

    _type = isEditing ? tx.type : (widget.initialType ?? 'expense');

    _amount = isEditing ? tx.amount : 0.0;
    _amountStr = isEditing && tx.amount > 0 ? tx.amount.toString() : '';

    _category = isEditing
        ? tx.category
        : (_type == 'income'
            ? AppCategories.income.first
            : AppCategories.expense.first);

    _accountId = isEditing ? tx.accountId : (widget.initialAccountId ?? '');
    _description = isEditing ? tx.description : '';
    _titleStr = isEditing ? tx.title : '';
    _paymentMethod = isEditing ? tx.paymentMethod : 'Cash';
    _date = isEditing ? tx.date : DateTime.now();
    _receiptUrl = isEditing ? tx.receiptUrl : null;
    _receiptLocalPath = isEditing ? tx.receiptLocalPath : null;

    _amountController = TextEditingController(text: _amountStr);
    _titleController = TextEditingController(text: _titleStr);
    _descriptionController = TextEditingController(text: _description);

    _amountFocusNode.addListener(() {
      if (_amountFocusNode.hasFocus) {
        if (_amountController.text == '0.0' || _amountController.text == '0') {
          _amountController.clear();
        }
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });

    if (tx == null) {
      _loadLastPaymentMethod();
      _loadDraft();
    }
  }

  void _loadDraft() async {
    final draft = await DraftManager.loadDraft();
    if (draft != null && mounted) {
      final restore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.translate('restore_draft')),
          content: Text(context.translate('restore_draft_desc')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.translate('discard')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.translate('restore')),
            ),
          ],
        ),
      );

      if (restore == true) {
        setState(() {
          _amountController.text = draft['amount'] ?? '';
          _amountStr = draft['amount'] ?? '';
          _titleController.text = draft['title'] ?? '';
          _titleStr = draft['title'] ?? '';
          _descriptionController.text = draft['description'] ?? '';
          _description = draft['description'] ?? '';
          _category = draft['category'] ?? '';
          _paymentMethod = draft['paymentMethod'] ?? '';
          _type = draft['type'] ?? 'expense';
          if (draft['date'] != null) {
            _date = DateTime.parse(draft['date']);
          }
        });
      } else {
        await DraftManager.clearDraft();
      }
    }
  }

  Future<void> _loadLastPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPm = prefs.getString(_prefLastPaymentMethodKey);
    if (lastPm != null && _paymentMethods.contains(lastPm)) {
      if (mounted) {
        setState(() {
          _paymentMethod = lastPm;
        });
      }
    }
  }

  Future<void> _saveLastPaymentMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLastPaymentMethodKey, method);
  }

  bool get _isFormValid {
    if (ValidationService.validateAmount(_amountStr) != null) {
      return false;
    }
    if (ValidationService.validateTitle(_titleStr) != null) {
      return false;
    }
    if (ValidationService.validateCategory(_category) != null) {
      return false;
    }
    if (ValidationService.validatePaymentMethod(_paymentMethod) != null) {
      return false;
    }
    if (_accountId.isEmpty) {
      return false;
    }
    return true;
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return CategoryPickerBottomSheet(
          type: _type,
          selectedCategory: _category,
          onCategorySelected: (cat) {
            setState(() {
              _category = cat;
            });
          },
        );
      },
    );
  }

  void _showPaymentMethodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.translate('select_payment_method'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final pm = _paymentMethods[index];
                      final isSelected = _paymentMethod == pm;
                      final translationKey = _paymentMethodsMap[pm] ?? pm;
                      return ListTile(
                        title: Text(
                          context.translate(translationKey),
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            _paymentMethod = pm;
                          });
                          _saveLastPaymentMethod(pm);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final controller = ref.read(transactionControllerProvider);
    final isEditing = widget.transaction != null && widget.transaction!.uuid.isNotEmpty;
    final primaryThemeColor = _type == 'income'
        ? AppColors.income
        : AppColors.expense;
    final settings = ref.watch(settingsProvider).value;
    final currencyCode = settings?.currency ?? 'INR';
    final currencySymbol = CurrencyEntity.supportedCurrencies
        .firstWhere((c) => c.code == currencyCode)
        .symbol;

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(
            isEditing
                ? context.translate('edit_transaction')
                : context.translate('add_transaction'),
          ),
        ),
        body: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.translate('no_accounts_found'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.translate('create_account_before_tx'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(context.translate('go_back')),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (_accountId.isEmpty && accounts.isNotEmpty) {
              _accountId = accounts.first.uuid;
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: primaryThemeColor.withValues(
                          alpha: 0.2,
                        ),
                        selectedForegroundColor: primaryThemeColor,
                      ),
                      segments: [
                        ButtonSegment(
                          value: 'expense',
                          label: Text(context.translate('expense')),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: Text(context.translate('income')),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (val) {
                        setState(() {
                          _type = val.first;
                          _category = _type == 'income'
                              ? AppCategories.income.first
                              : AppCategories.expense.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: context.translate('amount'),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            currencySymbol,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryThemeColor,
                            ),
                          ),
                        ),
                        hintText: '0.00',
                      ),
                      validator: (val) {
                        final key = ValidationService.validateAmount(val);
                        return key != null ? context.translate(key) : null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _amountStr = val;
                        });
                      },
                      onSaved: (val) => _amount = double.parse(val!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _accountId,
                      decoration: InputDecoration(
                        labelText: context.translate('account_wallet'),
                      ),
                      items: accounts.map((acc) {
                        return DropdownMenuItem(
                          value: acc.uuid,
                          child: Text(acc.name),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _accountId = val!),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.translate('category')),
                      subtitle: Row(
                        children: [
                          Icon(
                            AppCategories.getIcon(_category),
                            color: primaryThemeColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _showCategoryPicker,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.translate('payment_method')),
                      subtitle: Text(
                        context.translate(
                          _paymentMethodsMap[_paymentMethod] ?? _paymentMethod,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _showPaymentMethodPicker,
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 60,
                      decoration: InputDecoration(
                        labelText: context.translate('title'),
                        hintText: context.translate('title_hint'),
                      ),
                      validator: (val) {
                        final key = ValidationService.validateTitle(val);
                        return key != null ? context.translate(key) : null;
                      },
                      onChanged: (val) {
                        setState(() {
                          _titleStr = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: context.translate('description_optional'),
                        hintText: context.translate('add_details'),
                      ),
                      validator: (val) {
                        final key = ValidationService.validateDescription(val);
                        return key != null ? context.translate(key) : null;
                      },
                      onSaved: (val) => _description = val?.trim() ?? '',
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      leading: const Icon(Icons.calendar_today),
                      title: Text(context.translate('date')),
                      trailing: Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) {
                          setState(() => _date = selected);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                context.translate('receipt_attachment'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_selectedImageFile != null ||
                                _receiptLocalPath != null ||
                                _receiptUrl != null)
                              Container(
                                height: 150,
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: _selectedImageFile != null
                                        ? FileImage(_selectedImageFile!)
                                        : (_receiptLocalPath != null
                                              ? FileImage(
                                                  File(_receiptLocalPath!),
                                                )
                                              : NetworkImage(_receiptUrl!)
                                                    as ImageProvider),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  onPressed: _showReceiptPicker,
                                  icon: const Icon(Icons.camera_alt),
                                  label: Text(
                                    _selectedImageFile != null ||
                                            _receiptLocalPath != null ||
                                            _receiptUrl != null
                                        ? context.translate('manage_receipt')
                                        : context.translate('add_receipt'),
                                  ),
                                ),
                                if (_selectedImageFile != null ||
                                    _receiptLocalPath != null ||
                                    _receiptUrl != null)
                                  TextButton.icon(
                                    onPressed: _showReceiptPreview,
                                    icon: const Icon(Icons.visibility),
                                    label: Text(context.translate('view')),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            );
          },
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, _) =>
              Center(child: Text('${context.translate('error')}: $err')),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryThemeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isFormValid && !_isSaving
                    ? () => _save(controller)
                    : null,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? context.translate('update_transaction')
                            : context.translate('save_transaction'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _receiptService.pickReceipt(source);
    if (file == null) return;

    setState(() {
      _selectedImageFile = file;
    });
  }

  void _showReceiptPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final hasReceipt =
            _selectedImageFile != null ||
            _receiptLocalPath != null ||
            _receiptUrl != null;
        return ReceiptPickerBottomSheet(
          hasReceipt: hasReceipt,
          onFilePicked: (file) {
            setState(() {
              _selectedImageFile = file;
            });
          },
          onRemove: () {
            setState(() {
              _selectedImageFile = null;
              _receiptLocalPath = null;
              _receiptUrl = null;
            });
          },
        );
      },
    );
  }

  void _showReceiptPreview() {
    final imageProvider = _selectedImageFile != null
        ? FileImage(_selectedImageFile!)
        : (_receiptLocalPath != null
              ? FileImage(File(_receiptLocalPath!))
              : NetworkImage(_receiptUrl!) as ImageProvider);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: InteractiveViewer(
            child: Image(image: imageProvider, fit: BoxFit.contain),
          ),
        );
      },
    );
  }

  void _showSuccessBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  context.translate('transaction_saved'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Close sheet and return home
                          Navigator.pop(context); // close bottom sheet
                          Navigator.pop(
                            this.context,
                          ); // close add transaction screen
                        },
                        child: Text(context.translate('done')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Reset form state for another entry
                          setState(() {
                            _amountStr = '';
                            _titleStr = '';
                            _description = '';
                            _selectedImageFile = null;
                            _receiptLocalPath = null;
                            _receiptUrl = null;
                            _formKey.currentState?.reset();
                          });
                          Navigator.pop(context); // close bottom sheet
                        },
                        child: Text(context.translate('add_another')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(TransactionController controller) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final settings = ref.read(settingsProvider).value;
    final currencyCode = settings?.currency ?? 'INR';

    setState(() {
      _isSaving = true;
    });

    try {
      String? localPath = _receiptLocalPath;
      String? cloudUrl = _receiptUrl;

      if (_selectedImageFile != null) {
        localPath = await _receiptService.saveReceiptLocally(
          _selectedImageFile!,
        );
        cloudUrl = null;
      }

      final tx =
          widget.transaction?.copyWith(
            amount: _amount,
            type: _type,
            categoryId: _category,
            category: _category,
            accountId: _accountId,
            title: _titleStr.trim(),
            description: _description,
            paymentMethod: _paymentMethod,
            date: _date,
            receiptLocalPath: localPath,
            receiptUrl: cloudUrl,
          ) ??
          TransactionEntity(
            uuid: '',
            accountId: _accountId,
            type: _type,
            categoryId: _category,
            category: _category,
            amount: _amount,
            title: _titleStr.trim(),
            description: _description,
            currency: currencyCode,
            paymentMethod: _paymentMethod,
            receiptLocalPath: localPath,
            receiptUrl: cloudUrl,
            isDeleted: false,
            isSynced: false,
            isRecurring: false,
            date: _date,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            syncVersion: 1,
          );

      await controller.saveTransaction(tx);
      await DraftManager.clearDraft();

      if (!mounted) return;

      // Show temporary helper snackbar if saved purely offline
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.translate('saved_locally_sync'))),
      );

      setState(() {
        _isSaving = false;
      });
      _showSuccessBottomSheet();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save transaction: $e')),
        );
      }
    }
  }
}
