// lib/features/translation/data/datasources/translation_local_datasource.dart - UPDATED getCachedLanguages method
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

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

/// Implementation of translation local data source using Hive
@LazySingleton(as: TranslationLocalDataSource)
class TranslationLocalDataSourceImpl implements TranslationLocalDataSource {
  final Box _translationsBox;
  final Box _languagesBox;
  final Box _settingsBox;

  TranslationLocalDataSourceImpl(
    @Named('translationsBox') this._translationsBox,
    @Named('languagesBox') this._languagesBox,
    @Named('settingsBox') this._settingsBox,
  );

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

      // Safely handle different data types that might be cached
      if (data is List<dynamic>) {
        final languages = <LanguageModel>[];

        for (final langData in data) {
          try {
            if (langData is Map<String, dynamic>) {
              // Validate that the cached data has the required fields for LanguageModel
              if (_isValidLanguageModel(langData)) {
                final language = LanguageModel.fromJson(langData);
                languages.add(language);
              } else {
                // Skip invalid entries - they might be from old format
                print(
                    'Warning: Skipping invalid cached language entry: $langData');
              }
            }
          } catch (e) {
            // Skip entries that can't be parsed
            print('Warning: Failed to parse cached language entry: $e');
            continue;
          }
        }

        return languages;
      } else if (data is String) {
        // If somehow a JSON string was cached, clear it and return empty
        // This handles cases where the wrong format might have been cached
        await _languagesBox.delete('supported_languages');
        await _languagesBox.delete('languages_cached_at');
        return [];
      } else {
        // Unknown format, clear and return empty
        await _languagesBox.delete('supported_languages');
        await _languagesBox.delete('languages_cached_at');
        return [];
      }
    } catch (e) {
      // If there's any error reading cache, clear it and return empty
      print('Error reading cached languages, clearing cache: $e');
      try {
        await _languagesBox.delete('supported_languages');
        await _languagesBox.delete('languages_cached_at');
      } catch (clearError) {
        print('Error clearing language cache: $clearError');
      }
      return [];
    }
  }

  /// Validate that a cached language entry has all required fields for LanguageModel
  bool _isValidLanguageModel(Map<String, dynamic> data) {
    final requiredFields = ['code', 'name', 'nativeName', 'flag'];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }

    return true;
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

      if (startIndex >= allTranslations.length) {
        return [];
      }

      return allTranslations.sublist(startIndex, endIndex);
    } catch (e) {
      throw CacheException.readError('Failed to get translation history: $e');
    }
  }

  @override
  Future<List<TranslationModel>> searchTranslations(String query) async {
    try {
      final allTranslations = await getAllTranslations();
      final queryLower = query.toLowerCase();

      return allTranslations.where((translation) {
        return translation.sourceText.toLowerCase().contains(queryLower) ||
            translation.translatedText.toLowerCase().contains(queryLower);
      }).toList();
    } catch (e) {
      throw CacheException.readError('Failed to search translations: $e');
    }
  }

  @override
  Future<List<String>> getRecentLanguages() async {
    try {
      final recentLanguages = _settingsBox.get('recent_languages');
      if (recentLanguages == null) return [];

      return List<String>.from(recentLanguages);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRecentLanguage(String languageCode) async {
    try {
      if (languageCode == 'auto') return; // Don't save auto-detect

      final recentLanguages = await getRecentLanguages();

      // Remove if already exists
      recentLanguages.remove(languageCode);

      // Add to front
      recentLanguages.insert(0, languageCode);

      // Keep only last 10
      if (recentLanguages.length > 10) {
        recentLanguages.removeRange(10, recentLanguages.length);
      }

      await _settingsBox.put('recent_languages', recentLanguages);
    } catch (e) {
      // Don't throw error for recent languages - it's not critical
      print('Warning: Failed to save recent language: $e');
    }
  }

  /// Maintain translation cache size limit
  Future<void> _maintainSizeLimit() async {
    try {
      final maxTranslations = 1000;

      if (_translationsBox.length > maxTranslations) {
        final allTranslations = await getAllTranslations();

        // Sort by timestamp (oldest first for removal)
        allTranslations.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Remove oldest entries
        final toRemove = allTranslations.length - maxTranslations;
        for (int i = 0; i < toRemove; i++) {
          await _translationsBox.delete(allTranslations[i].id);
        }
      }
    } catch (e) {
      print('Warning: Failed to maintain cache size limit: $e');
    }
  }
}
