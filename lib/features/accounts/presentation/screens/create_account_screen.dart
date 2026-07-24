import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fintrack/core/constants/routes.dart';
import '../../../../core/database/isar/collections/account_model.dart';
import '../../../../core/utils/translations.dart';
import '../../../settings/domain/entities/currency_entity.dart';
import '../../../settings/providers/settings_provider.dart';
import '../controllers/account_controller.dart';
import '../../providers/account_provider.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  final AccountModel? account;

  const CreateAccountScreen({super.key, this.account});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _type;
  late double _balance;
  late String _icon;
  late int _colorValue;
  String? _notes;

  final List<String> _types = ['Cash', 'Bank', 'Card', 'Savings', 'Investment', 'Custom'];
  final Map<String, String> _typeTranslations = {
    'Cash': 'account_type_cash',
    'Bank': 'account_type_bank',
    'Card': 'account_type_card',
    'Savings': 'account_type_savings',
    'Investment': 'account_type_investment',
    'Custom': 'account_type_custom',
  };
  final List<Map<String, dynamic>> _icons = [
    {'name': 'wallet', 'icon': Icons.account_balance_wallet_outlined},
    {'name': 'credit_card', 'icon': Icons.credit_card_outlined},
    {'name': 'bank', 'icon': Icons.account_balance_outlined},
    {'name': 'savings', 'icon': Icons.savings_outlined},
  ];
  final List<Color> _colors = [
    Colors.indigo,
    Colors.teal,
    Colors.amber.shade800,
    Colors.purple,
    Colors.blueGrey,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    final acc = widget.account;
    _name = acc?.name ?? '';
    _type = acc?.type ?? 'Cash';
    _balance = acc?.balance ?? 0.0;
    _icon = acc?.icon ?? 'wallet';
    _colorValue = acc?.colorValue ?? Colors.indigo.value;
    _notes = acc?.notes;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.account != null;
    final controller = ref.read(accountControllerProvider);
    final settings = ref.watch(settingsProvider).value;
    final theme = Theme.of(context);
    final currencyCode = settings?.currency ?? 'INR';
    final currencySymbol = CurrencyEntity.supportedCurrencies
        .firstWhere((c) => c.code == currencyCode)
        .symbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.translate('edit_account') : 'Create Your First Wallet'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isEditing) ...[
                        Text(
                          'Create Your First Wallet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'A Wallet represents where your money is stored or managed for a specific purpose.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: context.translate('account_name'),
                          hintText: 'e.g. Cash, SBI, Nainital Trip, Business',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return context.translate('enter_account_name');
                          }
                          if (val.trim().length > 40) {
                            return context.translate('max_chars_40');
                          }
                          final activeAccs = ref.read(accountsStreamProvider).value ?? [];
                          final duplicate = activeAccs.any((a) => a.name.trim().toLowerCase() == val.trim().toLowerCase() && a.uuid != widget.account?.uuid);
                          if (duplicate) {
                            return context.translate('account_already_exists');
                          }
                          return null;
                        },
                        onSaved: (val) => _name = val!.trim(),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: InputDecoration(
                          labelText: '${context.translate('account_type')} (${context.translate('optional')})',
                          border: const OutlineInputBorder(),
                        ),
                        items: _types
                            .map((type) => DropdownMenuItem(value: type, child: Text(context.translate(_typeTranslations[type] ?? type))))
                            .toList(),
                        onChanged: (val) => setState(() => _type = val!),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: isEditing ? _balance.toString() : '',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: '${context.translate('starting_balance')} (${context.translate('optional')})',
                          hintText: '0.00 (${context.translate('optional')})',
                          prefixText: '$currencySymbol ',
                          border: const OutlineInputBorder(),
                          helperText: context.translate('leave_empty_for_zero'),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return null; // Optional
                          if (double.tryParse(val) == null) return context.translate('enter_valid_amount');
                          return null;
                        },
                        onSaved: (val) {
                          if (val == null || val.isEmpty) {
                            _balance = 0.0;
                          } else {
                            _balance = double.parse(val);
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        initialValue: _notes,
                        decoration: InputDecoration(
                          labelText: context.translate('notes_optional'),
                          border: const OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        maxLength: 500,
                        validator: (val) {
                          if (val != null && val.length > 500) {
                            return context.translate('max_chars_500');
                          }
                          return null;
                        },
                        onSaved: (val) => _notes = val?.trim(),
                      ),
                      const SizedBox(height: 24),
                      Text(context.translate('select_icon'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _icons.map((iconMap) {
                          final name = iconMap['name'] as String;
                          final iconData = iconMap['icon'] as IconData;
                          final isSelected = _icon == name;
                          return IconButton.filledTonal(
                            onPressed: () => setState(() => _icon = name),
                            icon: Icon(iconData),
                            isSelected: isSelected,
                            selectedIcon: Icon(iconData, color: Colors.white),
                            style: IconButton.styleFrom(
                              backgroundColor: isSelected ? Color(_colorValue) : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text(context.translate('select_color_theme'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _colors.map((color) {
                          final isSelected = _colorValue == color.value;
                          return GestureDetector(
                            onTap: () => setState(() => _colorValue = color.value),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(Icons.check, size: 20, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom submit button (never scrolls)
            Material(
              elevation: 3,
              color: Theme.of(context).cardColor,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                child: FilledButton(
                  onPressed: () => _save(controller),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Color(_colorValue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isEditing ? context.translate('save_changes') : context.translate('create_account'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save(AccountController controller) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final account = widget.account ?? AccountModel();
    try {
      await controller.saveAccount(
        account: account,
        name: _name,
        type: _type,
        balance: _balance,
        icon: _icon,
        colorValue: _colorValue,
        notes: _notes,
        openingBalanceTitle: context.translate('opening_balance'),
        openingBalanceDesc: '${context.translate('opening_balance_desc')}$_name',
      );
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.account != null
                  ? context.translate('account_updated')
                  : context.translate('account_created_success'),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("ACCOUNT SAVE FAILED");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
