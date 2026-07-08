import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

class AccessibilityPreview extends StatelessWidget {
  final SettingsEntity settings;

  const AccessibilityPreview({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: settings.highContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Accessibility Preview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Icon(Icons.accessibility_new),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This text demonstrates the current font scaling and contrast settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Notice the border width and icon contrast.'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              child: const Text('Sample Button'),
            ),
          ),
        ],
      ),
    );
  }
}
