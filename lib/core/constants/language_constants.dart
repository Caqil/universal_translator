class LanguageConstants {
  // Auto-detect Language
  static const String autoDetectCode = 'auto';
  static const String autoDetectName = 'Auto-detect';
  static const String autoDetectNativeName = 'Auto-detect';

  // Supported Languages (LibreTranslate compatible)
  static const Map<String, Map<String, String>> supportedLanguages = {
    'af': {
      'code': 'af',
      'name': 'Afrikaans',
      'nativeName': 'Afrikaans',
      'flag': '🇿🇦',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'ar': {
      'code': 'ar',
      'name': 'Arabic',
      'nativeName': 'العربية',
      'flag': '🇸🇦',
      'rtl': 'true',
      'family': 'Semitic'
    },
    'az': {
      'code': 'az',
      'name': 'Azerbaijani',
      'nativeName': 'Azərbaycan dili',
      'flag': '🇦🇿',
      'rtl': 'false',
      'family': 'Turkic'
    },
    'be': {
      'code': 'be',
      'name': 'Belarusian',
      'nativeName': 'Беларуская мова',
      'flag': '🇧🇾',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'bg': {
      'code': 'bg',
      'name': 'Bulgarian',
      'nativeName': 'Български език',
      'flag': '🇧🇬',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'bn': {
      'code': 'bn',
      'name': 'Bengali',
      'nativeName': 'বাংলা',
      'flag': '🇧🇩',
      'rtl': 'false',
      'family': 'Indo-Aryan'
    },
    'ca': {
      'code': 'ca',
      'name': 'Catalan',
      'nativeName': 'Català',
      'flag': '🇪🇸',
      'rtl': 'false',
      'family': 'Romance'
    },
    'cs': {
      'code': 'cs',
      'name': 'Czech',
      'nativeName': 'Čeština',
      'flag': '🇨🇿',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'da': {
      'code': 'da',
      'name': 'Danish',
      'nativeName': 'Dansk',
      'flag': '🇩🇰',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'de': {
      'code': 'de',
      'name': 'German',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'el': {
      'code': 'el',
      'name': 'Greek',
      'nativeName': 'Ελληνικά',
      'flag': '🇬🇷',
      'rtl': 'false',
      'family': 'Hellenic'
    },
    'en': {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇺🇸',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'eo': {
      'code': 'eo',
      'name': 'Esperanto',
      'nativeName': 'Esperanto',
      'flag': '🌍',
      'rtl': 'false',
      'family': 'Constructed'
    },
    'es': {
      'code': 'es',
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
      'rtl': 'false',
      'family': 'Romance'
    },
    'et': {
      'code': 'et',
      'name': 'Estonian',
      'nativeName': 'Eesti keel',
      'flag': '🇪🇪',
      'rtl': 'false',
      'family': 'Finno-Ugric'
    },
    'fa': {
      'code': 'fa',
      'name': 'Persian',
      'nativeName': 'فارسی',
      'flag': '🇮🇷',
      'rtl': 'true',
      'family': 'Indo-Iranian'
    },
    'fi': {
      'code': 'fi',
      'name': 'Finnish',
      'nativeName': 'Suomi',
      'flag': '🇫🇮',
      'rtl': 'false',
      'family': 'Finno-Ugric'
    },
    'fr': {
      'code': 'fr',
      'name': 'French',
      'nativeName': 'Français',
      'flag': '🇫🇷',
      'rtl': 'false',
      'family': 'Romance'
    },
    'ga': {
      'code': 'ga',
      'name': 'Irish',
      'nativeName': 'Gaeilge',
      'flag': '🇮🇪',
      'rtl': 'false',
      'family': 'Celtic'
    },
    'he': {
      'code': 'he',
      'name': 'Hebrew',
      'nativeName': 'עברית',
      'flag': '🇮🇱',
      'rtl': 'true',
      'family': 'Semitic'
    },
    'hi': {
      'code': 'hi',
      'name': 'Hindi',
      'nativeName': 'हिन्दी',
      'flag': '🇮🇳',
      'rtl': 'false',
      'family': 'Indo-Aryan'
    },
    'hu': {
      'code': 'hu',
      'name': 'Hungarian',
      'nativeName': 'Magyar',
      'flag': '🇭🇺',
      'rtl': 'false',
      'family': 'Finno-Ugric'
    },
    'id': {
      'code': 'id',
      'name': 'Indonesian',
      'nativeName': 'Bahasa Indonesia',
      'flag': '🇮🇩',
      'rtl': 'false',
      'family': 'Austronesian'
    },
    'it': {
      'code': 'it',
      'name': 'Italian',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
      'rtl': 'false',
      'family': 'Romance'
    },
    'ja': {
      'code': 'ja',
      'name': 'Japanese',
      'nativeName': '日本語',
      'flag': '🇯🇵',
      'rtl': 'false',
      'family': 'Japonic'
    },
    'ko': {
      'code': 'ko',
      'name': 'Korean',
      'nativeName': '한국어',
      'flag': '🇰🇷',
      'rtl': 'false',
      'family': 'Koreanic'
    },
    'lt': {
      'code': 'lt',
      'name': 'Lithuanian',
      'nativeName': 'Lietuvių kalba',
      'flag': '🇱🇹',
      'rtl': 'false',
      'family': 'Baltic'
    },
    'lv': {
      'code': 'lv',
      'name': 'Latvian',
      'nativeName': 'Latviešu valoda',
      'flag': '🇱🇻',
      'rtl': 'false',
      'family': 'Baltic'
    },
    'ms': {
      'code': 'ms',
      'name': 'Malay',
      'nativeName': 'Bahasa Melayu',
      'flag': '🇲🇾',
      'rtl': 'false',
      'family': 'Austronesian'
    },
    'nl': {
      'code': 'nl',
      'name': 'Dutch',
      'nativeName': 'Nederlands',
      'flag': '🇳🇱',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'no': {
      'code': 'no',
      'name': 'Norwegian',
      'nativeName': 'Norsk',
      'flag': '🇳🇴',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'pl': {
      'code': 'pl',
      'name': 'Polish',
      'nativeName': 'Polski',
      'flag': '🇵🇱',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'pt': {
      'code': 'pt',
      'name': 'Portuguese',
      'nativeName': 'Português',
      'flag': '🇵🇹',
      'rtl': 'false',
      'family': 'Romance'
    },
    'ro': {
      'code': 'ro',
      'name': 'Romanian',
      'nativeName': 'Română',
      'flag': '🇷🇴',
      'rtl': 'false',
      'family': 'Romance'
    },
    'ru': {
      'code': 'ru',
      'name': 'Russian',
      'nativeName': 'Русский',
      'flag': '🇷🇺',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'sk': {
      'code': 'sk',
      'name': 'Slovak',
      'nativeName': 'Slovenčina',
      'flag': '🇸🇰',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'sl': {
      'code': 'sl',
      'name': 'Slovenian',
      'nativeName': 'Slovenščina',
      'flag': '🇸🇮',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'sq': {
      'code': 'sq',
      'name': 'Albanian',
      'nativeName': 'Shqip',
      'flag': '🇦🇱',
      'rtl': 'false',
      'family': 'Albanian'
    },
    'sv': {
      'code': 'sv',
      'name': 'Swedish',
      'nativeName': 'Svenska',
      'flag': '🇸🇪',
      'rtl': 'false',
      'family': 'Germanic'
    },
    'th': {
      'code': 'th',
      'name': 'Thai',
      'nativeName': 'ไทย',
      'flag': '🇹🇭',
      'rtl': 'false',
      'family': 'Tai-Kadai'
    },
    'tr': {
      'code': 'tr',
      'name': 'Turkish',
      'nativeName': 'Türkçe',
      'flag': '🇹🇷',
      'rtl': 'false',
      'family': 'Turkic'
    },
    'uk': {
      'code': 'uk',
      'name': 'Ukrainian',
      'nativeName': 'Українська',
      'flag': '🇺🇦',
      'rtl': 'false',
      'family': 'Slavic'
    },
    'ur': {
      'code': 'ur',
      'name': 'Urdu',
      'nativeName': 'اردو',
      'flag': '🇵🇰',
      'rtl': 'true',
      'family': 'Indo-Aryan'
    },
    'vi': {
      'code': 'vi',
      'name': 'Vietnamese',
      'nativeName': 'Tiếng Việt',
      'flag': '🇻🇳',
      'rtl': 'false',
      'family': 'Austroasiatic'
    },
    'zh': {
      'code': 'zh',
      'name': 'Chinese',
      'nativeName': '中文',
      'flag': '🇨🇳',
      'rtl': 'false',
      'family': 'Sino-Tibetan'
    },
  };

  // Popular Languages (for quick access)
  static const List<String> popularLanguageCodes = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'ja',
    'ko',
    'zh',
    'ar',
    'hi'
  ];

  // European Languages
  static const List<String> europeanLanguageCodes = [
    'en',
    'de',
    'fr',
    'es',
    'it',
    'pt',
    'nl',
    'pl',
    'ru',
    'sv',
    'da',
    'no'
  ];

  // Asian Languages
  static const List<String> asianLanguageCodes = [
    'zh',
    'ja',
    'ko',
    'hi',
    'th',
    'vi',
    'id',
    'ms',
    'bn'
  ];

  // Right-to-Left Languages
  static const List<String> rtlLanguageCodes = ['ar', 'he', 'fa', 'ur'];

  // Languages that support Speech-to-Text
  static const List<String> speechToTextSupportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'ja',
    'ko',
    'zh',
    'ar',
    'hi',
    'nl',
    'pl',
    'sv',
    'da',
    'no',
    'fi',
    'cs',
    'hu',
    'tr',
    'th',
    'vi'
  ];

  // Languages that support Text-to-Speech
  static const List<String> textToSpeechSupportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'ja',
    'ko',
    'zh',
    'ar',
    'hi',
    'nl',
    'pl',
    'sv',
    'da',
    'no',
    'fi',
    'cs',
    'hu',
    'tr',
    'th',
    'vi',
    'id'
  ];

  // Languages that support OCR
  static const List<String> ocrSupportedLanguages = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'ja',
    'ko',
    'zh',
    'ar',
    'hi',
    'nl',
    'pl',
    'sv',
    'da',
    'no',
    'fi',
    'cs',
    'hu',
    'tr'
  ];

  // Language families for grouping
  static const Map<String, List<String>> languageFamilies = {
    'Germanic': ['en', 'de', 'nl', 'sv', 'da', 'no', 'af'],
    'Romance': ['es', 'fr', 'it', 'pt', 'ro', 'ca'],
    'Slavic': ['ru', 'pl', 'cs', 'sk', 'sl', 'bg', 'uk', 'be'],
    'Sino-Tibetan': ['zh'],
    'Japonic': ['ja'],
    'Koreanic': ['ko'],
    'Semitic': ['ar', 'he'],
    'Indo-Aryan': ['hi', 'bn', 'ur'],
    'Finno-Ugric': ['fi', 'et', 'hu'],
    'Turkic': ['tr', 'az'],
    'Austronesian': ['id', 'ms'],
    'Other': ['th', 'vi', 'sq', 'ga', 'eo']
  };

  // Default language settings
  static const String defaultSourceLanguage = 'auto';
  static const String defaultTargetLanguage = 'en';

  // Language detection confidence thresholds
  static const double highConfidenceThreshold = 0.8;
  static const double mediumConfidenceThreshold = 0.5;
  static const double lowConfidenceThreshold = 0.2;

  // Helper methods to get language info
  static String getLanguageName(String code) {
    return supportedLanguages[code]?['name'] ?? 'Unknown';
  }

  static String getLanguageNativeName(String code) {
    return supportedLanguages[code]?['nativeName'] ?? 'Unknown';
  }

  static String getLanguageFlag(String code) {
    return supportedLanguages[code]?['flag'] ?? '🌍';
  }

  static bool isRtlLanguage(String code) {
    return supportedLanguages[code]?['rtl'] == 'true';
  }

  static String getLanguageFamily(String code) {
    return supportedLanguages[code]?['family'] ?? 'Other';
  }

  static bool supportsSpeechToText(String code) {
    return speechToTextSupportedLanguages.contains(code);
  }

  static bool supportsTextToSpeech(String code) {
    return textToSpeechSupportedLanguages.contains(code);
  }

  static bool supportsOcr(String code) {
    return ocrSupportedLanguages.contains(code);
  }

  static List<String> getLanguagesByFamily(String family) {
    return languageFamilies[family] ?? [];
  }

  static bool isLanguageSupported(String code) {
    return supportedLanguages.containsKey(code);
  }

  static List<String> getAllLanguageCodes() {
    return supportedLanguages.keys.toList();
  }

  static List<Map<String, String>> getAllLanguages() {
    return supportedLanguages.values.toList();
  }
}
