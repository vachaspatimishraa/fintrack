import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/settings_controller.dart';
import '../../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/services/biometric_service.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  final _biometricService = BiometricService();
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final available = await _biometricService.isBiometricAvailable();
    if (mounted) setState(() => _biometricAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('security')),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildAppLockSection(settings),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${context.translate('error')}: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildAppLockSection(SettingsEntity settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context.translate('app_lock').toUpperCase()),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1.5),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  context.translate('app_lock'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(context.translate('require_auth_desc')),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: settings.appLockEnabled 
                        ? Theme.of(context).colorScheme.primaryContainer 
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    settings.appLockEnabled ? Icons.lock : Icons.lock_open,
                    color: settings.appLockEnabled 
                        ? Theme.of(context).colorScheme.onPrimaryContainer 
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                value: settings.appLockEnabled,
                onChanged: (val) {
                  if (val) {
                    _enableAppLock();
                  } else {
                    _showDisableConfirmDialog();
                  }
                },
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: settings.appLockEnabled
                    ? Column(
                        children: [
                          const Divider(height: 1, indent: 64),
                          SwitchListTile(
                            title: Text(context.translate('biometric_unlock')),
                            subtitle: Text(_biometricAvailable
                                ? context.translate('biometric_desc')
                                : context.translate('not_available')),
                            secondary: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(
                                Icons.fingerprint,
                                color: settings.biometricEnabled 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            value: settings.biometricEnabled,
                            onChanged: _biometricAvailable
                                ? (val) => ref.read(settingsControllerProvider).toggleBiometricEnabled(val)
                                : null,
                          ),
                          const Divider(height: 1, indent: 64),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(64, 16, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      context.translate('lock_timeout'),
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildTimeoutChip('immediately', context.translate('require_auth_immediately'), settings.sessionTimeout),
                                    _buildTimeoutChip('1_min', context.translate('require_auth_1_min'), settings.sessionTimeout),
                                    _buildTimeoutChip('5_min', context.translate('require_auth_5_min'), settings.sessionTimeout),
                                    _buildTimeoutChip('15_min', context.translate('require_auth_15_min'), settings.sessionTimeout),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutChip(String value, String label, String current) {
    final isSelected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(settingsControllerProvider).updateSessionTimeout(value);
        }
      },
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Theme.of(context).colorScheme.onPrimary : null,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _enableAppLock() async {
    // Enable directly
    await ref.read(settingsControllerProvider).toggleAppLock(true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.translate('app_lock_enabled_success')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showDisableConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.translate('disable_app_lock_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(settingsControllerProvider).toggleAppLock(false);
            },
            child: Text(context.translate('disable')),
          ),
        ],
      ),
    );
  }
}
