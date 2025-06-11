// lib/features/settings/domain/usecases/update_settings.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/app_settings_model.dart';
import '../repositories/settings_repository.dart';

/// Use case for updating application settings
@injectable
class UpdateSettings implements UseCase<void, UpdateSettingsParams> {
  final SettingsRepository _repository;

  UpdateSettings(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingsParams params) async {
    return await _repository.updateSettings(params.settings);
  }
}

/// Use case for updating a specific setting
@injectable
class UpdateSetting<T> implements UseCase<void, UpdateSettingParams<T>> {
  final SettingsRepository _repository;

  UpdateSetting(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingParams<T> params) async {
    return await _repository.updateSetting<T>(params.key, params.value);
  }
}

/// Use case for resetting settings to default
@injectable
class ResetSettings implements NoParamsUseCase<void> {
  final SettingsRepository _repository;

  ResetSettings(this._repository);

  @override
  Future<Either<Failure, void>> call() async {
    return await _repository.resetSettings();
  }
}

/// Use case for importing settings from backup
@injectable
class ImportSettings implements UseCase<void, ImportSettingsParams> {
  final SettingsRepository _repository;

  ImportSettings(this._repository);

  @override
  Future<Either<Failure, void>> call(ImportSettingsParams params) async {
    return await _repository.importSettings(params.settingsJson);
  }
}

/// Use case for updating theme
@injectable
class UpdateTheme implements UseCase<void, UpdateThemeParams> {
  final SettingsRepository _repository;

  UpdateTheme(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateThemeParams params) async {
    return await _repository.updateSetting<String>('theme', params.theme.name);
  }
}

/// Use case for updating language
@injectable
class UpdateLanguage implements UseCase<void, UpdateLanguageParams> {
  final SettingsRepository _repository;

  UpdateLanguage(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateLanguageParams params) async {
    return await _repository.updateSetting<String>(
        'language', params.languageCode);
  }
}

/// Parameters for updating settings
class UpdateSettingsParams {
  final AppSettings settings;

  const UpdateSettingsParams({required this.settings});
}

/// Parameters for updating a specific setting
class UpdateSettingParams<T> {
  final String key;
  final T value;

  const UpdateSettingParams({
    required this.key,
    required this.value,
  });
}

/// Parameters for importing settings
class ImportSettingsParams {
  final Map<String, dynamic> settingsJson;

  const ImportSettingsParams({required this.settingsJson});
}

/// Parameters for updating theme
class UpdateThemeParams {
  final AppTheme theme;

  const UpdateThemeParams({required this.theme});
}

/// Parameters for updating language
class UpdateLanguageParams {
  final String languageCode;

  const UpdateLanguageParams({required this.languageCode});
}
