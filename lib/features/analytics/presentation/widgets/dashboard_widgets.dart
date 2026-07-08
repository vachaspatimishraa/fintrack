import 'package:flutter/material.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        )),
      ),
    );
  }
}

class EmptyDashboardView extends StatelessWidget {
  final VoidCallback onAddTransaction;

  const EmptyDashboardView({super.key, required this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.4,
            child: Image.asset(
              'assets/images/logo.png',
              height: 64,
              width: 64,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Financial Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Start adding transactions to see insights.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAddTransaction,
            child: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.amber.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, size: 16, color: Colors.amber),
          SizedBox(width: 8),
          Text(
            'Offline: Analytics are using local data.',
            style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
