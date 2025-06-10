import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/language_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_utils.dart';
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

/// Implementation of translation remote data source using LibreTranslate API
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

      // Prepare request data
      final requestData = {
        ApiConstants.paramQ: text.trim(),
        ApiConstants.paramSource: sourceLanguage,
        ApiConstants.paramTarget: targetLanguage,
        ApiConstants.paramFormat: ApiConstants.defaultFormat,
      };

      // Make API request
      final response = await _dioClient.post(
        ApiConstants.translateEndpoint,
        data: requestData,
      );

      // Parse response
      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('translatedText')) {
        throw const ServerException(
          message: 'Invalid response format',
          code: 'INVALID_RESPONSE',
        );
      }

      final translatedText = responseData['translatedText'] as String;
      final detectedLanguage = responseData['detectedLanguage'] as String?;

      // Use detected language if source was auto
      final effectiveSourceLanguage = sourceLanguage == 'auto'
          ? (detectedLanguage ?? sourceLanguage)
          : sourceLanguage;

      // Create translation model
      return TranslationModel(
        id: AppUtils.generateTranslationId(),
        sourceText: text.trim(),
        translatedText: translatedText,
        sourceLanguage: effectiveSourceLanguage,
        targetLanguage: targetLanguage,
        timestamp: DateTime.now(),
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
      };

      final response = await _dioClient.post(
        ApiConstants.detectEndpoint,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;

      if (!responseData.containsKey('language')) {
        throw const ServerException(
          message: 'Invalid response format for language detection',
          code: 'INVALID_RESPONSE',
        );
      }

      final detectedLanguage = responseData['language'] as String;
      final confidence = responseData['confidence'] as double?;

      // Validate detected language
      if (!LanguageConstants.isLanguageSupported(detectedLanguage)) {
        throw TranslationException.languageNotSupported(detectedLanguage);
      }

      // Check confidence threshold
      if (confidence != null &&
          confidence < LanguageConstants.lowConfidenceThreshold) {
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

      final responseData = response.data as List<dynamic>;

      final languages = <LanguageModel>[];

      for (final langData in responseData) {
        try {
          final langMap = langData as Map<String, dynamic>;
          final code = langMap['code'] as String;
          final name = langMap['name'] as String;

          // Use our predefined language data if available
          if (LanguageConstants.supportedLanguages.containsKey(code)) {
            final langInfo = LanguageConstants.supportedLanguages[code]!;
            languages.add(LanguageModel(
              code: code,
              name: langInfo['name']!,
              nativeName: langInfo['nativeName']!,
              flag: langInfo['flag']!,
              isRtl: langInfo['rtl'] == 'true',
              family: langInfo['family']!,
              supportsSTT: LanguageConstants.supportsSpeechToText(code),
              supportsTTS: LanguageConstants.supportsTextToSpeech(code),
              supportsOCR: LanguageConstants.supportsOcr(code),
            ));
          } else {
            // Fallback for unknown languages
            languages.add(LanguageModel(
              code: code,
              name: name,
              nativeName: name,
              flag: '🌍',
              isRtl: false,
              family: 'Other',
              supportsSTT: false,
              supportsTTS: false,
              supportsOCR: false,
            ));
          }
        } catch (e) {
          // Skip invalid language entries
          continue;
        }
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
    try {
      final requestData = {
        ApiConstants.paramQ: text.trim(),
        ApiConstants.paramSource: sourceLanguage,
        ApiConstants.paramTarget: targetLanguage,
        ApiConstants.paramFormat: ApiConstants.defaultFormat,
        ApiConstants.paramAlternatives: alternatives,
      };

      final response = await _dioClient.post(
        ApiConstants.translateEndpoint,
        data: requestData,
      );

      final responseData = response.data as Map<String, dynamic>;

      // Primary translation
      final primaryTranslation = responseData['translatedText'] as String;
      final alternativesList = <String>[primaryTranslation];

      // Alternative translations (if supported by API)
      if (responseData.containsKey('alternatives')) {
        final alternatives = responseData['alternatives'] as List<dynamic>;
        for (final alt in alternatives) {
          if (alt is String && alt != primaryTranslation) {
            alternativesList.add(alt);
          }
        }
      }

      return alternativesList;
    } catch (e) {
      if (e is ServerException || e is NetworkException) {
        rethrow;
      }

      throw ServerException(
        message: 'Failed to get translation alternatives: ${e.toString()}',
        code: 'ALTERNATIVES_FAILED',
      );
    }
  }
}
