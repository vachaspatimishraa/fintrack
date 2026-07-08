import 'package:flutter/material.dart';
import '../../../../core/utils/translations.dart';
import '../screens/add_edit_transaction_screen.dart';

class EmptyTransactionView extends StatelessWidget {
  final String? title;
  final String? subtitle;

  const EmptyTransactionView({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
            Text(
              title ?? context.translate('no_transactions_yet'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? context.translate('empty_transactions_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditTransactionScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(context.translate('add_transaction')),
            ),
          ],
        ),
      ),
    );
  }
}
