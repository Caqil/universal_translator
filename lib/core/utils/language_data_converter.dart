// lib/core/utils/language_data_converter.dart
import 'dart:convert';

import '../constants/language_constants.dart';
import '../../features/translation/data/models/language_model.dart';

class LanguageDataConverter {
  /// Convert the new JSON format to LanguageModel format
  static List<LanguageModel> convertJsonToLanguageModels(String jsonString) {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final List<LanguageModel> languages = [];

      for (final langData in jsonData) {
        if (langData is Map<String, dynamic>) {
          final languageModel = _convertSingleLanguage(langData);
          if (languageModel != null) {
            languages.add(languageModel);
          }
        }
      }

      // Sort alphabetically by name
      languages.sort((a, b) => a.name.compareTo(b.name));

      return languages;
    } catch (e) {
      print('Error converting language data: $e');
      return [];
    }
  }

  /// Convert a single language entry from new format to LanguageModel
  static LanguageModel? _convertSingleLanguage(Map<String, dynamic> langData) {
    try {
      final String code = langData['code'] as String;
      final String name = langData['name'] as String;

      // Get additional data from constants if available
      final constantsData = LanguageConstants.supportedLanguages[code];

      return LanguageModel(
        code: code,
        name: name,
        nativeName: constantsData?['nativeName'] ?? name,
        flag: constantsData?['flag'] ?? _getDefaultFlag(code),
        isRtl: constantsData?['rtl'] == 'true',
        family: constantsData?['family'] ?? 'Unknown',
        supportsSTT: _supportsSpeechToText(code),
        supportsTTS: _supportsTextToSpeech(code),
        supportsOCR: _supportsOCR(code),
      );
    } catch (e) {
      print('Error converting single language: $e');
      return null;
    }
  }

  /// Get default flag for a language code
  static String _getDefaultFlag(String code) {
    const defaultFlags = {
      'en': '🇺🇸',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'pt-BR': '🇧🇷',
      'ru': '🇷🇺',
      'ja': '🇯🇵',
      'ko': '🇰🇷',
      'zh': '🇨🇳',
      'zh-Hans': '🇨🇳',
      'zh-Hant': '🇹🇼',
      'ar': '🇸🇦',
      'hi': '🇮🇳',
      'tr': '🇹🇷',
      'pl': '🇵🇱',
      'nl': '🇳🇱',
      'sv': '🇸🇪',
      'da': '🇩🇰',
      'no': '🇳🇴',
      'nb': '🇳🇴',
      'fi': '🇫🇮',
      'cs': '🇨🇿',
      'hu': '🇭🇺',
      'ro': '🇷🇴',
      'bg': '🇧🇬',
      'sk': '🇸🇰',
      'sl': '🇸🇮',
      'et': '🇪🇪',
      'lv': '🇱🇻',
      'lt': '🇱🇹',
      'id': '🇮🇩',
      'ms': '🇲🇾',
      'th': '🇹🇭',
      'uk': '🇺🇦',
      'ur': '🇵🇰',
      'fa': '🇮🇷',
      'he': '🇮🇱',
      'ga': '🇮🇪',
      'gl': '🇪🇸',
      'ca': '🇪🇸',
      'eu': '🇪🇸',
      'sq': '🇦🇱',
      'az': '🇦🇿',
      'bn': '🇧🇩',
      'eo': '🌍',
      'el': '🇬🇷',
      'tl': '🇵🇭',
    };

    return defaultFlags[code] ?? '🌍';
  }

  /// Check if language supports speech-to-text
  static bool _supportsSpeechToText(String code) {
    const supportedSTT = {
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
      'tr',
      'nl',
      'sv',
      'da',
      'no',
      'fi',
      'pl'
    };
    return supportedSTT.contains(code);
  }

  /// Check if language supports text-to-speech
  static bool _supportsTextToSpeech(String code) {
    const supportedTTS = {
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
      'tr',
      'nl',
      'sv',
      'da',
      'no',
      'fi',
      'pl',
      'cs'
    };
    return supportedTTS.contains(code);
  }

  /// Check if language supports OCR
  static bool _supportsOCR(String code) {
    const supportedOCR = {
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
      'tr',
      'nl',
      'sv',
      'da',
      'no',
      'fi',
      'pl'
    };
    return supportedOCR.contains(code);
  }

  /// Extract target languages from the JSON data for a specific language
  static List<String> getTargetLanguages(
      String jsonString, String sourceLanguageCode) {
    try {
      final List<dynamic> jsonData = jsonDecode(jsonString);

      for (final langData in jsonData) {
        if (langData is Map<String, dynamic>) {
          final String code = langData['code'] as String;
          if (code == sourceLanguageCode) {
            final targets = langData['targets'] as List<dynamic>?;
            return targets?.cast<String>() ?? [];
          }
        }
      }

      return [];
    } catch (e) {
      print('Error extracting target languages: $e');
      return [];
    }
  }
}
