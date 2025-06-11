import 'package:hive/hive.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/translation_model.dart';
import '../models/language_model.dart';

/// Abstract interface for translation local data source
abstract class TranslationLocalDataSource {
  /// Cache a translation
  Future<void> cacheTranslation(TranslationModel translation);

  /// Get cached translation
  Future<TranslationModel?> getCachedTranslation(String id);

  /// Get all cached translations
  Future<List<TranslationModel>> getAllTranslations();

  /// Delete cached translation
  Future<void> deleteTranslation(String id);

  /// Clear all translations
  Future<void> clearAllTranslations();

  /// Cache supported languages
  Future<void> cacheLanguages(List<LanguageModel> languages);

  /// Get cached languages
  Future<List<LanguageModel>> getCachedLanguages();

  /// Get translation history
  Future<List<TranslationModel>> getTranslationHistory({
    int? limit,
    int? offset,
  });

  /// Search translations
  Future<List<TranslationModel>> searchTranslations(String query);

  /// Get recent languages used
  Future<List<String>> getRecentLanguages();

  /// Save recent language
  Future<void> saveRecentLanguage(String languageCode);
}

class TranslationLocalDataSourceImpl implements TranslationLocalDataSource {
  final Box _translationsBox;
  final Box _languagesBox;
  final Box _settingsBox;

  TranslationLocalDataSourceImpl(
      this._translationsBox, this._languagesBox, this._settingsBox);

  @override
  Future<void> cacheTranslation(TranslationModel translation) async {
    try {
      await _translationsBox.put(translation.id, translation.toJson());

      // Maintain size limit
      await _maintainSizeLimit();

      // Update recent languages
      await saveRecentLanguage(translation.sourceLanguage);
      await saveRecentLanguage(translation.targetLanguage);
    } catch (e) {
      throw CacheException.writeError('Failed to cache translation: $e');
    }
  }

  @override
  Future<TranslationModel?> getCachedTranslation(String id) async {
    try {
      final data = _translationsBox.get(id);
      if (data == null) return null;

      return TranslationModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      throw CacheException.readError('Failed to get cached translation: $e');
    }
  }

  @override
  Future<List<TranslationModel>> getAllTranslations() async {
    try {
      final translations = <TranslationModel>[];

      for (final key in _translationsBox.keys) {
        final data = _translationsBox.get(key);
        if (data != null) {
          try {
            final translation = TranslationModel.fromJson(
              Map<String, dynamic>.from(data),
            );
            translations.add(translation);
          } catch (e) {
            // Skip invalid entries
            continue;
          }
        }
      }

      // Sort by timestamp (newest first)
      translations.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return translations;
    } catch (e) {
      throw CacheException.readError('Failed to get all translations: $e');
    }
  }

  @override
  Future<void> deleteTranslation(String id) async {
    try {
      await _translationsBox.delete(id);
    } catch (e) {
      throw CacheException.deleteError('Failed to delete translation: $e');
    }
  }

  @override
  Future<void> clearAllTranslations() async {
    try {
      await _translationsBox.clear();
    } catch (e) {
      throw CacheException.deleteError('Failed to clear translations: $e');
    }
  }

  @override
  Future<void> cacheLanguages(List<LanguageModel> languages) async {
    try {
      final languagesData = languages.map((lang) => lang.toJson()).toList();
      await _languagesBox.put('supported_languages', languagesData);
      await _languagesBox.put(
          'languages_cached_at', DateTime.now().toIso8601String());
    } catch (e) {
      throw CacheException.writeError('Failed to cache languages: $e');
    }
  }

  @override
  Future<List<LanguageModel>> getCachedLanguages() async {
    try {
      final data = _languagesBox.get('supported_languages');
      if (data == null) return [];

      // Check if cache is still valid (24 hours)
      final cachedAt = _languagesBox.get('languages_cached_at');
      if (cachedAt != null) {
        final cacheTime = DateTime.parse(cachedAt);
        final now = DateTime.now();
        if (now.difference(cacheTime).inHours > 24) {
          return []; // Cache expired
        }
      }

      final languagesList = List<Map<String, dynamic>>.from(data);
      return languagesList.map((lang) => LanguageModel.fromJson(lang)).toList();
    } catch (e) {
      throw CacheException.readError('Failed to get cached languages: $e');
    }
  }

  @override
  Future<List<TranslationModel>> getTranslationHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final allTranslations = await getAllTranslations();

      // Apply pagination
      final startIndex = offset ?? 0;
      final endIndex = limit != null
          ? (startIndex + limit).clamp(0, allTranslations.length)
          : allTranslations.length;

      if (startIndex >= allTranslations.length) return [];

      return allTranslations.sublist(startIndex, endIndex);
    } catch (e) {
      throw CacheException.readError('Failed to get translation history: $e');
    }
  }

  @override
  Future<List<TranslationModel>> searchTranslations(String query) async {
    try {
      final allTranslations = await getAllTranslations();
      final searchQuery = query.toLowerCase().trim();

      if (searchQuery.isEmpty) return allTranslations;

      return allTranslations.where((translation) {
        final sourceText = translation.sourceText.toLowerCase();
        final translatedText = translation.translatedText.toLowerCase();

        return sourceText.contains(searchQuery) ||
            translatedText.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw CacheException.readError('Failed to search translations: $e');
    }
  }

  @override
  Future<List<String>> getRecentLanguages() async {
    try {
      final recentLanguages = _settingsBox.get(
        AppConstants.keyRecentLanguages,
        defaultValue: <String>[],
      );
      return List<String>.from(recentLanguages);
    } catch (e) {
      throw CacheException.readError('Failed to get recent languages: $e');
    }
  }

  @override
  Future<void> saveRecentLanguage(String languageCode) async {
    try {
      if (languageCode == 'auto') return; // Don't save auto-detect

      final recentLanguages = await getRecentLanguages();

      // Remove if already exists
      recentLanguages.remove(languageCode);

      // Add to beginning
      recentLanguages.insert(0, languageCode);

      // Keep only recent languages
      if (recentLanguages.length > AppConstants.maxRecentLanguages) {
        recentLanguages.removeRange(
          AppConstants.maxRecentLanguages,
          recentLanguages.length,
        );
      }

      await _settingsBox.put(AppConstants.keyRecentLanguages, recentLanguages);
    } catch (e) {
      throw CacheException.writeError('Failed to save recent language: $e');
    }
  }

  /// Maintain size limit for cached translations
  Future<void> _maintainSizeLimit() async {
    try {
      if (_translationsBox.length <= AppConstants.maxHistoryItems) return;

      final translations = await getAllTranslations();

      // Remove oldest translations
      final toRemove = translations.length - AppConstants.maxHistoryItems;
      for (int i = 0; i < toRemove; i++) {
        final oldestTranslation = translations[translations.length - 1 - i];
        await _translationsBox.delete(oldestTranslation.id);
      }
    } catch (e) {
      // Don't throw error for maintenance operations
      print('Failed to maintain cache size limit: $e');
    }
  }
}
