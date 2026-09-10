import 'package:flutter/foundation.dart';

@immutable
class Language {
  const Language({required this.code, required this.label});

  /// BCP-47 tag passed to the speech engines.
  final String code;
  final String label;
}

/// Languages supported by the Google Translate voice, in menu order.
const kLanguages = <Language>[
  Language(code: 'pt-BR', label: 'Portuguese (Brazil)'),
  Language(code: 'pt-PT', label: 'Portuguese (Portugal)'),
  Language(code: 'en-US', label: 'English (United States)'),
  Language(code: 'en-GB', label: 'English (United Kingdom)'),
  Language(code: 'es', label: 'Spanish (Spain)'),
  Language(code: 'fr', label: 'French (France)'),
  Language(code: 'de', label: 'German (Germany)'),
  Language(code: 'it', label: 'Italian (Italy)'),
  Language(code: 'nl', label: 'Dutch (Netherlands)'),
  Language(code: 'pl', label: 'Polish (Poland)'),
  Language(code: 'ru', label: 'Russian (Russia)'),
  Language(code: 'tr', label: 'Turkish (Turkey)'),
  Language(code: 'ja', label: 'Japanese (Japan)'),
  Language(code: 'ko', label: 'Korean (Korea)'),
  Language(code: 'zh-CN', label: 'Chinese (Mandarin)'),
];

const kDefaultLanguage = 'pt-BR';

Language languageForCode(String code) => kLanguages.firstWhere(
  (language) => language.code == code,
  orElse: () => kLanguages.first,
);
