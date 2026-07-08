import 'package:flutter/material.dart';
import 'skeleton_loaders.dart';

class SkeletonMonthlyReport extends StatelessWidget {
  const SkeletonMonthlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month selector skeleton
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          // Summary cards skeleton
          const Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              SizedBox(width: 12),
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: SkeletonCard(height: 120)),
              SizedBox(width: 12),
              Expanded(child: SkeletonCard(height: 120)),
            ],
          ),
          const SizedBox(height: 16),
          // Budget skeleton card
          const SkeletonCard(height: 160),
          const SizedBox(height: 16),
          // Categories Pie chart skeleton card
          const SkeletonCard(height: 220),
          const SizedBox(height: 16),
          // Trend chart skeleton
          const SkeletonChart(height: 200),
          const SizedBox(height: 16),
          // Financial score skeleton
          const SkeletonCard(height: 140),
          const SizedBox(height: 16),
          // Recommendations skeleton
          const SkeletonCard(height: 180),
        ],
      ),
    );
  }
}
