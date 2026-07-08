import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/about_provider.dart';
import '../../../../core/utils/translations.dart';
import 'release_notes_screen.dart';
import 'legal_document_screen.dart';
import '../controllers/developer_controller.dart';
import '../../providers/settings_provider.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  int _tapCount = 0;

  void _handleTap() {
    final settingsAsync = ref.read(settingsProvider);
    settingsAsync.whenData((settings) {
      if (settings.developerModeEnabled) return;

      setState(() => _tapCount++);
      if (_tapCount >= 7) {
        ref.read(developerControllerProvider).enableDevMode();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Developer Mode Enabled!')),
        );
        setState(() => _tapCount = 0);
      } else if (_tapCount > 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You are ${7 - _tapCount} steps away from being a developer.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appInfoAsync = ref.watch(appInformationProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('about_fintrack')),
      ),
      body: appInfoAsync.when(
        data: (info) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                info.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Center(
              child: Text(
                context.translate('personal_finance_manager'),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _handleTap,
              child: _buildVersionCard(context, info),
            ),
            const SizedBox(height: 16),
            _buildDeveloperCard(context),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open Source Licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationName: info.appName,
                applicationVersion: info.version,
                applicationIcon: Image.asset('assets/images/logo.png', height: 48, width: 48),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                final content = await ref.read(privacyPolicyProvider.future);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LegalDocumentScreen(title: 'Privacy Policy', content: content),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () async {
                final content = await ref.read(termsOfServiceProvider.future);
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LegalDocumentScreen(title: 'Terms of Service', content: content),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Release Notes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReleaseNotesScreen()),
                );
              },
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                '© 2026 FinTrack Inc.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildVersionCard(BuildContext context, dynamic info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(context.translate('version'), info.version),
            const Divider(height: 24),
            _buildInfoRow('Build', info.buildNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Developed by'),
            subtitle: Text('FinTrack Developer Team'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website'),
            subtitle: const Text('www.fintrack.app'),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Support'),
            subtitle: const Text('support@fintrack.app'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
