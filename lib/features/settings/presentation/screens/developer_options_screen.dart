import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/developer_provider.dart';
import '../../providers/settings_provider.dart';
import '../controllers/developer_controller.dart';

import 'log_viewer_screen.dart';

class DeveloperOptionsScreen extends ConsumerWidget {
  const DeveloperOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appDiagnosticsProvider);
    final dbInfo = ref.watch(dbDiagnosticsProvider);
    final repoInfo = ref.watch(repoDiagnosticsProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Options'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoSection(context, 'Application Information', appInfo),
          const SizedBox(height: 16),
          _buildInfoSection(context, 'Database Inspector', dbInfo),
          const SizedBox(height: 16),
          _buildInfoSection(context, 'Repository Diagnostics', repoInfo),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Feature Flags'),
          settingsAsync.maybeWhen(
            data: (settings) => _buildFeatureFlags(ref, settings.featureFlags),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Maintenance Tools'),
          _buildMaintenanceTools(context, ref),
          const SizedBox(height: 48),
        ],
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

  Widget _buildInfoSection(BuildContext context, String title, AsyncValue<Map<String, dynamic>> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, title),
        Card(
          child: info.when(
            data: (data) => Column(
              children: data.entries.map((e) => ListTile(
                title: Text(e.key),
                trailing: Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => ListTile(title: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureFlags(WidgetRef ref, Map<String, bool> flags) {
    final controller = ref.read(developerControllerProvider);
    final defaultFlags = {
      'New Dashboard UI': false,
      'Beta Analytics': false,
      'AI Predictions': false,
    };

    return Card(
      child: Column(
        children: defaultFlags.keys.map((flag) {
          final isEnabled = flags[flag] ?? false;
          return SwitchListTile(
            title: Text(flag),
            value: isEnabled,
            onChanged: (val) => controller.toggleFlag(flag, val),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaintenanceTools(BuildContext context, WidgetRef ref) {
    final controller = ref.read(developerControllerProvider);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear Application Cache'),
            onTap: () => controller.clearCache(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.sync_disabled),
            title: const Text('Reset Sync Queue'),
            onTap: () => controller.resetSyncQueue(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Rebuild Analytics Cache'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('View Application Logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogViewerScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
