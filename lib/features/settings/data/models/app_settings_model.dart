// lib/features/settings/data/models/app_settings_model.dart
import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

/// Application settings configuration
class AppSettings extends Equatable {
  /// App theme mode
  final AppTheme theme;

  /// App language
  final String language;

  /// Enable auto-translate on text input
  final bool autoTranslate;

  /// Auto-translate delay in milliseconds
  final int autoTranslateDelay;

  /// Enable speech feedback
  final bool enableSpeechFeedback;

  /// Speech rate (0.0 to 2.0)
  final double speechRate;

  /// Speech pitch (0.0 to 2.0)
  final double speechPitch;

  /// Speech volume (0.0 to 1.0)
  final double speechVolume;

  /// Enable haptic feedback
  final bool enableHapticFeedback;

  /// Enable sound effects
  final bool enableSoundEffects;

  /// Sound effects volume (0.0 to 1.0)
  final double soundEffectsVolume;

  /// Enable notifications
  final bool enableNotifications;

  /// Enable push notifications
  final bool enablePushNotifications;

  /// Default source language
  final String defaultSourceLanguage;

  /// Default target language
  final String defaultTargetLanguage;

  /// Show translation confidence
  final bool showTranslationConfidence;

  /// Show alternative translations
  final bool showAlternativeTranslations;

  /// Maximum history items
  final int maxHistoryItems;

  /// Auto-save translations
  final bool autoSaveTranslations;

  /// Enable offline mode
  final bool enableOfflineMode;

  /// Data usage mode
  final DataUsageMode dataUsageMode;

  /// Font size multiplier
  final double fontSizeMultiplier;

  /// Enable high contrast
  final bool enableHighContrast;

  /// Enable reduce motion
  final bool enableReduceMotion;

  /// Camera flash for OCR
  final bool useCameraFlash;

  /// Auto-detect language
  final bool autoDetectLanguage;

  /// Translation cache duration in hours
  final int translationCacheDuration;

  /// Privacy analytics consent
  final bool analyticsConsent;

  /// Privacy crash reporting consent
  final bool crashReportingConsent;

  const AppSettings({
    this.theme = AppTheme.system,
    this.language = 'en',
    this.autoTranslate = false,
    this.autoTranslateDelay = 1000,
    this.enableSpeechFeedback = true,
    this.speechRate = 1.0,
    this.speechPitch = 1.0,
    this.speechVolume = 1.0,
    this.enableHapticFeedback = true,
    this.enableSoundEffects = true,
    this.soundEffectsVolume = 0.5,
    this.enableNotifications = true,
    this.enablePushNotifications = false,
    this.defaultSourceLanguage = 'en',
    this.defaultTargetLanguage = 'es',
    this.showTranslationConfidence = false,
    this.showAlternativeTranslations = true,
    this.maxHistoryItems = 1000,
    this.autoSaveTranslations = true,
    this.enableOfflineMode = false,
    this.dataUsageMode = DataUsageMode.standard,
    this.fontSizeMultiplier = 1.0,
    this.enableHighContrast = false,
    this.enableReduceMotion = false,
    this.useCameraFlash = false,
    this.autoDetectLanguage = true,
    this.translationCacheDuration = 24,
    this.analyticsConsent = false,
    this.crashReportingConsent = false,
  });

  /// Create a copy with modified values
  AppSettings copyWith({
    AppTheme? theme,
    String? language,
    bool? autoTranslate,
    int? autoTranslateDelay,
    bool? enableSpeechFeedback,
    double? speechRate,
    double? speechPitch,
    double? speechVolume,
    bool? enableHapticFeedback,
    bool? enableSoundEffects,
    double? soundEffectsVolume,
    bool? enableNotifications,
    bool? enablePushNotifications,
    String? defaultSourceLanguage,
    String? defaultTargetLanguage,
    bool? showTranslationConfidence,
    bool? showAlternativeTranslations,
    int? maxHistoryItems,
    bool? autoSaveTranslations,
    bool? enableOfflineMode,
    DataUsageMode? dataUsageMode,
    double? fontSizeMultiplier,
    bool? enableHighContrast,
    bool? enableReduceMotion,
    bool? useCameraFlash,
    bool? autoDetectLanguage,
    int? translationCacheDuration,
    bool? analyticsConsent,
    bool? crashReportingConsent,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      autoTranslateDelay: autoTranslateDelay ?? this.autoTranslateDelay,
      enableSpeechFeedback: enableSpeechFeedback ?? this.enableSpeechFeedback,
      speechRate: speechRate ?? this.speechRate,
      speechPitch: speechPitch ?? this.speechPitch,
      speechVolume: speechVolume ?? this.speechVolume,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      soundEffectsVolume: soundEffectsVolume ?? this.soundEffectsVolume,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      defaultSourceLanguage:
          defaultSourceLanguage ?? this.defaultSourceLanguage,
      defaultTargetLanguage:
          defaultTargetLanguage ?? this.defaultTargetLanguage,
      showTranslationConfidence:
          showTranslationConfidence ?? this.showTranslationConfidence,
      showAlternativeTranslations:
          showAlternativeTranslations ?? this.showAlternativeTranslations,
      maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
      autoSaveTranslations: autoSaveTranslations ?? this.autoSaveTranslations,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      dataUsageMode: dataUsageMode ?? this.dataUsageMode,
      fontSizeMultiplier: fontSizeMultiplier ?? this.fontSizeMultiplier,
      enableHighContrast: enableHighContrast ?? this.enableHighContrast,
      enableReduceMotion: enableReduceMotion ?? this.enableReduceMotion,
      useCameraFlash: useCameraFlash ?? this.useCameraFlash,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
      translationCacheDuration:
          translationCacheDuration ?? this.translationCacheDuration,
      analyticsConsent: analyticsConsent ?? this.analyticsConsent,
      crashReportingConsent:
          crashReportingConsent ?? this.crashReportingConsent,
    );
  }

  @override
  List<Object?> get props => [
        theme,
        language,
        autoTranslate,
        autoTranslateDelay,
        enableSpeechFeedback,
        speechRate,
        speechPitch,
        speechVolume,
        enableHapticFeedback,
        enableSoundEffects,
        soundEffectsVolume,
        enableNotifications,
        enablePushNotifications,
        defaultSourceLanguage,
        defaultTargetLanguage,
        showTranslationConfidence,
        showAlternativeTranslations,
        maxHistoryItems,
        autoSaveTranslations,
        enableOfflineMode,
        dataUsageMode,
        fontSizeMultiplier,
        enableHighContrast,
        enableReduceMotion,
        useCameraFlash,
        autoDetectLanguage,
        translationCacheDuration,
        analyticsConsent,
        crashReportingConsent,
      ];

  @override
  String toString() => 'AppSettings(theme: $theme, language: $language)';
}

/// App theme enumeration with proper Hive annotations - FIXED
@HiveType(typeId: 1)
enum AppTheme {
  @HiveField(0)
  light,

  @HiveField(1)
  dark,

  @HiveField(2)
  system;

  String get displayName {
    switch (this) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }
}

/// Data usage mode enumeration with proper Hive annotations - FIXED
@HiveType(typeId: 2)
enum DataUsageMode {
  @HiveField(0)
  low,

  @HiveField(1)
  standard,

  @HiveField(2)
  unlimited;

  String get displayName {
    switch (this) {
      case DataUsageMode.low:
        return 'Low Data';
      case DataUsageMode.standard:
        return 'Standard';
      case DataUsageMode.unlimited:
        return 'Unlimited';
    }
  }

  String get description {
    switch (this) {
      case DataUsageMode.low:
        return 'Minimizes data usage by limiting features';
      case DataUsageMode.standard:
        return 'Balanced data usage for most features';
      case DataUsageMode.unlimited:
        return 'Full features with unrestricted data usage';
    }
  }
}
