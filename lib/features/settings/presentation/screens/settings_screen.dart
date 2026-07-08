import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';
import '../../../../shared/widgets/offline_banner.dart';

import 'appearance_screen.dart';
import 'localization_screen.dart';
import 'notification_settings_screen.dart';
import 'security_settings_screen.dart';
import 'backup_settings_screen.dart';
import 'accessibility_screen.dart';
import 'about_screen.dart';
import 'developer_options_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('settings')),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 48,
                    width: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.translate('app_title'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            OfflineBanner(message: context.translate('settings_managed_locally')),
            const SizedBox(height: 16),
            _buildProfileCard(context, user),
            const SizedBox(height: 24),
            _buildSectionTitle(context, context.translate('appearance')),
            _buildAppearanceCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('currency_localization')),
            _buildLocalizationCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('notifications')),
            _buildNotificationCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('privacy_security')),
            _buildSecurityCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('backup_synchronization')),
            _buildBackupSyncCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('accessibility')),
            _buildAccessibilityCard(context, ref, settings),
            const SizedBox(height: 16),
            _buildSectionTitle(context, context.translate('about')),
            _buildAboutCard(context),
            const SizedBox(height: 16),
            if (settings.developerModeEnabled) ...[
              _buildSectionTitle(context, context.translate('developer')),
              _buildDeveloperCard(context),
              const SizedBox(height: 16),
            ],
            _buildLogoutButton(context, ref),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${context.translate('error')}: $err')),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: user?.email != null
                  ? Text(user!.email![0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer))
                  : const Icon(Icons.person, size: 36),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email != null ? context.translate('logged_in_user') : context.translate('guest_mode'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? context.translate('guest_mode_desc'),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildAppearanceCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(context.translate('theme_mode')),
            subtitle: Text(context.translate(settings.themeMode == 'system' ? 'system_default' : settings.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppearanceScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizationCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.translate('currency_localization')),
            subtitle: Text('${settings.currency} • ${settings.language == 'en' ? 'English' : 'Hindi'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocalizationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text(context.translate('notification_prefs')),
        subtitle: Text(settings.masterNotificationsEnabled ? context.translate('enabled') : context.translate('disabled')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.security_outlined),
        title: Text(context.translate('privacy_security')),
        subtitle: Text(settings.appLockEnabled ? context.translate('app_lock_active') : context.translate('protected')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildBackupSyncCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sync),
        title: Text(context.translate('backup_synchronization')),
        subtitle: Text(settings.syncEnabled ? context.translate('cloud_sync_active') : context.translate('manual_mode')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BackupSettingsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildAccessibilityCard(BuildContext context, WidgetRef ref, SettingsEntity settings) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.accessibility_new),
        title: Text(context.translate('accessibility')),
        subtitle: Text(context.translate('contrast_scaling_interaction')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccessibilityScreen()),
          );
        },
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(context.translate('about_fintrack')),
            subtitle: Text(context.translate('version_licenses_support')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bug_report_outlined),
        title: Text(context.translate('developer_options')),
        subtitle: Text(context.translate('diagnostics_debugging_flags')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DeveloperOptionsScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () => ref.read(authProvider.notifier).signOut(),
      icon: const Icon(Icons.logout),
      label: Text(context.translate('logout')),
    );
  }
}
