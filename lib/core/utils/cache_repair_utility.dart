// lib/core/utils/cache_repair_utility.dart
import 'package:hive/hive.dart';

class CacheRepairUtility {
  /// Repair corrupted language cache
  static Future<void> repairLanguageCache() async {
    try {
      final box = await Hive.openBox('languages');

      // Check if the cached data is corrupted
      final cachedData = box.get('supported_languages');

      if (cachedData != null) {
        bool isCorrupted = false;

        if (cachedData is List<dynamic>) {
          // Check if any entries are corrupted
          for (final entry in cachedData) {
            if (entry is Map<String, dynamic>) {
              // Check if it has the old format (with 'targets' field) instead of new format
              if (entry.containsKey('targets') &&
                  !entry.containsKey('nativeName')) {
                isCorrupted = true;
                break;
              }
            }
          }
        } else if (cachedData is String) {
          // If it's a string, it's definitely corrupted
          isCorrupted = true;
        }

        if (isCorrupted) {
          print('Detected corrupted language cache, clearing...');
          await box.delete('supported_languages');
          await box.delete('languages_cached_at');
          print('Language cache cleared successfully');
        }
      }

      await box.close();
    } catch (e) {
      print('Error repairing language cache: $e');
    }
  }

  /// Repair corrupted translation cache
  static Future<void> repairTranslationCache() async {
    try {
      final box = await Hive.openBox('translations');

      final keysToRemove = <dynamic>[];

      for (final key in box.keys) {
        try {
          final data = box.get(key);
          if (data is Map<String, dynamic>) {
            // Try to validate the structure
            if (!_isValidTranslationData(data)) {
              keysToRemove.add(key);
            }
          } else {
            // Invalid data type
            keysToRemove.add(key);
          }
        } catch (e) {
          // Corrupted entry
          keysToRemove.add(key);
        }
      }

      // Remove corrupted entries
      for (final key in keysToRemove) {
        await box.delete(key);
      }

      if (keysToRemove.isNotEmpty) {
        print('Removed ${keysToRemove.length} corrupted translation entries');
      }

      await box.close();
    } catch (e) {
      print('Error repairing translation cache: $e');
    }
  }

  /// Repair corrupted settings cache
  static Future<void> repairSettingsCache() async {
    try {
      final box = await Hive.openBox('settings');

      // Check and repair recent languages
      final recentLanguages = box.get('recent_languages');
      if (recentLanguages != null && recentLanguages is! List) {
        await box.delete('recent_languages');
        print('Repaired corrupted recent languages cache');
      }

      await box.close();
    } catch (e) {
      print('Error repairing settings cache: $e');
    }
  }

  /// Repair all caches
  static Future<void> repairAllCaches() async {
    print('Starting cache repair process...');

    await repairLanguageCache();
    await repairTranslationCache();
    await repairSettingsCache();

    print('Cache repair process completed');
  }

  /// Check if translation data is valid
  static bool _isValidTranslationData(Map<String, dynamic> data) {
    final requiredFields = [
      'id',
      'sourceText',
      'translatedText',
      'sourceLanguage',
      'targetLanguage',
      'timestamp'
    ];

    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        return false;
      }
    }

    return true;
  }

  /// Clear all caches (nuclear option)
  static Future<void> clearAllCaches() async {
    try {
      print('Clearing all caches...');

      // Clear languages cache
      try {
        final languagesBox = await Hive.openBox('languages');
        await languagesBox.clear();
        await languagesBox.close();
        print('Languages cache cleared');
      } catch (e) {
        print('Error clearing languages cache: $e');
      }

      // Clear translations cache
      try {
        final translationsBox = await Hive.openBox('translations');
        await translationsBox.clear();
        await translationsBox.close();
        print('Translations cache cleared');
      } catch (e) {
        print('Error clearing translations cache: $e');
      }

      // Clear settings cache
      try {
        final settingsBox = await Hive.openBox('settings');
        await settingsBox.clear();
        await settingsBox.close();
        print('Settings cache cleared');
      } catch (e) {
        print('Error clearing settings cache: $e');
      }

      print('All caches cleared successfully');
    } catch (e) {
      print('Error clearing caches: $e');
    }
  }
}
