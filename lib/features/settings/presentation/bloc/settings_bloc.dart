// lib/features/settings/presentation/bloc/settings_bloc.dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_settings_model.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/update_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;
  final UpdateSetting _updateSetting;
  final ResetSettings _resetSettings;
  final ExportSettings _exportSettings;
  final ImportSettings _importSettings;
  final WatchSettings _watchSettings;

  StreamSubscription<AppSettings>? _settingsSubscription;

  SettingsBloc(
    this._getSettings,
    this._updateSettings,
    this._updateSetting,
    this._resetSettings,
    this._exportSettings,
    this._importSettings,
    this._watchSettings,
  ) : super(const SettingsInitial()) {
    // Register event handlers
    on<LoadSettingsEvent>(_onLoadSettings);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<UpdateThemeEvent>(_onUpdateTheme);
    on<UpdateLanguageEvent>(_onUpdateLanguage);
    on<ToggleAutoTranslateEvent>(_onToggleAutoTranslate);
    on<UpdateAutoTranslateDelayEvent>(_onUpdateAutoTranslateDelay);
    on<ToggleSpeechFeedbackEvent>(_onToggleSpeechFeedback);
    on<UpdateSpeechRateEvent>(_onUpdateSpeechRate);
    on<UpdateSpeechPitchEvent>(_onUpdateSpeechPitch);
    on<UpdateSpeechVolumeEvent>(_onUpdateSpeechVolume);
    on<ToggleHapticFeedbackEvent>(_onToggleHapticFeedback);
    on<ToggleSoundEffectsEvent>(_onToggleSoundEffects);
    on<UpdateSoundEffectsVolumeEvent>(_onUpdateSoundEffectsVolume);
    on<ToggleNotificationsEvent>(_onToggleNotifications);
    on<TogglePushNotificationsEvent>(_onTogglePushNotifications);
    on<UpdateDefaultSourceLanguageEvent>(_onUpdateDefaultSourceLanguage);
    on<UpdateDefaultTargetLanguageEvent>(_onUpdateDefaultTargetLanguage);
    on<ToggleTranslationConfidenceEvent>(_onToggleTranslationConfidence);
    on<ToggleAlternativeTranslationsEvent>(_onToggleAlternativeTranslations);
    on<UpdateMaxHistoryItemsEvent>(_onUpdateMaxHistoryItems);
    on<ToggleAutoSaveTranslationsEvent>(_onToggleAutoSaveTranslations);
    on<ToggleOfflineModeEvent>(_onToggleOfflineMode);
    on<UpdateDataUsageModeEvent>(_onUpdateDataUsageMode);
    on<UpdateFontSizeMultiplierEvent>(_onUpdateFontSizeMultiplier);
    on<ToggleHighContrastEvent>(_onToggleHighContrast);
    on<ToggleReduceMotionEvent>(_onToggleReduceMotion);
    on<ToggleCameraFlashEvent>(_onToggleCameraFlash);
    on<ToggleAutoDetectLanguageEvent>(_onToggleAutoDetectLanguage);
    on<UpdateTranslationCacheDurationEvent>(_onUpdateTranslationCacheDuration);
    on<UpdateAnalyticsConsentEvent>(_onUpdateAnalyticsConsent);
    on<UpdateCrashReportingConsentEvent>(_onUpdateCrashReportingConsent);
    on<ResetSettingsEvent>(_onResetSettings);
    on<ExportSettingsEvent>(_onExportSettings);
    on<ImportSettingsEvent>(_onImportSettings);

    // Start listening to settings changes
    _startWatchingSettings();
  }

  /// Load current settings
  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await _getSettings();
    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
      )),
      (settings) => emit(SettingsLoaded(settings)),
    );
  }

  /// Update all settings
  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SettingsLoaded) {
      emit(SettingsUpdating(currentState.settings));
    }

    final result = await _updateSettings(UpdateSettingsParams(
      settings: event.settings,
    ));

    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
        currentSettings:
            currentState is SettingsLoaded ? currentState.settings : null,
      )),
      (_) => emit(SettingsOperationCompleted(
        'Settings updated successfully',
        event.settings,
        SettingsOperationType.update,
      )),
    );
  }

  /// Update theme
  Future<void> _onUpdateTheme(
    UpdateThemeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'theme',
      value: event.theme.name,
      updateFunction: (settings) => settings.copyWith(theme: event.theme),
      operationType: SettingsOperationType.themeChange,
    );
  }

  /// Update language
  Future<void> _onUpdateLanguage(
    UpdateLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'language',
      value: event.languageCode,
      updateFunction: (settings) =>
          settings.copyWith(language: event.languageCode),
      operationType: SettingsOperationType.languageChange,
    );
  }

  /// Toggle auto-translate
  Future<void> _onToggleAutoTranslate(
    ToggleAutoTranslateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'autoTranslate',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(autoTranslate: event.enabled),
    );
  }

  /// Update auto-translate delay
  Future<void> _onUpdateAutoTranslateDelay(
    UpdateAutoTranslateDelayEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'autoTranslateDelay',
      value: event.delay,
      updateFunction: (settings) =>
          settings.copyWith(autoTranslateDelay: event.delay),
    );
  }

  /// Toggle speech feedback
  Future<void> _onToggleSpeechFeedback(
    ToggleSpeechFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableSpeechFeedback',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableSpeechFeedback: event.enabled),
    );
  }

  /// Update speech rate
  Future<void> _onUpdateSpeechRate(
    UpdateSpeechRateEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'speechRate',
      value: event.rate,
      updateFunction: (settings) => settings.copyWith(speechRate: event.rate),
    );
  }

  /// Update speech pitch
  Future<void> _onUpdateSpeechPitch(
    UpdateSpeechPitchEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'speechPitch',
      value: event.pitch,
      updateFunction: (settings) => settings.copyWith(speechPitch: event.pitch),
    );
  }

  /// Update speech volume
  Future<void> _onUpdateSpeechVolume(
    UpdateSpeechVolumeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'speechVolume',
      value: event.volume,
      updateFunction: (settings) =>
          settings.copyWith(speechVolume: event.volume),
    );
  }

  /// Toggle haptic feedback
  Future<void> _onToggleHapticFeedback(
    ToggleHapticFeedbackEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableHapticFeedback',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableHapticFeedback: event.enabled),
    );
  }

  /// Toggle sound effects
  Future<void> _onToggleSoundEffects(
    ToggleSoundEffectsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableSoundEffects',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableSoundEffects: event.enabled),
    );
  }

  /// Update sound effects volume
  Future<void> _onUpdateSoundEffectsVolume(
    UpdateSoundEffectsVolumeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'soundEffectsVolume',
      value: event.volume,
      updateFunction: (settings) =>
          settings.copyWith(soundEffectsVolume: event.volume),
    );
  }

  /// Toggle notifications
  Future<void> _onToggleNotifications(
    ToggleNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableNotifications',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableNotifications: event.enabled),
    );
  }

  /// Toggle push notifications
  Future<void> _onTogglePushNotifications(
    TogglePushNotificationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enablePushNotifications',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enablePushNotifications: event.enabled),
    );
  }

  /// Update default source language
  Future<void> _onUpdateDefaultSourceLanguage(
    UpdateDefaultSourceLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'defaultSourceLanguage',
      value: event.languageCode,
      updateFunction: (settings) =>
          settings.copyWith(defaultSourceLanguage: event.languageCode),
    );
  }

  /// Update default target language
  Future<void> _onUpdateDefaultTargetLanguage(
    UpdateDefaultTargetLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'defaultTargetLanguage',
      value: event.languageCode,
      updateFunction: (settings) =>
          settings.copyWith(defaultTargetLanguage: event.languageCode),
    );
  }

  /// Toggle translation confidence
  Future<void> _onToggleTranslationConfidence(
    ToggleTranslationConfidenceEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'showTranslationConfidence',
      value: event.show,
      updateFunction: (settings) =>
          settings.copyWith(showTranslationConfidence: event.show),
    );
  }

  /// Toggle alternative translations
  Future<void> _onToggleAlternativeTranslations(
    ToggleAlternativeTranslationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'showAlternativeTranslations',
      value: event.show,
      updateFunction: (settings) =>
          settings.copyWith(showAlternativeTranslations: event.show),
    );
  }

  /// Update max history items
  Future<void> _onUpdateMaxHistoryItems(
    UpdateMaxHistoryItemsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'maxHistoryItems',
      value: event.maxItems,
      updateFunction: (settings) =>
          settings.copyWith(maxHistoryItems: event.maxItems),
    );
  }

  /// Toggle auto-save translations
  Future<void> _onToggleAutoSaveTranslations(
    ToggleAutoSaveTranslationsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'autoSaveTranslations',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(autoSaveTranslations: event.enabled),
    );
  }

  /// Toggle offline mode
  Future<void> _onToggleOfflineMode(
    ToggleOfflineModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableOfflineMode',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableOfflineMode: event.enabled),
    );
  }

  /// Update data usage mode
  Future<void> _onUpdateDataUsageMode(
    UpdateDataUsageModeEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'dataUsageMode',
      value: event.mode.name,
      updateFunction: (settings) =>
          settings.copyWith(dataUsageMode: event.mode),
    );
  }

  /// Update font size multiplier
  Future<void> _onUpdateFontSizeMultiplier(
    UpdateFontSizeMultiplierEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'fontSizeMultiplier',
      value: event.multiplier,
      updateFunction: (settings) =>
          settings.copyWith(fontSizeMultiplier: event.multiplier),
    );
  }

  /// Toggle high contrast
  Future<void> _onToggleHighContrast(
    ToggleHighContrastEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableHighContrast',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableHighContrast: event.enabled),
    );
  }

  /// Toggle reduce motion
  Future<void> _onToggleReduceMotion(
    ToggleReduceMotionEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'enableReduceMotion',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(enableReduceMotion: event.enabled),
    );
  }

  /// Toggle camera flash
  Future<void> _onToggleCameraFlash(
    ToggleCameraFlashEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'useCameraFlash',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(useCameraFlash: event.enabled),
    );
  }

  /// Toggle auto-detect language
  Future<void> _onToggleAutoDetectLanguage(
    ToggleAutoDetectLanguageEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'autoDetectLanguage',
      value: event.enabled,
      updateFunction: (settings) =>
          settings.copyWith(autoDetectLanguage: event.enabled),
    );
  }

  /// Update translation cache duration
  Future<void> _onUpdateTranslationCacheDuration(
    UpdateTranslationCacheDurationEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'translationCacheDuration',
      value: event.hours,
      updateFunction: (settings) =>
          settings.copyWith(translationCacheDuration: event.hours),
    );
  }

  /// Update analytics consent
  Future<void> _onUpdateAnalyticsConsent(
    UpdateAnalyticsConsentEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'analyticsConsent',
      value: event.consent,
      updateFunction: (settings) =>
          settings.copyWith(analyticsConsent: event.consent),
    );
  }

  /// Update crash reporting consent
  Future<void> _onUpdateCrashReportingConsent(
    UpdateCrashReportingConsentEvent event,
    Emitter<SettingsState> emit,
  ) async {
    await _updateSettingWithCurrentState(
      emit: emit,
      key: 'crashReportingConsent',
      value: event.consent,
      updateFunction: (settings) =>
          settings.copyWith(crashReportingConsent: event.consent),
    );
  }

  /// Reset settings
  Future<void> _onResetSettings(
    ResetSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsResetting());

    final result = await _resetSettings();
    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
      )),
      (_) async {
        // Get the reset settings
        final settingsResult = await _getSettings();
        settingsResult.fold(
          (failure) => emit(SettingsError(failure.message, code: failure.code)),
          (settings) => emit(SettingsOperationCompleted(
            'Settings have been reset to default',
            settings,
            SettingsOperationType.reset,
          )),
        );
      },
    );
  }

  /// Export settings
  Future<void> _onExportSettings(
    ExportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsExporting());

    final result = await _exportSettings();
    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
      )),
      (exportData) => emit(SettingsExported(exportData)),
    );
  }

  /// Import settings
  Future<void> _onImportSettings(
    ImportSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsImporting());

    final result = await _importSettings(ImportSettingsParams(
      settingsJson: event.settingsJson,
    ));

    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
      )),
      (_) async {
        // Get the imported settings
        final settingsResult = await _getSettings();
        settingsResult.fold(
          (failure) => emit(SettingsError(failure.message, code: failure.code)),
          (settings) => emit(SettingsOperationCompleted(
            'Settings imported successfully',
            settings,
            SettingsOperationType.import,
          )),
        );
      },
    );
  }

  /// Helper method to update a setting and emit appropriate states
  Future<void> _updateSettingWithCurrentState<T>({
    required Emitter<SettingsState> emit,
    required String key,
    required T value,
    required AppSettings Function(AppSettings) updateFunction,
    SettingsOperationType operationType = SettingsOperationType.update,
  }) async {
    final currentState = state;
    if (currentState is! SettingsLoaded) {
      emit(const SettingsError('Cannot update setting: Settings not loaded'));
      return;
    }

    final result =
        await _updateSetting(UpdateSettingParams(key: key, value: value));
    result.fold(
      (failure) => emit(SettingsError(
        failure.message,
        code: failure.code,
        currentSettings: currentState.settings,
      )),
      (_) {
        final updatedSettings = updateFunction(currentState.settings);
        emit(SettingsOperationCompleted(
          operationType.description,
          updatedSettings,
          operationType,
        ));
      },
    );
  }

  /// Start watching settings changes
  void _startWatchingSettings() async {
    final result = await _watchSettings();
    result.fold(
      (failure) {
        // Handle error - could emit an error state or log
      },
      (stream) {
        _settingsSubscription = stream.listen((settings) {
          if (state is! SettingsUpdating &&
              state is! SettingsImporting &&
              state is! SettingsResetting) {
            emit(SettingsLoaded(settings));
          }
        });
      },
    );
  }

  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    return super.close();
  }
}
