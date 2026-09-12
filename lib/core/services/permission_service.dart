import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing and requesting device permissions
/// (Notifications, Camera, Photos/Storage, Location) on app installation.
class AppPermissionService {
  static const String _permissionsPromptedKey = 'initial_permissions_prompted';
  static bool? _cachedPrompted;

  /// Checks whether the initial permissions sheet has already been presented.
  static Future<bool> shouldPromptInitialPermissions() async {
    if (_cachedPrompted != null) return !_cachedPrompted!;
    final prefs = await SharedPreferences.getInstance();
    _cachedPrompted = prefs.getBool(_permissionsPromptedKey) ?? false;
    return !_cachedPrompted!;
  }

  /// Marks initial permissions as prompted in SharedPreferences.
  static Future<void> markInitialPermissionsPrompted() async {
    _cachedPrompted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsPromptedKey, true);
  }

  /// Prompts the user with an introductory permissions modal and requests
  /// system permissions if they have not been asked before.
  static Future<void> promptInitialPermissions(BuildContext context) async {
    final shouldPrompt = await shouldPromptInitialPermissions();
    if (!shouldPrompt || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.security,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions Required',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'FinTrack needs a few permissions for key features:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _PermissionItem(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifications',
                  description:
                      'Daily reminders, budget limit warnings, and bill alerts.',
                ),
                const SizedBox(height: 12),
                const _PermissionItem(
                  icon: Icons.photo_library_outlined,
                  title: 'Storage & Photos',
                  description:
                      'Attaching receipts to transactions and exporting reports.',
                ),
                const SizedBox(height: 12),
                const _PermissionItem(
                  icon: Icons.camera_alt_outlined,
                  title: 'Camera',
                  description:
                      'Capturing receipt images directly within the app.',
                ),
                const SizedBox(height: 12),
                const _PermissionItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  description:
                      'Tagging expense venues and transactions automatically.',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await markInitialPermissionsPrompted();
                    await _requestCorePermissions();
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue & Allow',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    Navigator.of(sheetContext).pop();
                    await markInitialPermissionsPrompted();
                  },
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Requests the core runtime permissions from the operating system.
  static Future<void> _requestCorePermissions() async {
    try {
      // 1. Notifications
      await Permission.notification.request();

      // 2. Camera & Media/Storage
      await Permission.camera.request();
      await Permission.photos.request();
      await Permission.storage.request();

      // 3. Location
      await Permission.locationWhenInUse.request();
    } catch (_) {
      // Gracefully handle environments (e.g. desktop/test) where native channels differ
    }
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
