// lib/features/settings/data/models/settings_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

import 'app_settings_model.dart';

part 'settings_model.g.dart';

/// Data model for app settings
@HiveType(typeId: 5)
@JsonSerializable()
class SettingsModel extends Equatable {
  /// App theme mode
  @HiveField(0)
  @JsonKey(toJson: _themeToJson, fromJson: _themeFromJson)
  final AppTheme theme;

  /// App language
  @HiveField(1)
  final String language;

  /// Enable auto-translate on text input
  @HiveField(2)
  final bool autoTranslate;

  /// Auto-translate delay in milliseconds
  @HiveField(3)
  final int autoTranslateDelay;

  /// Enable speech feedback
  @HiveField(4)
  final bool enableSpeechFeedback;

  /// Speech rate (0.0 to 2.0)
  @HiveField(5)
  final double speechRate;

  /// Speech pitch (0.0 to 2.0)
  @HiveField(6)
  final double speechPitch;

  /// Speech volume (0.0 to 1.0)
  @HiveField(7)
  final double speechVolume;

  /// Enable haptic feedback
  @HiveField(8)
  final bool enableHapticFeedback;

  /// Enable sound effects
  @HiveField(9)
  final bool enableSoundEffects;

  /// Sound effects volume (0.0 to 1.0)
  @HiveField(10)
  final double soundEffectsVolume;

  /// Enable notifications
  @HiveField(11)
  final bool enableNotifications;

  /// Enable push notifications
  @HiveField(12)
  final bool enablePushNotifications;

  /// Default source language
  @HiveField(13)
  final String defaultSourceLanguage;

  /// Default target language
  @HiveField(14)
  final String defaultTargetLanguage;

  /// Show translation confidence
  @HiveField(15)
  final bool showTranslationConfidence;

  /// Show alternative translations
  @HiveField(16)
  final bool showAlternativeTranslations;

  /// Maximum history items
  @HiveField(17)
  final int maxHistoryItems;

  /// Auto-save translations
  @HiveField(18)
  final bool autoSaveTranslations;

  /// Enable offline mode
  @HiveField(19)
  final bool enableOfflineMode;

  /// Data usage mode
  @HiveField(20)
  @JsonKey(toJson: _dataUsageModeToJson, fromJson: _dataUsageModeFromJson)
  final DataUsageMode dataUsageMode;

  /// Font size multiplier
  @HiveField(21)
  final double fontSizeMultiplier;

  /// Enable high contrast
  @HiveField(22)
  final bool enableHighContrast;

  /// Enable reduce motion
  @HiveField(23)
  final bool enableReduceMotion;

  /// Camera flash for OCR
  @HiveField(24)
  final bool useCameraFlash;

  /// Auto-detect language
  @HiveField(25)
  final bool autoDetectLanguage;

  /// Translation cache duration in hours
  @HiveField(26)
  final int translationCacheDuration;

  /// Privacy analytics consent
  @HiveField(27)
  final bool analyticsConsent;

  /// Privacy crash reporting consent
  @HiveField(28)
  final bool crashReportingConsent;

  /// Timestamp when settings were last updated
  @HiveField(29)
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime lastUpdated;

  SettingsModel({
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
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime(2025, 1, 1);

  /// Factory constructor for JSON deserialization
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  /// Method for JSON serialization
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);

  /// Convert to domain entity
  AppSettings toEntity() {
    return AppSettings(
      theme: theme,
      language: language,
      autoTranslate: autoTranslate,
      autoTranslateDelay: autoTranslateDelay,
      enableSpeechFeedback: enableSpeechFeedback,
      speechRate: speechRate,
      speechPitch: speechPitch,
      speechVolume: speechVolume,
      enableHapticFeedback: enableHapticFeedback,
      enableSoundEffects: enableSoundEffects,
      soundEffectsVolume: soundEffectsVolume,
      enableNotifications: enableNotifications,
      enablePushNotifications: enablePushNotifications,
      defaultSourceLanguage: defaultSourceLanguage,
      defaultTargetLanguage: defaultTargetLanguage,
      showTranslationConfidence: showTranslationConfidence,
      showAlternativeTranslations: showAlternativeTranslations,
      maxHistoryItems: maxHistoryItems,
      autoSaveTranslations: autoSaveTranslations,
      enableOfflineMode: enableOfflineMode,
      dataUsageMode: dataUsageMode,
      fontSizeMultiplier: fontSizeMultiplier,
      enableHighContrast: enableHighContrast,
      enableReduceMotion: enableReduceMotion,
      useCameraFlash: useCameraFlash,
      autoDetectLanguage: autoDetectLanguage,
      translationCacheDuration: translationCacheDuration,
      analyticsConsent: analyticsConsent,
      crashReportingConsent: crashReportingConsent,
    );
  }

  /// Create from domain entity
  factory SettingsModel.fromEntity(AppSettings settings) {
    return SettingsModel(
      theme: settings.theme,
      language: settings.language,
      autoTranslate: settings.autoTranslate,
      autoTranslateDelay: settings.autoTranslateDelay,
      enableSpeechFeedback: settings.enableSpeechFeedback,
      speechRate: settings.speechRate,
      speechPitch: settings.speechPitch,
      speechVolume: settings.speechVolume,
      enableHapticFeedback: settings.enableHapticFeedback,
      enableSoundEffects: settings.enableSoundEffects,
      soundEffectsVolume: settings.soundEffectsVolume,
      enableNotifications: settings.enableNotifications,
      enablePushNotifications: settings.enablePushNotifications,
      defaultSourceLanguage: settings.defaultSourceLanguage,
      defaultTargetLanguage: settings.defaultTargetLanguage,
      showTranslationConfidence: settings.showTranslationConfidence,
      showAlternativeTranslations: settings.showAlternativeTranslations,
      maxHistoryItems: settings.maxHistoryItems,
      autoSaveTranslations: settings.autoSaveTranslations,
      enableOfflineMode: settings.enableOfflineMode,
      dataUsageMode: settings.dataUsageMode,
      fontSizeMultiplier: settings.fontSizeMultiplier,
      enableHighContrast: settings.enableHighContrast,
      enableReduceMotion: settings.enableReduceMotion,
      useCameraFlash: settings.useCameraFlash,
      autoDetectLanguage: settings.autoDetectLanguage,
      translationCacheDuration: settings.translationCacheDuration,
      analyticsConsent: settings.analyticsConsent,
      crashReportingConsent: settings.crashReportingConsent,
      lastUpdated: DateTime.now(),
    );
  }

  /// Create default settings - FIXED STATIC METHOD
  static SettingsModel defaultSettings() {
    return SettingsModel(
      theme: AppTheme.system,
      language: 'en',
      autoTranslate: false,
      autoTranslateDelay: 1000,
      enableSpeechFeedback: true,
      speechRate: 1.0,
      speechPitch: 1.0,
      speechVolume: 1.0,
      enableHapticFeedback: true,
      enableSoundEffects: true,
      soundEffectsVolume: 0.5,
      enableNotifications: true,
      enablePushNotifications: false,
      defaultSourceLanguage: 'en',
      defaultTargetLanguage: 'es',
      showTranslationConfidence: false,
      showAlternativeTranslations: true,
      maxHistoryItems: 1000,
      autoSaveTranslations: true,
      enableOfflineMode: false,
      dataUsageMode: DataUsageMode.standard,
      fontSizeMultiplier: 1.0,
      enableHighContrast: false,
      enableReduceMotion: false,
      useCameraFlash: false,
      autoDetectLanguage: true,
      translationCacheDuration: 24,
      analyticsConsent: false,
      crashReportingConsent: false,
    );
  }

  /// Copy with method for creating modified instances
  SettingsModel copyWith({
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
    DateTime? lastUpdated,
  }) {
    return SettingsModel(
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
      lastUpdated: lastUpdated ?? DateTime.now(),
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
        lastUpdated,
      ];

  @override
  String toString() => 'SettingsModel(theme: $theme, language: $language)';
}

// JSON converters
String _themeToJson(AppTheme theme) => theme.name;
AppTheme _themeFromJson(String theme) => AppTheme.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => AppTheme.system,
    );

String _dataUsageModeToJson(DataUsageMode mode) => mode.name;
DataUsageMode _dataUsageModeFromJson(String mode) =>
    DataUsageMode.values.firstWhere(
      (e) => e.name == mode,
      orElse: () => DataUsageMode.standard,
    );

DateTime _dateTimeFromJson(String dateTime) => DateTime.parse(dateTime);
String _dateTimeToJson(DateTime dateTime) => dateTime.toIso8601String();
