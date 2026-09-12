import 'package:flutter/material.dart';
import 'package:fintrack/features/settings/domain/entities/settings_entity.dart';
import 'package:fintrack/features/settings/domain/entities/language_entity.dart';

class LocalizationService {
  static Locale getLocale(SettingsEntity settings) {
    final language = LanguageEntity.supportedLanguages.firstWhere(
      (l) => l.code == settings.language,
      orElse: () => LanguageEntity.supportedLanguages.first,
    );
    return Locale(language.code);
  }

  static List<Locale> getSupportedLocales() {
    return LanguageEntity.supportedLanguages
        .map((l) => Locale(l.code))
        .toList();
  }
}
