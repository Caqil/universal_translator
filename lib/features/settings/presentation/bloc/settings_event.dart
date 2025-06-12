import 'package:equatable/equatable.dart';
import '../../data/models/app_settings_model.dart';

/// Base class for all settings events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load current settings
class LoadSettingsEvent extends SettingsEvent {
  const LoadSettingsEvent();
}

/// Event to update all settings
class UpdateSettingsEvent extends SettingsEvent {
  final AppSettings settings;

  const UpdateSettingsEvent(this.settings);

  @override
  List<Object?> get props => [settings];
}

/// Event to update theme
class UpdateThemeEvent extends SettingsEvent {
  final AppTheme theme;

  const UpdateThemeEvent(this.theme);

  @override
  List<Object?> get props => [theme];
}

/// Event to update language
class UpdateLanguageEvent extends SettingsEvent {
  final String languageCode;

  const UpdateLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to toggle auto-translate
class ToggleAutoTranslateEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAutoTranslateEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update auto-translate delay
class UpdateAutoTranslateDelayEvent extends SettingsEvent {
  final int delay;

  const UpdateAutoTranslateDelayEvent(this.delay);

  @override
  List<Object?> get props => [delay];
}

/// Event to toggle speech feedback
class ToggleSpeechFeedbackEvent extends SettingsEvent {
  final bool enabled;

  const ToggleSpeechFeedbackEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update speech rate
class UpdateSpeechRateEvent extends SettingsEvent {
  final double rate;

  const UpdateSpeechRateEvent(this.rate);

  @override
  List<Object?> get props => [rate];
}

/// Event to update speech pitch
class UpdateSpeechPitchEvent extends SettingsEvent {
  final double pitch;

  const UpdateSpeechPitchEvent(this.pitch);

  @override
  List<Object?> get props => [pitch];
}

/// Event to update speech volume
class UpdateSpeechVolumeEvent extends SettingsEvent {
  final double volume;

  const UpdateSpeechVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// Event to toggle haptic feedback
class ToggleHapticFeedbackEvent extends SettingsEvent {
  final bool enabled;

  const ToggleHapticFeedbackEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle sound effects
class ToggleSoundEffectsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleSoundEffectsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update sound effects volume
class UpdateSoundEffectsVolumeEvent extends SettingsEvent {
  final double volume;

  const UpdateSoundEffectsVolumeEvent(this.volume);

  @override
  List<Object?> get props => [volume];
}

/// Event to toggle notifications
class ToggleNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle push notifications
class TogglePushNotificationsEvent extends SettingsEvent {
  final bool enabled;

  const TogglePushNotificationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update default source language
class UpdateDefaultSourceLanguageEvent extends SettingsEvent {
  final String languageCode;

  const UpdateDefaultSourceLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to update default target language
class UpdateDefaultTargetLanguageEvent extends SettingsEvent {
  final String languageCode;

  const UpdateDefaultTargetLanguageEvent(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

/// Event to toggle translation confidence display
class ToggleTranslationConfidenceEvent extends SettingsEvent {
  final bool show;

  const ToggleTranslationConfidenceEvent(this.show);

  @override
  List<Object?> get props => [show];
}

/// Event to toggle alternative translations display
class ToggleAlternativeTranslationsEvent extends SettingsEvent {
  final bool show;

  const ToggleAlternativeTranslationsEvent(this.show);

  @override
  List<Object?> get props => [show];
}

/// Event to update maximum history items
class UpdateMaxHistoryItemsEvent extends SettingsEvent {
  final int maxItems;

  const UpdateMaxHistoryItemsEvent(this.maxItems);

  @override
  List<Object?> get props => [maxItems];
}

/// Event to toggle auto-save translations
class ToggleAutoSaveTranslationsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAutoSaveTranslationsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle offline mode
class ToggleOfflineModeEvent extends SettingsEvent {
  final bool enabled;

  const ToggleOfflineModeEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update data usage mode
class UpdateDataUsageModeEvent extends SettingsEvent {
  final DataUsageMode mode;

  const UpdateDataUsageModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Event to toggle analytics consent
class ToggleAnalyticsEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAnalyticsEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle crash reporting consent
class ToggleCrashReportingEvent extends SettingsEvent {
  final bool enabled;

  const ToggleCrashReportingEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update font size multiplier
class UpdateFontSizeMultiplierEvent extends SettingsEvent {
  final double multiplier;

  const UpdateFontSizeMultiplierEvent(this.multiplier);

  @override
  List<Object?> get props => [multiplier];
}

class UpdateFontSizeEvent extends SettingsEvent {
  final double multiplier;

  const UpdateFontSizeEvent(this.multiplier);

  @override
  List<Object?> get props => [multiplier];
}

/// Event to toggle high contrast
class ToggleHighContrastEvent extends SettingsEvent {
  final bool enabled;

  const ToggleHighContrastEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle reduce motion
class ToggleReduceMotionEvent extends SettingsEvent {
  final bool enabled;

  const ToggleReduceMotionEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle camera flash for OCR
class ToggleCameraFlashEvent extends SettingsEvent {
  final bool enabled;

  const ToggleCameraFlashEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to toggle auto-detect language
class ToggleAutoDetectLanguageEvent extends SettingsEvent {
  final bool enabled;

  const ToggleAutoDetectLanguageEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Event to update translation cache duration
class UpdateTranslationCacheDurationEvent extends SettingsEvent {
  final int hours;

  const UpdateTranslationCacheDurationEvent(this.hours);

  @override
  List<Object?> get props => [hours];
}

/// Event to update analytics consent
class UpdateAnalyticsConsentEvent extends SettingsEvent {
  final bool consent;

  const UpdateAnalyticsConsentEvent(this.consent);

  @override
  List<Object?> get props => [consent];
}

/// Event to update crash reporting consent
class UpdateCrashReportingConsentEvent extends SettingsEvent {
  final bool consent;

  const UpdateCrashReportingConsentEvent(this.consent);

  @override
  List<Object?> get props => [consent];
}

/// Event to reset settings to default
class ResetSettingsEvent extends SettingsEvent {
  const ResetSettingsEvent();
}

/// Event to export settings
class ExportSettingsEvent extends SettingsEvent {
  const ExportSettingsEvent();
}

/// Event to import settings
class ImportSettingsEvent extends SettingsEvent {
  final Map<String, dynamic> settingsJson;

  const ImportSettingsEvent(this.settingsJson);

  @override
  List<Object?> get props => [settingsJson];
}
