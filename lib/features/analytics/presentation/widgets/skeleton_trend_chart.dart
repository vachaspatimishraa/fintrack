import 'package:flutter/material.dart';

class SkeletonTrendChart extends StatelessWidget {
  const SkeletonTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHighest;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 20, width: double.infinity, color: color),
            const SizedBox(height: 16),
            Container(height: 180, width: double.infinity, color: color),
          ],
        ),
      ),
    );
  }
}
