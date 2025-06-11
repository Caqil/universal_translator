import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
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

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final Box _settingsBox;

  static const String _settingsKey = 'app_settings';
  static const String _versionKey = 'settings_version';
  static const int _currentVersion = 1;

  SettingsLocalDataSourceImpl(
    this._settingsBox,
  );

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final data = _settingsBox.get(_settingsKey);

      if (data == null) {
        // Return default settings if none exist
        final defaultSettings = SettingsModel.defaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }

      // Handle different data types
      if (data is SettingsModel) {
        return data;
      } else if (data is Map<String, dynamic>) {
        return SettingsModel.fromJson(data);
      } else {
        throw CacheException.readError('Invalid settings data format');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.readError('Failed to get settings: $e');
    }
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _settingsBox.put(_settingsKey, settings);
      await setSettingsVersion(_currentVersion);
    } catch (e) {
      throw CacheException.writeError('Failed to save settings: $e');
    }
  }

  @override
  Future<void> resetSettings() async {
    try {
      final defaultSettings = SettingsModel.defaultSettings();
      await _settingsBox.put(_settingsKey, defaultSettings);
      await setSettingsVersion(_currentVersion);
    } catch (e) {
      throw CacheException.writeError('Failed to reset settings: $e');
    }
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await getSettings();
      final settingsJson = settings.toJson();
      return settingsJson[key] as T?;
    } catch (e) {
      throw CacheException.readError('Failed to get setting $key: $e');
    }
  }

  @override
  Future<void> saveSetting<T>(String key, T value) async {
    try {
      final currentSettings = await getSettings();
      final settingsJson = currentSettings.toJson();
      settingsJson[key] = value;

      final updatedSettings = SettingsModel.fromJson(settingsJson);
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheException.writeError('Failed to save setting $key: $e');
    }
  }

  @override
  Future<bool> hasSettings() async {
    try {
      return _settingsBox.containsKey(_settingsKey);
    } catch (e) {
      throw CacheException.readError('Failed to check settings existence: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getSettings();
      return {
        'settings': settings.toJson(),
        'version': _currentVersion,
        'exportedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw CacheException.readError('Failed to export settings: $e');
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settingsJson) async {
    try {
      final settingsData = settingsJson['settings'] as Map<String, dynamic>?;
      if (settingsData == null) {
        throw CacheException.readError('Invalid settings format for import');
      }

      final importedSettings = SettingsModel.fromJson(settingsData);
      await saveSettings(importedSettings);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException.writeError('Failed to import settings: $e');
    }
  }

  @override
  Future<int> getSettingsVersion() async {
    try {
      return _settingsBox.get(_versionKey, defaultValue: 0) as int;
    } catch (e) {
      throw CacheException.readError('Failed to get settings version: $e');
    }
  }

  @override
  Future<void> setSettingsVersion(int version) async {
    try {
      await _settingsBox.put(_versionKey, version);
    } catch (e) {
      throw CacheException.writeError('Failed to set settings version: $e');
    }
  }
}

class SettingsMigrationHelper {
  final SettingsLocalDataSource _dataSource;

  SettingsMigrationHelper(this._dataSource);

  /// Migrate settings if needed
  Future<void> migrateIfNeeded() async {
    try {
      final currentVersion = await _dataSource.getSettingsVersion();
      const targetVersion = SettingsLocalDataSourceImpl._currentVersion;

      if (currentVersion < targetVersion) {
        await _performMigration(currentVersion, targetVersion);
        await _dataSource.setSettingsVersion(targetVersion);
      }
    } catch (e) {
      throw CacheException.readError('Settings migration failed: $e');
    }
  }

  /// Perform migration between versions
  Future<void> _performMigration(int fromVersion, int toVersion) async {
    // Migration logic for future versions
    // Example:
    // if (fromVersion < 1) {
    //   await _migrateToV1();
    // }
    // if (fromVersion < 2) {
    //   await _migrateToV2();
    // }
  }
}
