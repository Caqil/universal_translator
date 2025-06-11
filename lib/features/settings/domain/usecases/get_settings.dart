
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/app_settings_model.dart';
import '../repositories/settings_repository.dart';

class GetSettings implements NoParamsUseCase<AppSettings> {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  @override
  Future<Either<Failure, AppSettings>> call() async {
    return await _repository.getSettings();
  }
}

class GetSetting<T> implements UseCase<T?, GetSettingParams> {
  final SettingsRepository _repository;

  GetSetting(this._repository);

  @override
  Future<Either<Failure, T?>> call(GetSettingParams params) async {
    return await _repository.getSetting<T>(params.key);
  }
}

class HasSettings implements NoParamsUseCase<bool> {
  final SettingsRepository _repository;

  HasSettings(this._repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return await _repository.hasSettings();
  }
}

class WatchSettings implements NoParamsUseCase<Stream<AppSettings>> {
  final SettingsRepository _repository;

  WatchSettings(this._repository);

  @override
  Future<Either<Failure, Stream<AppSettings>>> call() async {
    try {
      final stream = _repository.watchSettings().map(
            (either) => either.fold(
              (failure) => throw failure,
              (settings) => settings,
            ),
          );
      return Right(stream);
    } catch (e) {
      return Left(CacheFailure(
        message: 'Failed to watch settings: ${e.toString()}',
        code: 'WATCH_SETTINGS_FAILED',
      ));
    }
  }
}

class ExportSettings implements NoParamsUseCase<Map<String, dynamic>> {
  final SettingsRepository _repository;

  ExportSettings(this._repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await _repository.exportSettings();
  }
}

/// Parameters for getting a specific setting
class GetSettingParams {
  final String key;

  const GetSettingParams({required this.key});
}
