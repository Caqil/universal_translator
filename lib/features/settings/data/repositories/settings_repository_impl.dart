import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';
import '../models/settings_model.dart';

/// Implementation of settings repository
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;
  final StreamController<AppSettings> _settingsController;

  SettingsRepositoryImpl(this._localDataSource)
      : _settingsController = StreamController<AppSettings>.broadcast();

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settingsModel = await _localDataSource.getSettings();
      return Right(settingsModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get settings: ${e.toString()}',
        code: 'GET_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(settingsModel);

      // Notify listeners of settings change
      _settingsController.add(settings);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update settings: ${e.toString()}',
        code: 'UPDATE_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    try {
      await _localDataSource.resetSettings();

      // Get the default settings and notify listeners
      final defaultSettings = SettingsModel.defaultSettings().toEntity();
      _settingsController.add(defaultSettings);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to reset settings: ${e.toString()}',
        code: 'RESET_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateSetting<T>(String key, T value) async {
    try {
      await _localDataSource.saveSetting<T>(key, value);

      // Get updated settings and notify listeners
      final settingsResult = await getSettings();
      settingsResult.fold(
        (failure) => null, // Error already handled in getSettings
        (settings) => _settingsController.add(settings),
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to update setting $key: ${e.toString()}',
        code: 'UPDATE_SETTING_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, T?>> getSetting<T>(String key) async {
    try {
      final value = await _localDataSource.getSetting<T>(key);
      return Right(value);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to get setting $key: ${e.toString()}',
        code: 'GET_SETTING_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> exportSettings() async {
    try {
      final exportData = await _localDataSource.exportSettings();
      return Right(exportData);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to export settings: ${e.toString()}',
        code: 'EXPORT_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> importSettings(
      Map<String, dynamic> settingsJson) async {
    try {
      await _localDataSource.importSettings(settingsJson);

      // Get imported settings and notify listeners
      final settingsResult = await getSettings();
      settingsResult.fold(
        (failure) => null, // Error already handled in getSettings
        (settings) => _settingsController.add(settings),
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to import settings: ${e.toString()}',
        code: 'IMPORT_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Future<Either<Failure, bool>> hasSettings() async {
    try {
      final exists = await _localDataSource.hasSettings();
      return Right(exists);
    } on CacheException catch (e) {
      return Left(CacheFailure.fromException(e));
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to check settings existence: ${e.toString()}',
        code: 'CHECK_SETTINGS_FAILED',
      ));
    }
  }

  @override
  Stream<Either<Failure, AppSettings>> watchSettings() {
    return _settingsController.stream.map((settings) => Right(settings));
  }

  /// Dispose resources
  void dispose() {
    _settingsController.close();
  }
}
