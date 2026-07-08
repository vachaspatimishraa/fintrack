import 'package:flutter/material.dart';

class CalendarFilterSheet extends StatefulWidget {
  final bool includeIncome;
  final bool includeExpense;
  final ValueChanged<({bool includeIncome, bool includeExpense})> onApply;

  const CalendarFilterSheet({
    super.key,
    required this.includeIncome,
    required this.includeExpense,
    required this.onApply,
  });

  @override
  State<CalendarFilterSheet> createState() => _CalendarFilterSheetState();
}

class _CalendarFilterSheetState extends State<CalendarFilterSheet> {
  late bool _includeIncome;
  late bool _includeExpense;

  @override
  void initState() {
    super.initState();
    _includeIncome = widget.includeIncome;
    _includeExpense = widget.includeExpense;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Calendar Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _includeIncome,
              title: const Text('Income'),
              onChanged: (value) => setState(() => _includeIncome = value),
            ),
            SwitchListTile(
              value: _includeExpense,
              title: const Text('Expense'),
              onChanged: (value) => setState(() => _includeExpense = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                widget.onApply((
                  includeIncome: _includeIncome,
                  includeExpense: _includeExpense,
                ));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
