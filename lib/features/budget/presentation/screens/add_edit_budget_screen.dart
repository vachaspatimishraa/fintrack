import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_entity.dart';
import '../controllers/budget_controller.dart';
import '../../../../core/constants/app_categories.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budget;

  const AddEditBudgetScreen({super.key, this.budget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _thresholdController;
  
  late String _budgetType;
  String? _categoryId;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _rolloverEnabled;
  late double _alertThreshold;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    _titleController = TextEditingController(text: b?.title ?? '');
    _amountController = TextEditingController(text: b?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _thresholdController = TextEditingController(text: b?.alertThreshold.toString() ?? '80');
    
    _budgetType = b?.budgetType ?? 'overall';
    _categoryId = b?.categoryId;
    _startDate = b?.startDate ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    _endDate = b?.endDate ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    _rolloverEnabled = b?.rolloverEnabled ?? false;
    _alertThreshold = b?.alertThreshold ?? 80.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final controller = ref.read(budgetControllerProvider);
      final budget = (widget.budget ?? BudgetEntity(
        uuid: '',
        ownerId: '', // Set by repository
        title: _titleController.text,
        budgetType: _budgetType,
        amount: double.parse(_amountController.text),
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )).copyWith(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        budgetType: _budgetType,
        categoryId: _budgetType == 'category' ? _categoryId : null,
        startDate: _startDate,
        endDate: _endDate,
        rolloverEnabled: _rolloverEnabled,
        alertThreshold: double.tryParse(_thresholdController.text) ?? 80.0,
      );

      if (widget.budget == null) {
        await controller.createBudget(budget);
      } else {
        await controller.updateBudget(budget);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget ${widget.budget == null ? 'created' : 'updated'} successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Create Budget' : 'Edit Budget'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Budget Name*', hintText: 'e.g. Monthly Groceries'),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount*', prefixText: '₹ '),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _thresholdController,
                    decoration: const InputDecoration(labelText: 'Alert at (%)', suffixText: '%'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _budgetType,
              decoration: const InputDecoration(labelText: 'Budget Type'),
              items: const [
                DropdownMenuItem(value: 'overall', child: Text('Overall Budget')),
                DropdownMenuItem(value: 'category', child: Text('Category Budget')),
              ],
              onChanged: (val) => setState(() => _budgetType = val!),
            ),
            if (_budgetType == 'category') ...[
              const SizedBox(height: 16),
              // Category dropdown - using AppCategories for now, should ideally come from categoryProvider
              DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Select Category'),
                items: AppCategories.expense.map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                )).toList(),
                onChanged: (val) => setState(() => _categoryId = val),
                validator: (val) => _budgetType == 'category' && val == null ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Date Range'),
              subtitle: Text('${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateRange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Rollover'),
              subtitle: const Text('Carry forward remaining balance to next month'),
              value: _rolloverEnabled,
              onChanged: (val) => setState(() => _rolloverEnabled = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Text(widget.budget == null ? 'Create Budget' : 'Update Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
