import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/utils/formatter.dart';
import '../../../../core/utils/translations.dart';
import 'currency_selection_screen.dart';
import 'language_selection_screen.dart';

class LocalizationScreen extends ConsumerWidget {
  const LocalizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('currency_localization')),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, context.translate('regional_settings')),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: Text(context.translate('currency')),
                    subtitle: Text(settings.currency),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CurrencySelectionScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(context.translate('language')),
                    subtitle: Text(settings.language == 'en' ? 'English' : 'Hindi'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle(context, context.translate('format_previews')),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildPreviewRow(
                      context.translate('currency_format'),
                      AppFormatter.formatCurrency(12345.67),
                    ),
                    const Divider(height: 24),
                    _buildPreviewRow(
                      context.translate('date_format'),
                      AppFormatter.formatDate(DateTime.now()),
                    ),
                    const Divider(height: 24),
                    _buildPreviewRow(
                      context.translate('number_format'),
                      AppFormatter.formatCurrency(123456.0).replaceAll(RegExp(r'[^0-9,.]'), '').trim(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
