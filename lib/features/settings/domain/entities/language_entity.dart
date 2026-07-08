class LanguageEntity {
  final String code; // en, hi
  final String name;
  final String nativeName;
  final String locale;
  final bool isRTL;

  const LanguageEntity({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.locale,
    this.isRTL = false,
  });

  static const List<LanguageEntity> supportedLanguages = [
    LanguageEntity(code: 'en', name: 'English', nativeName: 'English', locale: 'en_US'),
    LanguageEntity(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', locale: 'hi_IN'),
  ];
}
