import 'package:flutter/material.dart';
import 'skeleton_loaders.dart';

class SkeletonYearlyReport extends StatelessWidget {
  const SkeletonYearlyReport({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Year selector skeleton
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
          // Monthly Overview skeleton (a chart loader)
          const SkeletonChart(height: 220),
          const SizedBox(height: 16),
          // Category Distribution chart skeleton card
          const SkeletonCard(height: 220),
          const SizedBox(height: 16),
          // Budget skeleton card
          const SkeletonCard(height: 160),
          const SizedBox(height: 16),
          // Financial Health skeleton
          const SkeletonCard(height: 140),
          const SizedBox(height: 16),
          // Insights skeleton
          const SkeletonCard(height: 180),
        ],
      ),
    );
  }
}
