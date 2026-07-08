import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/custom_report_data.dart';
import '../../providers/custom_report_provider.dart';
import '../controllers/custom_report_controller.dart';
import 'package:intl/intl.dart';

class ReportPreviewScreen extends ConsumerWidget {
  const ReportPreviewScreen({super.key});

  Color _getCategoryColor(String name) {
    const palette = [
      '#6750A4',
      '#006A6A',
      '#B3261E',
      '#386A20',
      '#7D5260',
      '#625B71',
      '#005DB7',
      '#8C5000',
      '#006D3B',
      '#7F4E1D',
    ];
    final index = name.codeUnits.fold<int>(0, (sum, code) => sum + code) % palette.length;
    return Color(int.parse(palette[index].replaceFirst('#', '0xff')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datasetAsync = ref.watch(customReportDatasetProvider);
    final controller = ref.watch(customReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Preview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              datasetAsync.whenData((dataset) => controller.shareReport(dataset));
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              datasetAsync.whenData((dataset) => controller.exportPDF(dataset));
            },
          ),
        ],
      ),
      body: datasetAsync.when(
        data: (dataset) {
          if (dataset.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.query_stats_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No transactions matched the criteria', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Try modifying your filters', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterSummary(context, dataset.filter),
                const SizedBox(height: 16),
                _buildMetricsGrid(context, dataset.stats),
                const SizedBox(height: 16),
                if (dataset.groups.isNotEmpty) ...[
                  _buildChartCard(context, dataset.groups),
                  const SizedBox(height: 16),
                ],
                _buildTransactionsList(context, dataset.transactions),
                const SizedBox(height: 24),
                _buildExportSection(context, dataset, controller),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading report preview: $err')),
      ),
    );
  }

  Widget _buildFilterSummary(BuildContext context, CustomReportFilter filter) {
    final theme = Theme.of(context);
    final chips = <Widget>[];

    if (filter.startDate != null || filter.endDate != null) {
      chips.add(Chip(label: const Text('Date Range Active'), avatar: const Icon(Icons.calendar_today, size: 14)));
    }
    if (filter.selectedAccounts.isNotEmpty) {
      chips.add(Chip(label: Text('${filter.selectedAccounts.length} Accounts'), avatar: const Icon(Icons.account_balance, size: 14)));
    }
    if (filter.selectedCategories.isNotEmpty) {
      chips.add(Chip(label: Text('${filter.selectedCategories.length} Categories'), avatar: const Icon(Icons.category, size: 14)));
    }
    if (filter.selectedTypes.isNotEmpty) {
      chips.add(Chip(label: Text('${filter.selectedTypes.length} Types'), avatar: const Icon(Icons.filter_list, size: 14)));
    }
    if (filter.minAmount != null || filter.maxAmount != null) {
      chips.add(Chip(label: const Text('Amount Threshold'), avatar: const Icon(Icons.money, size: 14)));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Applied Filters', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 4, children: chips),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, CustomReportStats stats) {
    final theme = Theme.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _MetricCard(label: 'Total Income', value: AppFormatter.formatCurrency(stats.income), color: const Color(0xFF10B981)),
        _MetricCard(label: 'Total Expense', value: AppFormatter.formatCurrency(stats.expense), color: const Color(0xFFF43F5E)),
        _MetricCard(label: 'Net Savings', value: AppFormatter.formatCurrency(stats.savings), color: Colors.blue),
        _MetricCard(label: 'Avg Transaction', value: AppFormatter.formatCurrency(stats.averageTransaction), color: theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildChartCard(BuildContext context, List<CustomReportGroup> groups) {
    final theme = Theme.of(context);
    final double totalExpenses = groups.fold<double>(0, (sum, g) => sum + g.expense);
    final double totalValue = totalExpenses <= 0 ? groups.fold<double>(0, (sum, g) => sum + g.income) : totalExpenses;

    final List<PieSliceData> slices = groups.map((g) {
      final value = g.expense > 0 ? g.expense : g.income;
      final percentage = totalValue > 0 ? (value / totalValue) * 100 : 0.0;
      return PieSliceData(
        name: g.name,
        value: value,
        percentage: percentage,
        color: _getCategoryColor(g.name),
      );
    }).toList();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Dataset Distribution', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _PiePainter(slices: slices),
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(5, slices.length),
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final slice = slices[index];
                return Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(slice.name, style: theme.textTheme.bodySmall)),
                    Text(
                      '${AppFormatter.formatCurrency(slice.value)} (${slice.percentage.toStringAsFixed(1)}%)',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, List<dynamic> txs) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Matching Transactions', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('${txs.length} total', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(10, txs.length),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tx = txs[index];
                final isIncome = tx.type == 'income';

                return ListTile(
                  title: Text(tx.title),
                  subtitle: Text('${tx.category} | ${DateFormat('d MMM yyyy').format(tx.date)}'),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${AppFormatter.formatCurrency(tx.amount)}',
                    style: TextStyle(
                      color: isIncome ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(BuildContext context, CustomReportDataset dataset, CustomReportController controller) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Export Formats', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF'),
                  onPressed: () => controller.exportPDF(dataset),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.grid_on, size: 18),
                  label: const Text('Excel'),
                  onPressed: () => controller.exportExcel(dataset),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: const Text('CSV'),
                  onPressed: () => controller.exportCSV(dataset),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Print'),
                  onPressed: () => controller.printReport(dataset),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PieSliceData {
  final String name;
  final double value;
  final double percentage;
  final Color color;

  PieSliceData({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class _PiePainter extends CustomPainter {
  final List<PieSliceData> slices;

  _PiePainter({required this.slices});

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.9;
    double startAngle = -pi / 2;

    for (final slice in slices) {
      final sweepAngle = (slice.percentage / 100) * 2 * pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) => true;
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
