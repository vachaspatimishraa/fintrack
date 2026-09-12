import 'package:flutter/material.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/budget/presentation/widgets/budget_card.dart';

class CategoryBudgetGrid extends StatelessWidget {
  final List<BudgetEntity> budgets;

  const CategoryBudgetGrid({super.key, required this.budgets});

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Budgets',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to category budget screen if needed
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            return BudgetCard(budget: budgets[index]);
          },
        ),
      ],
    );
  }
}
