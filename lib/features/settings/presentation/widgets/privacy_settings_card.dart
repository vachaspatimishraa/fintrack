import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/settings_controller.dart';
import '../../domain/entities/settings_entity.dart';

class PrivacySettingsCard extends ConsumerWidget {
  final SettingsEntity settings;

  const PrivacySettingsCard({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(context.translate('hide_account_balances')),
            subtitle: Text(context.translate('hide_account_balances_desc')),
            secondary: const Icon(Icons.account_balance_wallet_outlined),
            value: settings.hideAccountBalances,
            onChanged: (val) => controller.toggleHideAccountBalances(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.translate('hide_dashboard_amounts')),
            subtitle: Text(context.translate('hide_dashboard_amounts_desc')),
            secondary: const Icon(Icons.dashboard_outlined),
            value: settings.hideDashboardAmounts,
            onChanged: (val) => controller.toggleHideDashboardAmounts(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.translate('hide_recent_transactions')),
            subtitle: Text(context.translate('hide_recent_transactions_desc')),
            secondary: const Icon(Icons.history),
            value: settings.hideRecentTransactions,
            onChanged: (val) => controller.toggleHideRecentTransactions(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.translate('hide_analytics_values')),
            subtitle: Text(context.translate('hide_analytics_values_desc')),
            secondary: const Icon(Icons.analytics_outlined),
            value: settings.hideAnalyticsValues,
            onChanged: (val) => controller.toggleHideAnalyticsValues(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: Text(context.translate('screenshot_protection')),
            subtitle: Text(context.translate('screenshot_protection_desc')),
            secondary: const Icon(Icons.screenshot_outlined),
            value: settings.screenshotProtectionEnabled,
            onChanged: (val) => controller.toggleScreenshotProtection(val),
          ),
        ],
      ),
    );
  }
}
