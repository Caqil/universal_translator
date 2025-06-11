// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 5;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      theme: fields[0] as AppTheme,
      language: fields[1] as String,
      autoTranslate: fields[2] as bool,
      autoTranslateDelay: fields[3] as int,
      enableSpeechFeedback: fields[4] as bool,
      speechRate: fields[5] as double,
      speechPitch: fields[6] as double,
      speechVolume: fields[7] as double,
      enableHapticFeedback: fields[8] as bool,
      enableSoundEffects: fields[9] as bool,
      soundEffectsVolume: fields[10] as double,
      enableNotifications: fields[11] as bool,
      enablePushNotifications: fields[12] as bool,
      defaultSourceLanguage: fields[13] as String,
      defaultTargetLanguage: fields[14] as String,
      showTranslationConfidence: fields[15] as bool,
      showAlternativeTranslations: fields[16] as bool,
      maxHistoryItems: fields[17] as int,
      autoSaveTranslations: fields[18] as bool,
      enableOfflineMode: fields[19] as bool,
      dataUsageMode: fields[20] as DataUsageMode,
      fontSizeMultiplier: fields[21] as double,
      enableHighContrast: fields[22] as bool,
      enableReduceMotion: fields[23] as bool,
      useCameraFlash: fields[24] as bool,
      autoDetectLanguage: fields[25] as bool,
      translationCacheDuration: fields[26] as int,
      analyticsConsent: fields[27] as bool,
      crashReportingConsent: fields[28] as bool,
      lastUpdated: fields[29] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.theme)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.autoTranslate)
      ..writeByte(3)
      ..write(obj.autoTranslateDelay)
      ..writeByte(4)
      ..write(obj.enableSpeechFeedback)
      ..writeByte(5)
      ..write(obj.speechRate)
      ..writeByte(6)
      ..write(obj.speechPitch)
      ..writeByte(7)
      ..write(obj.speechVolume)
      ..writeByte(8)
      ..write(obj.enableHapticFeedback)
      ..writeByte(9)
      ..write(obj.enableSoundEffects)
      ..writeByte(10)
      ..write(obj.soundEffectsVolume)
      ..writeByte(11)
      ..write(obj.enableNotifications)
      ..writeByte(12)
      ..write(obj.enablePushNotifications)
      ..writeByte(13)
      ..write(obj.defaultSourceLanguage)
      ..writeByte(14)
      ..write(obj.defaultTargetLanguage)
      ..writeByte(15)
      ..write(obj.showTranslationConfidence)
      ..writeByte(16)
      ..write(obj.showAlternativeTranslations)
      ..writeByte(17)
      ..write(obj.maxHistoryItems)
      ..writeByte(18)
      ..write(obj.autoSaveTranslations)
      ..writeByte(19)
      ..write(obj.enableOfflineMode)
      ..writeByte(20)
      ..write(obj.dataUsageMode)
      ..writeByte(21)
      ..write(obj.fontSizeMultiplier)
      ..writeByte(22)
      ..write(obj.enableHighContrast)
      ..writeByte(23)
      ..write(obj.enableReduceMotion)
      ..writeByte(24)
      ..write(obj.useCameraFlash)
      ..writeByte(25)
      ..write(obj.autoDetectLanguage)
      ..writeByte(26)
      ..write(obj.translationCacheDuration)
      ..writeByte(27)
      ..write(obj.analyticsConsent)
      ..writeByte(28)
      ..write(obj.crashReportingConsent)
      ..writeByte(29)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      theme: json['theme'] == null
          ? AppTheme.system
          : _themeFromJson(json['theme'] as String),
      language: json['language'] as String? ?? 'en',
      autoTranslate: json['autoTranslate'] as bool? ?? false,
      autoTranslateDelay: (json['autoTranslateDelay'] as num?)?.toInt() ?? 1000,
      enableSpeechFeedback: json['enableSpeechFeedback'] as bool? ?? true,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 1.0,
      speechPitch: (json['speechPitch'] as num?)?.toDouble() ?? 1.0,
      speechVolume: (json['speechVolume'] as num?)?.toDouble() ?? 1.0,
      enableHapticFeedback: json['enableHapticFeedback'] as bool? ?? true,
      enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
      soundEffectsVolume:
          (json['soundEffectsVolume'] as num?)?.toDouble() ?? 0.5,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enablePushNotifications:
          json['enablePushNotifications'] as bool? ?? false,
      defaultSourceLanguage: json['defaultSourceLanguage'] as String? ?? 'en',
      defaultTargetLanguage: json['defaultTargetLanguage'] as String? ?? 'es',
      showTranslationConfidence:
          json['showTranslationConfidence'] as bool? ?? false,
      showAlternativeTranslations:
          json['showAlternativeTranslations'] as bool? ?? true,
      maxHistoryItems: (json['maxHistoryItems'] as num?)?.toInt() ?? 1000,
      autoSaveTranslations: json['autoSaveTranslations'] as bool? ?? true,
      enableOfflineMode: json['enableOfflineMode'] as bool? ?? false,
      dataUsageMode: json['dataUsageMode'] == null
          ? DataUsageMode.standard
          : _dataUsageModeFromJson(json['dataUsageMode'] as String),
      fontSizeMultiplier:
          (json['fontSizeMultiplier'] as num?)?.toDouble() ?? 1.0,
      enableHighContrast: json['enableHighContrast'] as bool? ?? false,
      enableReduceMotion: json['enableReduceMotion'] as bool? ?? false,
      useCameraFlash: json['useCameraFlash'] as bool? ?? false,
      autoDetectLanguage: json['autoDetectLanguage'] as bool? ?? true,
      translationCacheDuration:
          (json['translationCacheDuration'] as num?)?.toInt() ?? 24,
      analyticsConsent: json['analyticsConsent'] as bool? ?? false,
      crashReportingConsent: json['crashReportingConsent'] as bool? ?? false,
      lastUpdated: _dateTimeFromJson(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'theme': _themeToJson(instance.theme),
      'language': instance.language,
      'autoTranslate': instance.autoTranslate,
      'autoTranslateDelay': instance.autoTranslateDelay,
      'enableSpeechFeedback': instance.enableSpeechFeedback,
      'speechRate': instance.speechRate,
      'speechPitch': instance.speechPitch,
      'speechVolume': instance.speechVolume,
      'enableHapticFeedback': instance.enableHapticFeedback,
      'enableSoundEffects': instance.enableSoundEffects,
      'soundEffectsVolume': instance.soundEffectsVolume,
      'enableNotifications': instance.enableNotifications,
      'enablePushNotifications': instance.enablePushNotifications,
      'defaultSourceLanguage': instance.defaultSourceLanguage,
      'defaultTargetLanguage': instance.defaultTargetLanguage,
      'showTranslationConfidence': instance.showTranslationConfidence,
      'showAlternativeTranslations': instance.showAlternativeTranslations,
      'maxHistoryItems': instance.maxHistoryItems,
      'autoSaveTranslations': instance.autoSaveTranslations,
      'enableOfflineMode': instance.enableOfflineMode,
      'dataUsageMode': _dataUsageModeToJson(instance.dataUsageMode),
      'fontSizeMultiplier': instance.fontSizeMultiplier,
      'enableHighContrast': instance.enableHighContrast,
      'enableReduceMotion': instance.enableReduceMotion,
      'useCameraFlash': instance.useCameraFlash,
      'autoDetectLanguage': instance.autoDetectLanguage,
      'translationCacheDuration': instance.translationCacheDuration,
      'analyticsConsent': instance.analyticsConsent,
      'crashReportingConsent': instance.crashReportingConsent,
      'lastUpdated': _dateTimeToJson(instance.lastUpdated),
    };
