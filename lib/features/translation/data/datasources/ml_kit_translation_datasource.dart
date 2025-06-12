// lib/features/translation/data/datasources/ml_kit_translation_datasource.dart
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../models/download_status_model.dart';
import '../models/translation_model.dart';

abstract class MLKitTranslationDataSource {
  Future<TranslationModel> translateTextOffline({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  });

  Future<String> detectLanguageOffline(String text);

  Future<DownloadStatusModel> downloadLanguageModel(String languageCode);

  Future<bool> deleteLanguageModel(String languageCode);

  Future<List<DownloadStatusModel>> getDownloadedLanguages();

  Future<bool> isLanguageModelDownloaded(String languageCode);

  Stream<DownloadStatusModel> getDownloadProgress(String languageCode);
}

@LazySingleton(as: MLKitTranslationDataSource)
class MLKitTranslationDataSourceImpl implements MLKitTranslationDataSource {
  final Map<String, OnDeviceTranslator> _translators = {};
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 1);
  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  // Key for storing downloaded models list in SharedPreferences
  static const String _downloadedModelsKey = 'downloaded_language_models';

  @override
  Future<TranslationModel> translateTextOffline({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      final translatorKey = '${sourceLanguage}_$targetLanguage';

      // Check if models are downloaded
      final sourceDownloaded =
          await _modelManager.isModelDownloaded(sourceLanguage);
      final targetDownloaded =
          await _modelManager.isModelDownloaded(targetLanguage);

      if (!sourceDownloaded || !targetDownloaded) {
        throw TranslationException(
          message:
              'Language models not downloaded. Source: $sourceDownloaded, Target: $targetDownloaded',
          code: 'MODEL_NOT_DOWNLOADED',
        );
      }

      // Get or create translator
      OnDeviceTranslator translator;
      if (_translators.containsKey(translatorKey)) {
        translator = _translators[translatorKey]!;
      } else {
        translator = OnDeviceTranslator(
          sourceLanguage: TranslateLanguage.values.firstWhere(
            (lang) => lang.bcpCode == sourceLanguage,
            orElse: () => TranslateLanguage.english,
          ),
          targetLanguage: TranslateLanguage.values.firstWhere(
            (lang) => lang.bcpCode == targetLanguage,
            orElse: () => TranslateLanguage.english,
          ),
        );
        _translators[translatorKey] = translator;
      }

      // Perform translation
      final translatedText = await translator.translateText(text);

      return TranslationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceText: text,
        translatedText: translatedText,
        sourceLanguage: sourceLanguage,
        targetLanguage: targetLanguage,
        confidence: 1.0, // ML Kit doesn't provide confidence scores
        timestamp: DateTime.now(),
    
      );
    } catch (e) {
      throw TranslationException(
        message: 'Offline translation failed: ${e.toString()}',
        code: 'OFFLINE_TRANSLATION_ERROR',
      );
    }
  }

  @override
  Future<String> detectLanguageOffline(String text) async {
    try {
      final List<IdentifiedLanguage> possibleLanguages =
          await _languageIdentifier.identifyPossibleLanguages(text);

      if (possibleLanguages.isEmpty) {
        return 'en'; // Default fallback to English
      }

      // Return the most confident language
      return possibleLanguages.first.languageTag;
    } catch (e) {
      throw TranslationException(
        message: 'Language detection failed: ${e.toString()}',
        code: 'LANGUAGE_DETECTION_ERROR',
      );
    }
  }

  @override
  Future<DownloadStatusModel> downloadLanguageModel(String languageCode) async {
    try {
      // Check if language is supported
      final supportedLanguage = TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == languageCode,
        orElse: () => throw TranslationException(
          message: 'Unsupported language: $languageCode',
          code: 'UNSUPPORTED_LANGUAGE',
        ),
      );

      // Download the model
      final isDownloaded =
          await _modelManager.downloadModel(supportedLanguage.bcpCode);

      if (isDownloaded) {
        // Add to downloaded models list
        await _addToDownloadedList(languageCode);
      }

      return DownloadStatusModel(
        languageCode: languageCode,
        isDownloaded: isDownloaded,
        isDownloading: false,
        progress: isDownloaded ? 1.0 : 0.0,
        sizeInBytes: _getModelSize(languageCode),
        downloadedAt: isDownloaded ? DateTime.now() : null,
      );
    } catch (e) {
      throw TranslationException(
        message: 'Download failed: ${e.toString()}',
        code: 'DOWNLOAD_ERROR',
      );
    }
  }

  @override
  Future<bool> deleteLanguageModel(String languageCode) async {
    try {
      // Check if language is supported
      final supportedLanguage = TranslateLanguage.values.firstWhere(
        (lang) => lang.bcpCode == languageCode,
        orElse: () => throw TranslationException(
          message: 'Unsupported language: $languageCode',
          code: 'UNSUPPORTED_LANGUAGE',
        ),
      );

      final success =
          await _modelManager.deleteModel(supportedLanguage.bcpCode);

      if (success) {
        // Remove from downloaded models list
        await _removeFromDownloadedList(languageCode);

        // Close any active translators using this language
        _closeTranslatorsForLanguage(languageCode);
      }

      return success;
    } catch (e) {
      throw TranslationException(
        message: 'Delete failed: ${e.toString()}',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<List<DownloadStatusModel>> getDownloadedLanguages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadedModels =
          prefs.getStringList(_downloadedModelsKey) ?? <String>[];

      // Verify each model is actually downloaded and update the list
      final verifiedModels = <String>[];
      final downloadStatusList = <DownloadStatusModel>[];

      for (final languageCode in downloadedModels) {
        final isActuallyDownloaded =
            await _modelManager.isModelDownloaded(languageCode);

        if (isActuallyDownloaded) {
          verifiedModels.add(languageCode);
          downloadStatusList.add(DownloadStatusModel(
            languageCode: languageCode,
            isDownloaded: true,
            isDownloading: false,
            progress: 1.0,
            sizeInBytes: _getModelSize(languageCode),
            downloadedAt: DateTime.now(), // We don't store exact download time
          ));
        }
      }

      // Update the stored list with verified models
      if (verifiedModels.length != downloadedModels.length) {
        await prefs.setStringList(_downloadedModelsKey, verifiedModels);
      }

      return downloadStatusList;
    } catch (e) {
      throw TranslationException(
        message: 'Failed to get downloaded languages: ${e.toString()}',
        code: 'GET_DOWNLOADED_ERROR',
      );
    }
  }

  @override
  Future<bool> isLanguageModelDownloaded(String languageCode) async {
    try {
      return await _modelManager.isModelDownloaded(languageCode);
    } catch (e) {
      return false;
    }
  }

  @override
  Stream<DownloadStatusModel> getDownloadProgress(String languageCode) async* {
    // Since ML Kit doesn't provide real-time progress, we simulate it
    for (int i = 0; i <= 10; i++) {
      final progress = i / 10.0;
      yield DownloadStatusModel(
        languageCode: languageCode,
        isDownloaded: progress >= 1.0,
        isDownloading: progress < 1.0,
        progress: progress,
        sizeInBytes: _getModelSize(languageCode),
        downloadedAt: progress >= 1.0 ? DateTime.now() : null,
      );

      if (progress < 1.0) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // Helper method to add language to downloaded list
  Future<void> _addToDownloadedList(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedModels =
        prefs.getStringList(_downloadedModelsKey) ?? <String>[];

    if (!downloadedModels.contains(languageCode)) {
      downloadedModels.add(languageCode);
      await prefs.setStringList(_downloadedModelsKey, downloadedModels);
    }
  }

  // Helper method to remove language from downloaded list
  Future<void> _removeFromDownloadedList(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    final downloadedModels =
        prefs.getStringList(_downloadedModelsKey) ?? <String>[];

    downloadedModels.remove(languageCode);
    await prefs.setStringList(_downloadedModelsKey, downloadedModels);
  }

  // Helper method to close translators using a specific language
  void _closeTranslatorsForLanguage(String languageCode) {
    final keysToRemove =
        _translators.keys.where((key) => key.contains(languageCode)).toList();

    for (final key in keysToRemove) {
      _translators[key]?.close();
      _translators.remove(key);
    }
  }

  // Helper method to get model size (approximate)
  int _getModelSize(String languageCode) {
    // Approximate model sizes in bytes (these are estimates based on ML Kit documentation)
    const Map<String, int> modelSizes = {
      'en': 30 * 1024 * 1024, // 30MB
      'es': 30 * 1024 * 1024, // 30MB
      'fr': 30 * 1024 * 1024, // 30MB
      'de': 30 * 1024 * 1024, // 30MB
      'it': 30 * 1024 * 1024, // 30MB
      'pt': 30 * 1024 * 1024, // 30MB
      'ru': 35 * 1024 * 1024, // 35MB
      'ja': 35 * 1024 * 1024, // 35MB
      'ko': 35 * 1024 * 1024, // 35MB
      'zh': 35 * 1024 * 1024, // 35MB
      'ar': 30 * 1024 * 1024, // 30MB
      'hi': 30 * 1024 * 1024, // 30MB
      'th': 30 * 1024 * 1024, // 30MB
      'vi': 30 * 1024 * 1024, // 30MB
      'tr': 30 * 1024 * 1024, // 30MB
      'pl': 30 * 1024 * 1024, // 30MB
      'nl': 30 * 1024 * 1024, // 30MB
      'sv': 30 * 1024 * 1024, // 30MB
      'da': 30 * 1024 * 1024, // 30MB
      'no': 30 * 1024 * 1024, // 30MB
      'fi': 30 * 1024 * 1024, // 30MB
    };

    return modelSizes[languageCode] ?? 30 * 1024 * 1024; // Default 30MB
  }

  // Get all supported languages by ML Kit
  List<String> getSupportedLanguages() {
    return TranslateLanguage.values.map((lang) => lang.bcpCode).toList();
  }

  void dispose() {
    for (final translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
    _languageIdentifier.close();
  }
}
