import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/app_settings_model.dart';

/// Abstract repository for settings operations
abstract class SettingsRepository {
  /// Get current application settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update application settings
  Future<Either<Failure, void>> updateSettings(AppSettings settings);

  /// Reset settings to default values
  Future<Either<Failure, void>> resetSettings();

  /// Update a specific setting
  Future<Either<Failure, void>> updateSetting<T>(String key, T value);

  /// Get a specific setting value
  Future<Either<Failure, T?>> getSetting<T>(String key);

  /// Export settings as JSON for backup
  Future<Either<Failure, Map<String, dynamic>>> exportSettings();

  /// Import settings from JSON backup
  Future<Either<Failure, void>> importSettings(
      Map<String, dynamic> settingsJson);

  /// Check if settings have been initialized
  Future<Either<Failure, bool>> hasSettings();

  /// Stream of settings changes
  Stream<Either<Failure, AppSettings>> watchSettings();
}
