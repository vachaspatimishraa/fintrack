import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/settings_controller.dart';
import '../../providers/settings_provider.dart';
import '../widgets/theme_selection_card.dart';
import '../widgets/display_density_selector.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('appearance')),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle(context, context.translate('theme')),
            ThemeSelectionCard(currentMode: settings.themeMode),
            const SizedBox(height: 24),
            _buildSectionTitle(context, context.translate('display_density')),
            DisplayDensitySelector(currentDensity: settings.displayDensity),
            const SizedBox(height: 24),
            _buildSectionTitle(context, context.translate('text_scaling')),
            _buildFontSettings(context, ref, settings.fontScale),
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
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildFontSettings(BuildContext context, WidgetRef ref, String fontScale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.translate('small'), style: const TextStyle(fontSize: 12)),
                Text(context.translate('default'), style: const TextStyle(fontSize: 14)),
                Text(context.translate('large'), style: const TextStyle(fontSize: 18)),
              ],
            ),
            Slider(
              value: _getFontSliderValue(fontScale),
              min: 0,
              max: 3,
              divisions: 3,
              onChanged: (val) {
                final scale = _getFontScaleFromSlider(val);
                ref.read(settingsControllerProvider).updateFontScale(scale);
              },
            ),
          ],
        ),
      ),
    );
  }

  double _getFontSliderValue(String scale) {
    switch (scale) {
      case 'small': return 0;
      case 'large': return 2;
      case 'extra_large': return 3;
      default: return 1;
    }
  }

  String _getFontScaleFromSlider(double val) {
    if (val == 0) return 'small';
    if (val == 2) return 'large';
    if (val == 3) return 'extra_large';
    return 'default';
  }
}
