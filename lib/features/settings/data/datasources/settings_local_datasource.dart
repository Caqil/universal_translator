// lib/features/settings/data/datasources/settings_local_datasource.dart
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../models/app_settings_model.dart';
import '../models/settings_model.dart';

/// Abstract interface for settings local data source
abstract class SettingsLocalDataSource {
  /// Get current settings
  Future<SettingsModel> getSettings();

  /// Save settings
  Future<void> saveSettings(SettingsModel settings);

  /// Reset settings to default
  Future<void> resetSettings();

  /// Get specific setting value
  Future<T?> getSetting<T>(String key);

  /// Save specific setting value
  Future<void> saveSetting<T>(String key, T value);

  /// Check if settings exist
  Future<bool> hasSettings();

  /// Export settings as JSON
  Future<Map<String, dynamic>> exportSettings();

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settingsJson);

  /// Get settings version for migration
  Future<int> getSettingsVersion();

  /// Set settings version
  Future<void> setSettingsVersion(int version);
}

/// Implementation of settings local data source using Hive
@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box _settingsBox;

  static const String _settingsKey = 'app_settings';
  static const String _versionKey = 'settings_version';
  static const int _currentVersion = 1;

  SettingsLocalDataSourceImpl(
    @Named('settingsBox') this._settingsBox,
  );

  @override
  Future<SettingsModel> getSettings() async {
    try {
      // Check if we have settings in the box
      if (!_settingsBox.containsKey(_settingsKey)) {
        // Return default settings if none exist
        final defaultSettings = SettingsModel.defaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }

      final data = _settingsBox.get(_settingsKey);

      // Handle different data types for backward compatibility
      if (data is SettingsModel) {
        return data;
      } else if (data is Map) {
        // Convert Map to proper format
        final Map<String, dynamic> jsonData = Map<String, dynamic>.from(data);
        return SettingsModel.fromJson(jsonData);
      } else {
        // Fallback to default if data is corrupted
        print('⚠️ Settings data corrupted, using defaults');
        final defaultSettings = SettingsModel.defaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
    } catch (e) {
      print('❌ Error getting settings: $e');
      // Return default settings on any error
      final defaultSettings = SettingsModel.defaultSettings();
      try {
        await saveSettings(defaultSettings);
      } catch (saveError) {
        print('❌ Error saving default settings: $saveError');
      }
      return defaultSettings;
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      // Save as SettingsModel object (Hive will serialize it)
      await _settingsBox.put(_settingsKey, settings);
      print('✅ Settings saved successfully');
    } catch (e) {
      print('❌ Error saving settings: $e');
      throw CacheException.writeError('Failed to save settings: $e');
    }
  }

  @override
  Future<void> resetSettings() async {
    try {
      // Delete current settings
      await _settingsBox.delete(_settingsKey);

      // Save default settings
      final defaultSettings = SettingsModel.defaultSettings();
      await saveSettings(defaultSettings);

      print('✅ Settings reset to defaults');
    } catch (e) {
      print('❌ Error resetting settings: $e');
      throw CacheException.writeError('Failed to reset settings: $e');
    }
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await getSettings();
      final settingsJson = settings.toJson();

      if (settingsJson.containsKey(key)) {
        final value = settingsJson[key];
        if (value is T) {
          return value;
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting setting $key: $e');
      return null;
    }
  }

  @override
  Future<void> saveSetting<T>(String key, T value) async {
    try {
      // Get current settings
      final currentSettings = await getSettings();

      // Update the specific setting
      final updatedSettings = _updateSetting(currentSettings, key, value);

      // Save updated settings
      await saveSettings(updatedSettings);

      print('✅ Setting $key updated successfully');
    } catch (e) {
      print('❌ Error saving setting $key: $e');
      throw CacheException.writeError('Failed to save setting $key: $e');
    }
  }

  /// Helper method to update a specific setting
  SettingsModel _updateSetting<T>(SettingsModel settings, String key, T value) {
    switch (key) {
      case 'theme':
        if (value is String) {
          final theme = AppTheme.values.firstWhere(
            (e) => e.name == value,
            orElse: () => AppTheme.system,
          );
          return settings.copyWith(theme: theme);
        }
        break;
      case 'language':
        if (value is String) {
          return settings.copyWith(language: value);
        }
        break;
      case 'autoTranslate':
        if (value is bool) {
          return settings.copyWith(autoTranslate: value);
        }
        break;
      case 'autoTranslateDelay':
        if (value is int) {
          return settings.copyWith(autoTranslateDelay: value);
        }
        break;
      case 'enableSpeechFeedback':
        if (value is bool) {
          return settings.copyWith(enableSpeechFeedback: value);
        }
        break;
      case 'speechRate':
        if (value is double) {
          return settings.copyWith(speechRate: value);
        }
        break;
      case 'speechPitch':
        if (value is double) {
          return settings.copyWith(speechPitch: value);
        }
        break;
      case 'speechVolume':
        if (value is double) {
          return settings.copyWith(speechVolume: value);
        }
        break;
      case 'enableHapticFeedback':
        if (value is bool) {
          return settings.copyWith(enableHapticFeedback: value);
        }
        break;
      case 'enableSoundEffects':
        if (value is bool) {
          return settings.copyWith(enableSoundEffects: value);
        }
        break;
      case 'soundEffectsVolume':
        if (value is double) {
          return settings.copyWith(soundEffectsVolume: value);
        }
        break;
      case 'enableNotifications':
        if (value is bool) {
          return settings.copyWith(enableNotifications: value);
        }
        break;
      case 'enablePushNotifications':
        if (value is bool) {
          return settings.copyWith(enablePushNotifications: value);
        }
        break;
      case 'defaultSourceLanguage':
        if (value is String) {
          return settings.copyWith(defaultSourceLanguage: value);
        }
        break;
      case 'defaultTargetLanguage':
        if (value is String) {
          return settings.copyWith(defaultTargetLanguage: value);
        }
        break;
      case 'showTranslationConfidence':
        if (value is bool) {
          return settings.copyWith(showTranslationConfidence: value);
        }
        break;
      case 'showAlternativeTranslations':
        if (value is bool) {
          return settings.copyWith(showAlternativeTranslations: value);
        }
        break;
      case 'maxHistoryItems':
        if (value is int) {
          return settings.copyWith(maxHistoryItems: value);
        }
        break;
      case 'autoSaveTranslations':
        if (value is bool) {
          return settings.copyWith(autoSaveTranslations: value);
        }
        break;
      case 'enableOfflineMode':
        if (value is bool) {
          return settings.copyWith(enableOfflineMode: value);
        }
        break;
      case 'dataUsageMode':
        if (value is String) {
          final mode = DataUsageMode.values.firstWhere(
            (e) => e.name == value,
            orElse: () => DataUsageMode.standard,
          );
          return settings.copyWith(dataUsageMode: mode);
        }
        break;
      case 'fontSizeMultiplier':
        if (value is double) {
          return settings.copyWith(fontSizeMultiplier: value.clamp(0.8, 2.0));
        }
        break;
      case 'enableHighContrast':
        if (value is bool) {
          return settings.copyWith(enableHighContrast: value);
        }
        break;
      case 'enableReduceMotion':
        if (value is bool) {
          return settings.copyWith(enableReduceMotion: value);
        }
        break;
      case 'useCameraFlash':
        if (value is bool) {
          return settings.copyWith(useCameraFlash: value);
        }
        break;
      case 'autoDetectLanguage':
        if (value is bool) {
          return settings.copyWith(autoDetectLanguage: value);
        }
        break;
      case 'translationCacheDuration':
        if (value is int) {
          return settings.copyWith(translationCacheDuration: value);
        }
        break;
      case 'analyticsConsent':
        if (value is bool) {
          return settings.copyWith(analyticsConsent: value);
        }
        break;
      case 'crashReportingConsent':
        if (value is bool) {
          return settings.copyWith(crashReportingConsent: value);
        }
        break;
    }

    // Return original settings if key not found
    print('⚠️ Unknown setting key: $key');
    return settings;
  }

  @override
  Future<bool> hasSettings() async {
    try {
      return _settingsBox.containsKey(_settingsKey);
    } catch (e) {
      print('❌ Error checking settings existence: $e');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getSettings();
      return settings.toJson();
    } catch (e) {
      print('❌ Error exporting settings: $e');
      throw CacheException.readError('Failed to export settings: $e');
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settingsJson) async {
    try {
      final settings = SettingsModel.fromJson(settingsJson);
      await saveSettings(settings);
      print('✅ Settings imported successfully');
    } catch (e) {
      print('❌ Error importing settings: $e');
      throw CacheException.writeError('Failed to import settings: $e');
    }
  }

  @override
  Future<int> getSettingsVersion() async {
    try {
      return _settingsBox.get(_versionKey, defaultValue: _currentVersion);
    } catch (e) {
      print('❌ Error getting settings version: $e');
      return _currentVersion;
    }
  }

  @override
  Future<void> setSettingsVersion(int version) async {
    try {
      await _settingsBox.put(_versionKey, version);
    } catch (e) {
      print('❌ Error setting settings version: $e');
      throw CacheException.writeError('Failed to set settings version: $e');
    }
  }
}
