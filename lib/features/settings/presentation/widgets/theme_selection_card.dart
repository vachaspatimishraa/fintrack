import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/settings_controller.dart';

class ThemeSelectionCard extends ConsumerWidget {
  final String currentMode;

  const ThemeSelectionCard({super.key, required this.currentMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          _ThemeTile(ref, context.translate('light'), 'light', Icons.light_mode, currentMode),
          _ThemeTile(ref, context.translate('dark'), 'dark', Icons.dark_mode, currentMode),
          _ThemeTile(ref, context.translate('system_default'), 'system', Icons.brightness_auto, currentMode),
          _ThemeTile(ref, context.translate('amoled'), 'amoled', Icons.brightness_2, currentMode),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final WidgetRef ref;
  final String title;
  final String mode;
  final IconData icon;
  final String currentMode;

  const _ThemeTile(this.ref, this.title, this.mode, this.icon, this.currentMode);

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title),
      secondary: Icon(icon),
      value: mode,
      groupValue: currentMode,
      onChanged: (val) => ref.read(settingsControllerProvider).updateThemeMode(val!),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
