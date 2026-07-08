import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/settings_controller.dart';
import '../../providers/settings_provider.dart';

class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibility'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, 'Visual'),
            _buildVisualSettings(context, ref, settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Interaction'),
            _buildInteractionSettings(context, ref, settings),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'System'),
            _buildSystemSettings(context, ref, settings),
            const SizedBox(height: 48),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
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

  Widget _buildVisualSettings(BuildContext context, WidgetRef ref, dynamic settings) {
    final controller = ref.read(settingsControllerProvider);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('High Contrast'),
            subtitle: const Text('Increase visibility of borders and text'),
            secondary: const Icon(Icons.contrast),
            value: settings.highContrast,
            onChanged: (val) => controller.toggleHighContrast(val),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Text Scaling'),
            subtitle: Text(settings.fontScale.toUpperCase()),
            leading: const Icon(Icons.text_fields),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showFontScalePicker(context, ref, settings.fontScale),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Reduce Motion'),
            subtitle: const Text('Minimize non-essential animations'),
            secondary: const Icon(Icons.motion_photos_off_outlined),
            value: settings.reduceMotion,
            onChanged: (val) => controller.toggleReduceMotion(val),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionSettings(BuildContext context, WidgetRef ref, dynamic settings) {
    final controller = ref.read(settingsControllerProvider);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('Vibrate device on interactions'),
            secondary: const Icon(Icons.vibration),
            value: settings.hapticFeedbackEnabled,
            onChanged: (val) => controller.toggleHapticFeedback(val),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Touch Target Size'),
            subtitle: Text(settings.touchTargetSize.toUpperCase()),
            leading: const Icon(Icons.touch_app_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showTouchTargetPicker(context, ref, settings.touchTargetSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettings(BuildContext context, WidgetRef ref, dynamic settings) {
    final controller = ref.read(settingsControllerProvider);
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Screen Reader Hints'),
            subtitle: const Text('Provide additional context for TalkBack/VoiceOver'),
            secondary: const Icon(Icons.record_voice_over_outlined),
            value: settings.screenReaderHints,
            onChanged: (val) => controller.toggleScreenReaderHints(val),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('Keyboard Navigation'),
            subtitle: const Text('Optimize interface for external keyboards'),
            secondary: const Icon(Icons.keyboard_outlined),
            value: settings.keyboardNavigationEnabled,
            onChanged: (val) => controller.toggleKeyboardNavigation(val),
          ),
        ],
      ),
    );
  }

  void _showFontScalePicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPickerOption(ref, 'small', 'Small', current, (v) => ref.read(settingsControllerProvider).updateFontScale(v)),
            _buildPickerOption(ref, 'default', 'Default', current, (v) => ref.read(settingsControllerProvider).updateFontScale(v)),
            _buildPickerOption(ref, 'large', 'Large', current, (v) => ref.read(settingsControllerProvider).updateFontScale(v)),
            _buildPickerOption(ref, 'extra_large', 'Extra Large', current, (v) => ref.read(settingsControllerProvider).updateFontScale(v)),
          ],
        ),
      ),
    );
  }

  void _showTouchTargetPicker(BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPickerOption(ref, 'normal', 'Normal (48dp)', current, (v) => ref.read(settingsControllerProvider).updateTouchTargetSize(v)),
            _buildPickerOption(ref, 'large', 'Large (64dp)', current, (v) => ref.read(settingsControllerProvider).updateTouchTargetSize(v)),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(WidgetRef ref, String value, String label, String current, Function(String) onSelect) {
    return ListTile(
      title: Text(label),
      trailing: value == current ? const Icon(Icons.check, color: Colors.green) : null,
      onTap: () {
        onSelect(value);
        Navigator.pop(ref.context);
      },
    );
  }
}
