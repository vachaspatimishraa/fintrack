import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../domain/entities/settings_entity.dart';

class AppearanceSettingsTile extends ConsumerWidget {
  final SettingsEntity settings;

  const AppearanceSettingsTile({super.key, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Dynamic Colors'),
            subtitle: const Text('Use wallpaper-based colors (Android 12+)'),
            secondary: const Icon(Icons.color_lens_outlined),
            value: settings.dynamicColor,
            onChanged: (val) => ref.read(settingsControllerProvider).updateDynamicColor(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Animations'),
            subtitle: const Text('Enable smooth interface transitions'),
            secondary: const Icon(Icons.animation),
            value: settings.animationEnabled,
            onChanged: (val) => ref.read(settingsControllerProvider).updateAnimationEnabled(val),
          ),
        ],
      ),
    );
  }
}
