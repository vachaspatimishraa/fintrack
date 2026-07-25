import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../../../../core/utils/formatter.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../sync/providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';
import '../../../../shared/widgets/offline_banner.dart';

import 'appearance_screen.dart';
import 'localization_screen.dart';
import 'security_settings_screen.dart';
import 'backup_settings_screen.dart';
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
      body: SafeArea(
        child: settingsAsync.when(
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
              _buildProfileCard(context, ref, user, authState.status),
              const SizedBox(height: 24),
              _buildSectionTitle(context, context.translate('appearance')),
              _buildAppearanceCard(context, ref, settings),
              const SizedBox(height: 16),
              _buildSectionTitle(context, context.translate('currency_localization')),
              _buildLocalizationCard(context, ref, settings),
              const SizedBox(height: 16),
              _buildSectionTitle(context, context.translate('privacy_security')),
              _buildSecurityCard(context, ref, settings),
              const SizedBox(height: 16),
              _buildSectionTitle(context, context.translate('backup_synchronization')),
              _buildBackupSyncCard(context, ref, settings),
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
          loading: () => const Center(child: CircularProgressIndicator.adaptive()),
          error: (err, _) => Center(child: Text('${context.translate('error')}: $err')),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref, dynamic user, AuthStatus status) {
    final theme = Theme.of(context);
    final isGuest = status == AuthStatus.guest || status == AuthStatus.unauthenticated || status == AuthStatus.error;

    if (isGuest) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.person_outline, size: 36, color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Guest User',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your data is stored locally.',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => ref.read(authControllerProvider).loginWithGoogle(),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final email = user?.email ?? '';
      final name = user?.userMetadata?['display_name'] ?? user?.userMetadata?['full_name'] ?? user?.userMetadata?['name'] ?? 'User';
      final avatarUrl = user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];

      final syncState = ref.watch(syncStatusProvider);
      final isConnected = ref.watch(connectivityStreamProvider).value ?? true;

      String syncStatusText = 'Synced';
      Color syncColor = Colors.green;
      if (!isConnected) {
        syncStatusText = 'Offline';
        syncColor = Colors.red;
      } else if (syncState.isSyncing) {
        syncStatusText = 'Syncing...';
        syncColor = Colors.amber;
      }

      final lastSyncStr = syncState.lastSyncTime != null 
          ? AppFormatter.formatFriendlyDateTime(syncState.lastSyncTime!) 
          : 'Never';

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 36)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: syncColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$syncStatusText • Cloud Sync Enabled',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Last Sync: $lastSyncStr',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
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
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: () => _showLogoutConfirmation(context, ref),
      icon: const Icon(Icons.logout),
      label: Text(context.translate('logout')),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final isGuest = authState.status == AuthStatus.guest || authState.status == AuthStatus.unauthenticated || authState.status == AuthStatus.error;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isGuest ? 'Exit Guest Mode?' : 'Logout?'),
          content: Text(
            isGuest
                ? 'Your local data will remain on this device.'
                : 'Your local data will remain on this device. Cloud synchronization will stop.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.pop(context); // Close settings screen
                }
              },
              child: Text(isGuest ? 'Exit' : 'Logout'),
            ),
          ],
        );
      },
    );
  }
}
