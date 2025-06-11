// lib/features/translation/data/datasources/translation_remote_datasource.dart
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/utils/language_data_converter.dart';
import '../models/translation_model.dart';
import '../models/language_model.dart';

/// Abstract interface for translation remote data source
abstract class TranslationRemoteDataSource {
  /// Translate text from source to target language
  Future<TranslationModel> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  /// Detect language of given text
  Future<String> detectLanguage(String text);

  /// Get supported languages
  Future<List<LanguageModel>> getSupportedLanguages();

  /// Get translation alternatives
  Future<List<String>> getTranslationAlternatives({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    int alternatives = 3,
  });
}

@LazySingleton(as: TranslationRemoteDataSource)
class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final DioClient _dioClient;

  TranslationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<TranslationModel> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      // Validate input
      if (text.trim().isEmpty) {
        throw const TranslationException(
          message: 'Text cannot be empty',
          code: 'EMPTY_TEXT',
        );
      }

      if (text.length > ApiConstants.maxTextLengthForTranslation) {
        throw TranslationException.textTooLong(
            ApiConstants.maxTextLengthForTranslation);
      }

      if (sourceLanguage == targetLanguage && sourceLanguage != 'auto') {
        throw TranslationException.sameLanguage();
      }

      // Prepare request data matching LibreTranslate API spec
      final requestData = {
        ApiConstants.paramQ: text.trim(),
        ApiConstants.paramSource: sourceLanguage,
        ApiConstants.paramTarget: targetLanguage,
        ApiConstants.paramFormat: ApiConstants.defaultFormat,
        ApiConstants.paramAlternatives: ApiConstants.defaultAlternatives,
        // API key will be added automatically by DioClient.post()
      };

      // Make API request
      final response = await _dioClient.post(
        ApiConstants.translateEndpoint,
        data: requestData,
      );

      // Parse response according to LibreTranslate spec
      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('translatedText')) {
        throw const ServerException(
          message: 'Invalid response format - missing translatedText',
          code: 'INVALID_RESPONSE',
        );
      }

      final translatedText = responseData['translatedText'] as String;

      // Handle detectedLanguage object structure safely
      String? detectedLanguageCode;
      if (responseData.containsKey('detectedLanguage')) {
        final detectedLang = responseData['detectedLanguage'];
        if (detectedLang is Map<String, dynamic>) {
          // New format: {"confidence": 30, "language": "es"}
          detectedLanguageCode = detectedLang['language'] as String?;
        } else if (detectedLang is String) {
          // Fallback for older format
          detectedLanguageCode = detectedLang;
        }
      }

      // Use detected language if source was auto
      final effectiveSourceLanguage = sourceLanguage == 'auto'
          ? (detectedLanguageCode ?? sourceLanguage)
          : sourceLanguage;

      // Create translation model
      return TranslationModel(
        id: AppUtils.generateTranslationId(),
        sourceText: text.trim(),
        translatedText: translatedText,
        sourceLanguage: effectiveSourceLanguage,
        targetLanguage: targetLanguage,
        timestamp: DateTime.now(),
        // Store alternatives if available
        alternatives: _extractAlternatives(responseData),
      );
    } catch (e) {
      if (e is TranslationException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }

      throw ServerException(
        message: 'Translation failed: ${e.toString()}',
        code: 'TRANSLATION_FAILED',
      );
    }
  }

  @override
  Future<String> detectLanguage(String text) async {
    try {
      if (text.trim().isEmpty) {
        throw const TranslationException(
          message: 'Text cannot be empty for language detection',
          code: 'EMPTY_TEXT',
        );
      }

      final requestData = {
        ApiConstants.paramQ: text.trim(),
        // API key will be added automatically by DioClient.post()
      };

      final response = await _dioClient.post(
        ApiConstants.detectEndpoint,
        data: requestData,
      );

      final responseData = response.data as List<dynamic>;

      if (responseData.isEmpty) {
        throw const ServerException(
          message: 'No language detected',
          code: 'NO_LANGUAGE_DETECTED',
        );
      }

      // LibreTranslate detect returns array of results
      final firstResult = responseData.first as Map<String, dynamic>;
      final detectedLanguage = firstResult['language'] as String;
      final confidence = firstResult['confidence'] as double?;

      // Validate confidence if available
      if (confidence != null && confidence < 0.1) {
        throw const TranslationException(
          message: 'Language detection confidence too low',
          code: 'LOW_CONFIDENCE',
        );
      }

      return detectedLanguage;
    } catch (e) {
      if (e is TranslationException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }

      throw ServerException(
        message: 'Language detection failed: ${e.toString()}',
        code: 'DETECTION_FAILED',
      );
    }
  }

  @override
  Future<List<LanguageModel>> getSupportedLanguages() async {
    try {
      final response = await _dioClient.get(ApiConstants.languagesEndpoint);

      final responseData = response.data;
      final languages = <LanguageModel>[];

      // Handle different response formats
      if (responseData is List<dynamic>) {
        // Standard LibreTranslate format
        for (final langData in responseData) {
          try {
            if (langData is Map<String, dynamic>) {
              final code = langData['code'] as String?;
              final name = langData['name'] as String?;

              if (code != null && name != null) {
                // Create language model with proper field mapping
                languages.add(LanguageModel(
                  code: code,
                  name: name,
                  nativeName:
                      name, // LibreTranslate doesn't provide native names
                  flag: _getLanguageFlag(code),
                  isRtl: _isRightToLeft(code),
                  family: 'Unknown',
                  supportsSTT: false,
                  supportsTTS: false,
                  supportsOCR: false,
                ));
              }
            }
          } catch (e) {
            // Skip invalid language entries and continue
            print('Warning: Skipped invalid language entry: $e');
            continue;
          }
        }
      } else if (responseData is String) {
        // If response is a JSON string (like your paste.txt format)
        try {
          languages.addAll(
              LanguageDataConverter.convertJsonToLanguageModels(responseData));
        } catch (e) {
          throw ServerException(
            message: 'Failed to parse language data: ${e.toString()}',
            code: 'INVALID_LANGUAGE_FORMAT',
          );
        }
      } else {
        throw const ServerException(
          message: 'Unexpected response format for languages endpoint',
          code: 'INVALID_RESPONSE_FORMAT',
        );
      }

      // Ensure we have at least some languages
      if (languages.isEmpty) {
        throw const ServerException(
          message: 'No valid languages found in response',
          code: 'NO_LANGUAGES_FOUND',
        );
      }

      // Sort languages alphabetically
      languages.sort((a, b) => a.name.compareTo(b.name));

      return languages;
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }

      throw ServerException(
        message: 'Failed to get supported languages: ${e.toString()}',
        code: 'LANGUAGES_FAILED',
      );
    }
  }

  @override
  Future<List<String>> getTranslationAlternatives({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    int alternatives = 3,
  }) async {
    // LibreTranslate returns alternatives in the main translate call
    final translation = await translateText(
      text: text,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );

    return translation.alternatives ?? [translation.translatedText];
  }

  // Helper methods

  List<String>? _extractAlternatives(Map<String, dynamic> responseData) {
    if (!responseData.containsKey('alternatives')) {
      return null;
    }

    final alternatives = responseData['alternatives'] as List<dynamic>?;
    if (alternatives == null || alternatives.isEmpty) {
      return null;
    }

    return alternatives
        .where((alt) => alt is String && alt.isNotEmpty)
        .cast<String>()
        .toList();
  }

  String _getLanguageFlag(String code) {
    // Simple mapping for common language codes
    const flags = {
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
      'hr': '🇭🇷',
      'sk': '🇸🇰',
      'sl': '🇸🇮',
      'et': '🇪🇪',
      'lv': '🇱🇻',
      'lt': '🇱🇹',
      'mt': '🇲🇹',
      'id': '🇮🇩',
      'ms': '🇲🇾',
      'th': '🇹🇭',
      'vi': '🇻🇳',
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

    return flags[code] ?? '🌍';
  }

  bool _isRightToLeft(String code) {
    const rtlLanguages = {'ar', 'he', 'fa', 'ur', 'yi'};
    return rtlLanguages.contains(code);
  }
}
