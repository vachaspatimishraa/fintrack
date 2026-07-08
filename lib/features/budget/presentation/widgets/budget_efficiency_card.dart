import 'package:flutter/material.dart';

class BudgetEfficiencyCard extends StatelessWidget {
  final double score;
  final String status;

  const BudgetEfficiencyCard({super.key, required this.score, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green;
    if (score < 20) {
      color = Colors.red;
    } else if (score < 40) color = Colors.deepOrange;
    else if (score < 60) color = Colors.orange;
    else if (score < 80) color = Colors.amber;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Budget Efficiency Score', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Your efficiency is based on budget compliance and savings rate.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
