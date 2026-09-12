import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/settings/domain/entities/language_entity.dart';
import 'package:fintrack/features/settings/presentation/controllers/settings_controller.dart';
import 'package:fintrack/features/settings/providers/settings_provider.dart';
import 'package:fintrack/core/utils/translations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currentLanguage = settingsAsync.maybeWhen(
      data: (s) => s.language,
      orElse: () => 'en',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate('select_language')),
      ),
      body: ListView.builder(
        itemCount: LanguageEntity.supportedLanguages.length,
        itemBuilder: (context, index) {
          final language = LanguageEntity.supportedLanguages[index];
          final isSelected = language.code == currentLanguage;

          return ListTile(
            title: Text(language.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(language.nativeName),
            trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
            onTap: () {
              ref.read(settingsControllerProvider).updateLanguage(language.code);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
