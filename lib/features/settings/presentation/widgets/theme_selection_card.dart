import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/core/utils/translations.dart';
import 'package:fintrack/features/settings/presentation/controllers/settings_controller.dart';


class ThemeSelectionCard extends ConsumerWidget {
  final String currentMode;

  const ThemeSelectionCard({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          _ThemeTile(
            ref: ref,
            title: context.translate('system_default'),
            subtitle: context.translate('system_default_subtitle'),
            mode: 'system',
            icon: Icons.brightness_auto,
            currentMode: currentMode,
          ),
          const Divider(height: 1),
          _ThemeTile(
            ref: ref,
            title: context.translate('light'),
            subtitle: null,
            mode: 'light',
            icon: Icons.light_mode,
            currentMode: currentMode,
          ),
          const Divider(height: 1),
          _ThemeTile(
            ref: ref,
            title: context.translate('dark'),
            subtitle: null,
            mode: 'dark',
            icon: Icons.dark_mode,
            currentMode: currentMode,
          ),
          const Divider(height: 1),
          _ThemeTile(
            ref: ref,
            title: context.translate('amoled'),
            subtitle: context.translate('amoled_subtitle'),
            mode: 'amoled',
            icon: Icons.brightness_2,
            currentMode: currentMode,
          ),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final WidgetRef ref;
  final String title;
  final String? subtitle;
  final String mode;
  final IconData icon;
  final String currentMode;

  const _ThemeTile({
    required this.ref,
    required this.title,
    required this.subtitle,
    required this.mode,
    required this.icon,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = currentMode == mode;

    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      secondary: Icon(
        icon,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      value: mode,
      groupValue: currentMode,
      activeColor: theme.colorScheme.primary,
      onChanged: (val) => ref.read(settingsControllerProvider).updateThemeMode(val!),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}

