import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/translations.dart';
import '../controllers/settings_controller.dart';

class DisplayDensitySelector extends ConsumerWidget {
  final String currentDensity;

  const DisplayDensitySelector({super.key, required this.currentDensity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            _DensityOption(ref, context.translate('compact'), 'compact', currentDensity),
            _DensityOption(ref, context.translate('comfortable'), 'comfortable', currentDensity),
            _DensityOption(ref, context.translate('expanded'), 'expanded', currentDensity),
          ],
        ),
      ),
    );
  }
}

class _DensityOption extends StatelessWidget {
  final WidgetRef ref;
  final String label;
  final String value;
  final String current;

  const _DensityOption(this.ref, this.label, this.value, this.current);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == current;
    final color = isSelected ? Theme.of(context).colorScheme.primary : null;

    return Expanded(
      child: InkWell(
        onTap: () => ref.read(settingsControllerProvider).updateDisplayDensity(value),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                height: 4,
                width: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
